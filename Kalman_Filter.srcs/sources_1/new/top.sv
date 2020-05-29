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
    input float32 idata,
    input clk,
    input enable,
    output float32 odata
    );
//    logic clk = 0, reset_n = 0, enable = 0, request_result_and_reset=0,result_ready,idata_valid=0; 
//    float32 a, b, result, expected; 
//    MAC mac(a, b, result, clk, reset_n, enable, request_result_and_reset,idata_valid, result_ready);
    
    parameter matrix_array_length=3;
    parameter matrix_size=6;
    
    Float_matrix_manipulation_interface i_bus();
    assign idata =i_bus.idata;
    assign odata = i_bus.odata;
    Float_matrix_manipulation # (matrix_array_length,matrix_size) matrix_pu(i_bus);
    
endmodule
