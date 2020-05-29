`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2020 03:20:53 PM
// Design Name: 
// Module Name: Float32_ram_2p1c
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
import float::*;

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
    end
    
//    always_ff @ (posedge clk) begin
//        if(enb) begin
//            dob<=ram[addrb];
//        end
//    end
    assign dob = enb ? ram[addrb]: 'b0;
    
endmodule
