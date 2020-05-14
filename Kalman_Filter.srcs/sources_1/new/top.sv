`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2020 03:09:36 PM
// Design Name: 
// Module Name: top
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
// cmd /S /k "code -r -g [file name]:[line number]"
//////////////////////////////////////////////////////////////////////////////////

import float::*;
module top(
//    input [7:0] Data,
//    input clk,
//    input enable
    );
    logic clk = 0, reset_n = 0, enable = 0, request_result_and_reset=0,result_ready,idata_valid=0; 
    float32 a, b, result, expected; 
    MAC mac(a, b, result, clk, reset_n, enable, request_result_and_reset,idata_valid, result_ready);
    
    
    
endmodule
