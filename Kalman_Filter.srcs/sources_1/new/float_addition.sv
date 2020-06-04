`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 09:12:09 AM
// Design Name: 
// Module Name: Float_addition
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Adding two floats
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// 
// 
// TODO:
//      Pipeline
//////////////////////////////////////////////////////////////////////////////////
import float32_addition::*;
import float:: * ; 


// --------------------------------------------- DEPRICATED ----------------------------------
// ----------------------------------------- DO NOT USE!!! -----------------------------------
module Float_addition(input logic clk, 
                        input float32 idata, 
                        output float32 odata, 
                        output logic data_ready, 
                        input logic reset_n, 
                        input logic enable
                        ); 
    enum {load_a = 0, load_b = 1, send_result = 2}state; 

    float32 a, b, next_result;
        
    always_comb begin
        next_result=add_float32(a,b);
    end

    always_ff @(negedge clk)begin
        if (~reset_n)begin
            odata <= 0; 
            data_ready <= 0; 
            state <= load_a; 
        end
        else if (enable)begin
            case(state)

                load_a:begin 
                    a <= idata; 
                    data_ready <= 0; 
                    state <= load_b; 
                    end

                load_b:begin
                    b <= idata; 
                    state <= send_result; 
                    end

                send_result:begin
                    odata <= next_result; 
                    data_ready <= 1; 
                    state<=load_a;
                end
                
                default: begin
                    odata <= 0; 
                    data_ready <= 0; 
                    state<=load_b;
                end
            endcase
        end
    end
        

    
endmodule