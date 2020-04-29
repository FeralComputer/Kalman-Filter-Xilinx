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


module top(
//    input [7:0] Data,
//    input clk,
//    input enable
    );
    logic [7:0] data_out ;
    logic [7:0] data_in='1;
    logic clk=0;
    logic enable=0;
    
    Kalman_Filter kf (.clk,.data_in,.enable,.data_out);
    
    
    
endmodule
