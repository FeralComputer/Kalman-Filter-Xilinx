`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 05/10/2020 12:27:05 PM
// Design Name: 
// Module Name: MAC
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: multiplies and accumulates float32s in N+1 cycles
// 
// Dependencies: float32_multiplication, float32_addition
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float32_multiplication::*;
import float32_addition::*;
import float:: * ; 

module MAC(
    input float32 a,
    input float32 b,
    output float32 result,
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic request_result_and_reset,
    input logic idata_valid,
    output logic result_ready
    );
    
    float32 multiplication_result;
    float32 accumulated_result,next_accumulated_result;
    
    enum {entry,accumulate,send_result,wait_for_data}state;
    
    
    always_comb begin
        multiplication_result=float32_multiplication::multiply_float32(a,b);
        if (idata_valid)  
            next_accumulated_result=add_float32(accumulated_result,multiplication_result);
        else
            next_accumulated_result=accumulated_result;
    end
    
    always_ff @(posedge clk) begin
        if(~reset_n) begin
            state<=entry;
            result_ready<=0;
            accumulated_result<=0;
            
        end
        else if (enable) begin
            case(state)
                entry: begin
                    accumulated_result<=0;
                    state<=accumulate;                    
                end
                
                accumulate: begin
                    result_ready<=0;
                    
                    accumulated_result<= next_accumulated_result;
                    
                    if(request_result_and_reset)
                        state<=send_result;
                end
                
                send_result: begin
                    result<=accumulated_result;
                    result_ready<=1;
                    
                    accumulated_result<=0;
                    
                    if (idata_valid)
                        state<=accumulate;
                    else
                        state<=wait_for_data;
                end
                
                wait_for_data: begin
                    result_ready<=0;
                    if(idata_valid)
                        state<=accumulate;
                end
            endcase
            
        end
    end
    
endmodule
