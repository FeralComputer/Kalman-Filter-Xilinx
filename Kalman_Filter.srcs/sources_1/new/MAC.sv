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
// Description: multiplies and accumulates float32s in N cycles if the new itteration
//              starts while the result is returned
// 
// Dependencies: float32_multiplication, float32_addition
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float32_multiplication:: * ; 
import float32_addition:: * ; 
import float:: * ; 

//interface MAC_interface contains the data between MAC and parent module
// NOTE: inputs might be a good thing to have
interface MAC_interface (); 
float32 a, b; 
float32 result; 
logic clk, reset_n, enable, request_result_and_reset, idata_valid, result_ready; 
modport mac_stream(input a, input b, output result, input clk, input reset_n, input enable, input request_result_and_reset, 
                    input idata_valid, output result_ready); 
modport upstream(output a, output b, input result, output clk, output reset_n, output enable, output request_result_and_reset, 
                    output idata_valid, input result_ready); 
endinterface

//Module Float_matrix_manipulation stores, adds, multiplies, and returns matricies
// input: (MAC_interface.mac_stream) mac which holds the data between parent and this module
// NOTE: should rename to Float32_MAC
module MAC(
    MAC_interface.mac_stream mac
    ); 

float32 multiplication_result; 
float32 accumulated_result, next_accumulated_result; 

enum {entry, accumulate, send_result, wait_for_data}state; 


always_comb begin

    //multiplies a and b inputs and accumulates the result if idata is valid
    multiplication_result = float32_multiplication::multiply_float32(mac.a, mac.b); 
    if (mac.idata_valid)
        next_accumulated_result = add_float32(accumulated_result, multiplication_result); 
    else
        next_accumulated_result = accumulated_result; 
    end
    
always_ff @(posedge mac.clk)begin
    if (~mac.reset_n)begin
        state <= entry; 
        mac.result_ready <= 0; 
        accumulated_result <= 0; 

    end
    else if (mac.enable)begin
        case(state)
            entry:begin
                accumulated_result <= 0; 
                state <= accumulate; 
            end
                
            accumulate:begin
                mac.result_ready <= 0; 
                
                if(mac.idata_valid)
                    accumulated_result <= next_accumulated_result; 

                if (mac.request_result_and_reset)
                    state <= send_result; 
            end
                
            send_result:begin
                mac.result <= accumulated_result; 
                mac.result_ready <= 1;
                state <= accumulate;  

                if (mac.idata_valid) begin
                    accumulated_result <= multiplication_result; 
                end else begin 
                    accumulated_result <= 0; 
//                    state <= wait_for_data; 
                end
            end
                
            wait_for_data:begin
                mac.result_ready <= 0; 
                if (mac.idata_valid)
                    state <= accumulate; 
            end

        endcase
            
        end
    end
    
endmodule
