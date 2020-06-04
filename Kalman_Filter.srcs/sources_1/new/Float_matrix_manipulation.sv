`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer   
// 
// Create Date: 05/14/2020 01:27:17 PM
// Design Name: 
// Module Name: Float_matrix_manipulation
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Float_matrix_manipulation stores , multiplies, adds, and
//              returns matricies.
// 
// Dependencies: Uses float32_addition, MAC, Float32_ram_2p1c
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float::*;
import float32_addition::*;


//Interface Float_matrix_manipulation_interface holds the data between parent and Float_matrix_manipulation
// (modport) downstream is intended for Float_matrix_manipulation
// (modport) upstream is intended for the parent module
// NOTE: this interface could input some of the signals
interface Float_matrix_manipulation_interface();
    float32 idata,odata;
    enum {load_matrix,return_matrix, read_write, multiply_matrix, add_matrix, idle} instruction;
    int xindex,yindex,address;
    int operator1, operator2, operator_result;
    logic idata_valid, clk,reset_n,enable,odata_valid, operation_done;
                                        
    modport downstream( input idata, 
                        input instruction, 
                        input address, 
                        input xindex,
                        input yindex,
                        input idata_valid,
                        input clk,
                        input reset_n,
                        input enable,
                        input operator1,
                        input operator2,
                        input operator_result,
                        output odata,
                        output odata_valid,
                        output operation_done);                                    
    modport upstream(   input odata,
                        input odata_valid,
                        input operation_done, 
                        output instruction, 
                        output address, 
                        output xindex,
                        output yindex,
                        output idata_valid,
                        output clk,
                        output reset_n,
                        output enable,
                        output idata,
                        output operator1,
                        output operator2,
                        output operator_result);
endinterface

interface adder_logic_interface();
    enum {senda, senda_loadresult, sendb, load_last_result, idle} state;
    int xindex, yindex, xindex_prev, yindex_prev;
    float32 a,b;
endinterface

//Module Float_matrix_manipulation stores, adds, multiplies, and returns matricies
// input: (Float_matrix_manipulation_interface.downstream) i_bus which holds the data between parent and this module
// parameter: (int) matrix_array_length is the number of individual matricies
// parameter: (int) matrix_size is the height/width of the square matricies used (N)
module Float_matrix_manipulation#(matrix_array_length=2,matrix_size=2)(Float_matrix_manipulation_interface.downstream i_bus                          
);
    logic ena, enb, wea;
    int addra, addrb;
    float32 dia,dob;
    Float32_ram_2p1c#(matrix_array_length*matrix_size*matrix_size)ram(i_bus.clk, ena, enb, wea,addra, addrb,dia,dob);
    
    int state;
      
    MAC_interface mac();
    MAC m_mac(mac);
    
    adder_logic_interface i_adder();
    
//    assign #1ps dia = i_bus.instruction==i_bus.load_matrix ||i_bus.instruction==i_bus.read_write ? i_bus.idata : 'bz ;
    assign #1ps i_bus.odata = dob;
    assign wea = ena;
    assign #1ps i_bus.odata_valid =  i_bus.instruction==i_bus.return_matrix ||i_bus.instruction==i_bus.read_write ? 1 : 0;
    assign #1ps i_bus.odata_valid =  i_bus.instruction==i_bus.return_matrix ||i_bus.instruction==i_bus.read_write ? 1 : 0;
    
    
    always_comb begin
        if(~i_bus.reset_n) begin
            addra = 0;
            addrb = 0;
            ena = 0;
            enb = 0;
        end else begin
            case(i_bus.instruction)
                i_bus.load_matrix: begin
                    #1ps 
                    dia = i_bus.idata;
                    addra = i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex;
                    ena = 1;
                    addrb =  0;
                    enb = 0;
                end
                
                i_bus.return_matrix: begin
                    #1ps 
                    dia = i_bus.idata;
                    addra = 0;
                    ena = 0;
                    addrb =  i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex;
                    enb = 1;
                end
                
                i_bus.read_write: begin
                    #1ps 
                    dia = i_bus.idata;
                    addra = i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex;
                    ena = 1;
                    addrb =  i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex;
                    enb = 1;
                end
                
                i_bus.add_matrix: begin
                    #1ps 
                    //add the result into ram
                    dia = add_float32(i_adder.a, i_adder.b); 
                    if(i_adder.state == i_adder.senda) begin
                        addrb =  i_bus.operator1*matrix_size*matrix_size + i_adder.yindex*matrix_size + i_adder.xindex;
                        enb = 1;
                        addra = i_bus.operator_result*matrix_size*matrix_size + i_adder.yindex_prev*matrix_size + i_adder.xindex_prev; 
                        ena = 0;
                    end else if(i_adder.state == i_adder.senda_loadresult) begin                       
                        addrb =  i_bus.operator1*matrix_size*matrix_size + i_adder.yindex*matrix_size + i_adder.xindex;
                        enb = 1;
                        addra = i_bus.operator_result*matrix_size*matrix_size + i_adder.yindex_prev*matrix_size + i_adder.xindex_prev; 
                        ena = 1;
                    end else if(i_adder.state == i_adder.sendb) begin
                        addrb =  i_bus.operator2*matrix_size*matrix_size + i_adder.yindex*matrix_size + i_adder.xindex;
                        enb = 1;
                        addra = i_bus.operator_result*matrix_size*matrix_size + i_adder.yindex_prev*matrix_size + i_adder.xindex_prev;
                        ena = 0;
                    end else if(i_adder.state ==i_adder.load_last_result) begin
                        addrb = 'bx;
                        enb = 0;
                        addra = i_bus.operator_result*matrix_size*matrix_size + i_adder.yindex_prev*matrix_size + i_adder.xindex_prev;
                        ena = 1;
                    end else begin
                        addrb = 0;
                        enb = 0;
                        addra = i_bus.operator_result*matrix_size*matrix_size + i_adder.yindex_prev*matrix_size + i_adder.xindex_prev;
                        ena = 0;
                    end
                    
                    
                end
                
                default: begin
                    #1ps 
                    addra = 0;
                    ena = 0;
                    addrb = 0;
                    enb = 0;
                    dia = i_bus.idata;
                end
            endcase
        end
    end
    
    always_ff @(posedge i_bus.clk) begin
        if(~i_bus.reset_n) begin
            state<=i_bus.idle;
            mac.enable<=0;
            mac.request_result_and_reset<=0;
            mac.idata_valid<=0;
            i_bus.operation_done <= 0;
            i_adder.state <= i_adder.senda;
            i_adder.xindex <= 0;
            i_adder.yindex <= 0;
            i_adder.xindex_prev <= 0;
            i_adder.yindex_prev <= 0;

        end else if (i_bus.enable) begin
            
            case (i_bus.instruction)
                i_bus.idle: begin
                    
                end
                
                i_bus.return_matrix: begin

                end
                   
                i_bus.load_matrix: begin
                end
                
                i_bus.multiply_matrix: begin
                
                end
                
                i_bus.add_matrix: begin
                    case(i_adder.state)
                    
                        i_adder.senda: begin
                            i_adder.state <= i_adder.sendb;
                            //store the first element to be added
                            i_adder.a <= dob;
                            
                        end
                        
                        i_adder.senda_loadresult: begin
                            i_adder.state <= i_adder.sendb;
                            //store the first element to be added
                            i_adder.a <= dob;
                            
                        end
                        
                        i_adder.sendb: begin
                            i_adder.xindex_prev <= i_adder.xindex;
                            i_adder.yindex_prev <= i_adder.yindex;
                            i_adder.b <= dob;                            
                            //determine the new x and y indexes
                            if(i_adder.xindex < matrix_size - 1) begin
                                i_adder.xindex <= i_adder.xindex + 'b1;
                                i_adder.state <= i_adder.senda_loadresult;
                            end else if (i_adder.yindex < matrix_size - 1) begin
                                i_adder.xindex <= 'b0;
                                i_adder.yindex <= i_adder.yindex + 'b1;
                                i_adder.state <= i_adder.senda_loadresult;
                            end else begin
                                i_adder.state <= i_adder.load_last_result;
                            end
                        end
                        
                        i_adder.load_last_result: begin
                            i_adder.state <= i_adder.idle;
                            i_bus.operation_done <=1;
                            i_adder.xindex <= 0;
                            i_adder.yindex <= 0;
                            i_adder.xindex_prev <= 0;
                            i_adder.yindex_prev <= 0;
                            //save last addition
                        end
                        
                        i_adder.idle: begin
                            
                        end
                        
                    endcase
                    
                    
                end            
                
            endcase
            
            
            //entry and exit conditions
            if(i_bus.instruction!=state) begin
                // Exit conditions for states
                state<=i_bus.instruction;
                case(state)
                    i_bus.idle: begin
                    
                    end
                    
                    i_bus.return_matrix: begin
                    
                    end
                    
                    i_bus.load_matrix: begin
                        
                    end
                    
                    i_bus.multiply_matrix: begin
                    
                    end
                    
                    i_bus.add_matrix: begin
                        // the parent should only leave add_matrix once operation_done
                        i_bus.operation_done <= 0;
                        i_adder.state <= i_adder.senda;
                    end
                endcase
                
                // entry cases
                case(i_bus.instruction)
                    i_bus.idle: begin
                    
                    end
                    
                    i_bus.return_matrix: begin

                    end
                    
                    i_bus.load_matrix: begin

                    end
                    
                    i_bus.multiply_matrix: begin
                    
                    end
                    
                    i_bus.add_matrix: begin
//                        i_adder.state <= i_adder.senda_loadresult;
                    end
                endcase
            end
            
        end
        
    end
    
    
endmodule

