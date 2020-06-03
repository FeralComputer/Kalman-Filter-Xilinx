`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2020 03:20:53 PM
// Design Name: 
// Module Name: Float32_ram_2p1c
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: implementation of float32 block ram with asyncronous read
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float::*;

//Module Float32_ram_2p1c implements float32 blockram with asyncronous read
// input: (logic) clk clock for writes 
// input: (logic) ena enables writing to ram
// input: (logic) enb enables reading from ram
// input: (logic) wea enables writing to ram (likely redundant)
// input: (int) addra address for writing to ram
// input: (int) addrb address for reading from ram
// input: (float32) dia data to be written to ram 
// parameter: (int) RAM_SIZE=1024 is the size of ram created
// output: (float32) dob data read from ram
module Float32_ram_2p1c#(RAM_SIZE=1024)(   input logic clk, ena, enb, wea, 
                                           int addra, addrb,
                                           float32 dia, 
                                           output float32 dob);
    
    float32 ram[0:RAM_SIZE-1];
    
    always_ff @ (posedge clk) begin
        if(ena) begin
            if(wea) begin
                ram[addra]<=dia;
            end
        end
//        if (enb) begin
//            dob <= ram[addrb];
//        end
    end
    
    assign #1ps dob = enb ? ram[addrb]: 'b0;
    
endmodule
