`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2020 03:09:36 PM
// Design Name: 
// Module Name: Kalman_Filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Kalman_Filter(
input logic clk, 
input logic [7:0] data_in, 
input logic enable, 
output logic [7:0] data_out 
    ); 


always_ff @(posedge clk)begin
        if (enable)
data_out <= data_in; 
else
            data_out <= '0;
            
    end
endmodule
