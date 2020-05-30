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


//Interface Float_matrix_manipulation_interface holds the data between parent and Float_matrix_manipulation
// (modport) downstream is intended for Float_matrix_manipulation
// (modport) upstream is intended for the parent module
// NOTE: this interface could input some of the signals
interface Float_matrix_manipulation_interface();
    float32 idata,odata;
    enum {load_matrix,return_matrix, multiply_matrix,add_matrix,idle} instruction;
    int xindex,yindex,address;
    logic idata_valid, clk,reset_n,enable,odata_valid;
                                        
    modport downstream( input idata, 
                        input instruction, 
                        input address, 
                        input xindex,
                        input yindex,
                        input idata_valid,
                        input clk,
                        input reset_n,
                        input enable,
                        output odata,
                        output odata_valid);                                    
    modport upstream(   input odata, 
                        input instruction, 
                        input address, 
                        input xindex,
                        input yindex,
                        input idata_valid,
                        input clk,
                        input reset_n,
                        input enable,
                        output idata,
                        output odata_valid );
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
    logic transition;
    
    int state;
      
    MAC_interface mac();
    MAC m_mac(mac);
    
    assign addra = i_bus.instruction==i_bus.load_matrix ? i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex:'b0;
    assign addrb = i_bus.instruction==i_bus.return_matrix ? i_bus.address*matrix_size*matrix_size + i_bus.yindex*matrix_size + i_bus.xindex:'b0;
    assign dia = i_bus.idata;
    assign i_bus.odata = dob;
    assign enb = i_bus.instruction==i_bus.return_matrix ? 1 : 0;
    assign ena = i_bus.instruction==i_bus.load_matrix ? 1 : 0;
    assign wea = ena;
    assign i_bus.odata_valid = enb;
    
    always_comb begin
        
    end
    
    always_ff @(posedge i_bus.clk) begin
        if(~i_bus.reset_n) begin
            state<=i_bus.idle;
            mac.enable<=0;
            mac.request_result_and_reset<=0;
            mac.idata_valid<=0;
            transition<=1;

        end else if (i_bus.enable) begin
            
            case (state)
                i_bus.idle: begin
                    
                end
                
                i_bus.return_matrix: begin

                end
                   
                i_bus.load_matrix: begin
                end
                
                i_bus.multiply_matrix: begin
                
                end
                
                i_bus.add_matrix: begin
                
                end            
                
            endcase
            
            
            // Exit conditions for states
            if(i_bus.instruction!=state) begin
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
                    
                    end
                endcase
                
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
                    
                    end
                endcase
            end
            
        end
        
    end
    
    
endmodule

