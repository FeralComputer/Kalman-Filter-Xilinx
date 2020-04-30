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
    logic [7:0] data_out ;
    logic [7:0] data_in='1;
    logic clk=0;
    logic enable=0,reset_n=1;
    float32 idata,odata;
    
//    Kalman_Filter kf (.clk,.data_in,.enable,.odata(odata[7:0]));
    Float_addition fadd(clk,idata,odata,data_ready,reset_n,enable);
    
    
    
endmodule
