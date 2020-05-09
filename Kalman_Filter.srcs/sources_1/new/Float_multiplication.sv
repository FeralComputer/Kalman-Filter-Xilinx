`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 09:12:09 AM
// Design Name: 
// Module Name: Float_multiplication
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Multiplies two floats together
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float32_multiplication::*;
//Function msb_search finds the most significant '1' and returns its index
    // input: added_significants is the added significants of two float32s
    // output: int the index of the most significant '1'
    // NOTE: this function could be abstracted more for general purpose
//function automatic int msb_search_(input logic [50:0] added_significants); 
//    for (int i = 49; i >= 23; i = i-1)begin:unrolling_normalization
//        if (added_significants[i + 1])begin
//            msb_search_ = i; 
//            break; 
//        end
//    end
//endfunction

import float:: * ; 



module Float_multiplication(input logic clk, 
                        input float32 idata, 
                        output float32 odata, 
                        output logic data_ready, 
                        input logic reset_n, 
                        input logic enable
                        );
    
    enum {load_a,load_b,send_result} state;                    
    float32 a,b,result;
    
    always_comb begin
        result=float32_multiplication::multiply_float32(a,b);    
    end
    
    always_ff @(posedge clk) begin
        if(~reset_n) begin
            odata<=0;
            data_ready<=0;
        end
        else if (enable) begin
            case(state)
                load_a: begin
                    a<=idata;
                    state<=load_b;
                    end
                    
                load_b: begin
                    b<=idata;
                    state<=send_result;
                    end
                    
                send_result: begin
                    odata<=result;
                    data_ready<=1;
                    state<=load_a;
                    end
                    
                default: begin
                    state<=load_a;
                    data_ready<=0;
                    end
            endcase
            
        end
    end
    
    
endmodule
