`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 09:12:09 AM
// Design Name: 
// Module Name: Float
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Structure of float
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package float;
    typedef struct packed{
        logic sign;
        logic [7:0] exponent;
        logic [22:0] significant;
    }float32;
endpackage