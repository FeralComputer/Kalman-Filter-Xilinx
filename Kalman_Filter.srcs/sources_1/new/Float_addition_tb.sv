`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 09:12:09 AM
// Design Name: 
// Module Name: Float_addition_tb
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Testing of Float_addition
// 
// Dependencies: Float.sv and Float_addition.sv
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////

import float:: * ; 
module Float_addition_tb(); 

    logic clk = 0, reset_n = 0, enable = 0,data_ready; 
    float32 idata, odata; 
    Float_addition adder(clk, idata, odata, data_ready, reset_n, enable); 
    logic failed = 0,run_failed=0;

    float32 inputdata [111:0] = {'b00111111000000000000000000000000,'b00111111000000000000000000000000,
'b00111111000000000000000000000000,'b00111111010011001100110011001101,
'b00111111000000000000000000000000,'b00111111100011001100110011001101,
'b00111111000000000000000000000000,'b00111111101100110011001100110011,
'b00111111000000000000000000000000,'b00111111110110011001100110011010,
'b00111111000000000000000000000000,'b01000000000000000000000000000000,
'b00111111000000000000000000000000,'b01000000000100110011001100110011,
'b00111111001100110011001100110011,'b00111111000000000000000000000000,
'b00111111001100110011001100110011,'b00111111010011001100110011001101,
'b00111111001100110011001100110011,'b00111111100011001100110011001101,
'b00111111001100110011001100110011,'b00111111101100110011001100110011,
'b00111111001100110011001100110011,'b00111111110110011001100110011010,
'b00111111001100110011001100110011,'b01000000000000000000000000000000,
'b00111111001100110011001100110011,'b01000000000100110011001100110011,
'b00111111011001100110011001100110,'b00111111000000000000000000000000,
'b00111111011001100110011001100110,'b00111111010011001100110011001101,
'b00111111011001100110011001100110,'b00111111100011001100110011001101,
'b00111111011001100110011001100110,'b00111111101100110011001100110011,
'b00111111011001100110011001100110,'b00111111110110011001100110011010,
'b00111111011001100110011001100110,'b01000000000000000000000000000000,
'b00111111011001100110011001100110,'b01000000000100110011001100110011,
'b00111111100011001100110011001101,'b00111111000000000000000000000000,
'b00111111100011001100110011001101,'b00111111010011001100110011001101,
'b00111111100011001100110011001101,'b00111111100011001100110011001101,
'b00111111100011001100110011001101,'b00111111101100110011001100110011,
'b00111111100011001100110011001101,'b00111111110110011001100110011010,
'b00111111100011001100110011001101,'b01000000000000000000000000000000,
'b00111111100011001100110011001101,'b01000000000100110011001100110011,
'b00111111101001100110011001100110,'b00111111000000000000000000000000,
'b00111111101001100110011001100110,'b00111111010011001100110011001101,
'b00111111101001100110011001100110,'b00111111100011001100110011001101,
'b00111111101001100110011001100110,'b00111111101100110011001100110011,
'b00111111101001100110011001100110,'b00111111110110011001100110011010,
'b00111111101001100110011001100110,'b01000000000000000000000000000000,
'b00111111101001100110011001100110,'b01000000000100110011001100110011,
'b00111111110000000000000000000000,'b00111111000000000000000000000000,
'b00111111110000000000000000000000,'b00111111010011001100110011001101,
'b00111111110000000000000000000000,'b00111111100011001100110011001101,
'b00111111110000000000000000000000,'b00111111101100110011001100110011,
'b00111111110000000000000000000000,'b00111111110110011001100110011010,
'b00111111110000000000000000000000,'b01000000000000000000000000000000,
'b00111111110000000000000000000000,'b01000000000100110011001100110011,
'b00111111110110011001100110011010,'b00111111000000000000000000000000,
'b00111111110110011001100110011010,'b00111111010011001100110011001101,
'b00111111110110011001100110011010,'b00111111100011001100110011001101,
'b00111111110110011001100110011010,'b00111111101100110011001100110011,
'b00111111110110011001100110011010,'b00111111110110011001100110011010,
'b00111111110110011001100110011010,'b01000000000000000000000000000000,
'b00111111110110011001100110011010,'b01000000000100110011001100110011,
'b00111111111100110011001100110011,'b00111111000000000000000000000000,
'b00111111111100110011001100110011,'b00111111010011001100110011001101,
'b00111111111100110011001100110011,'b00111111100011001100110011001101,
'b00111111111100110011001100110011,'b00111111101100110011001100110011,
'b00111111111100110011001100110011,'b00111111110110011001100110011010,
'b00111111111100110011001100110011,'b01000000000000000000000000000000,
'b00111111111100110011001100110011,'b01000000000100110011001100110011}; 

    float32 expectedresults[55:0] =  {'b00111111100000000000000000000000,
'b00111111101001100110011001100110,
'b00111111110011001100110011001101,
'b00111111111100110011001100110011,
'b01000000000011001100110011001101,
'b01000000001000000000000000000000,
'b01000000001100110011001100110011,
'b00111111100110011001100110011010,
'b00111111110000000000000000000000,
'b00111111111001100110011001100110,
'b01000000000001100110011001100110,
'b01000000000110011001100110011010,
'b01000000001011001100110011001101,
'b01000000010000000000000000000000,
'b00111111101100110011001100110011,
'b00111111110110011001100110011010,
'b01000000000000000000000000000000,
'b01000000000100110011001100110011,
'b01000000001001100110011001100110,
'b01000000001110011001100110011010,
'b01000000010011001100110011001101,
'b00111111110011001100110011001101,
'b00111111111100110011001100110011,
'b01000000000011001100110011001101,
'b01000000001000000000000000000000,
'b01000000001100110011001100110011,
'b01000000010001100110011001100110,
'b01000000010110011001100110011010,
'b00111111111001100110011001100110,
'b01000000000001100110011001100110,
'b01000000000110011001100110011010,
'b01000000001011001100110011001101,
'b01000000010000000000000000000000,
'b01000000010100110011001100110011,
'b01000000011001100110011001100110,
'b01000000000000000000000000000000,
'b01000000000100110011001100110011,
'b01000000001001100110011001100110,
'b01000000001110011001100110011010,
'b01000000010011001100110011001101,
'b01000000011000000000000000000000,
'b01000000011100110011001100110011,
'b01000000000011001100110011001101,
'b01000000001000000000000000000000,
'b01000000001100110011001100110011,
'b01000000010001100110011001100110,
'b01000000010110011001100110011010,
'b01000000011011001100110011001101,
'b01000000100000000000000000000000,
'b01000000000110011001100110011010,
'b01000000001011001100110011001101,
'b01000000010000000000000000000000,
'b01000000010100110011001100110011,
'b01000000011001100110011001100110,
'b01000000011110011001100110011010,
'b01000000100001100110011001100110}; 

    initial begin
        reset_n = 0; 
        repeat (1)@(posedge clk)
        reset_n = 1; 
        enable = 1; 
        for (int i = 0; i < 56; i++)begin
            idata = inputdata[2*i]; 
            repeat (1)@(posedge clk)
            idata = inputdata[2*i+1]; 
//            wait(data_ready)
            repeat (6)@(posedge clk)
            clk=clk;
            if (odata != expectedresults[i]) begin
                if(odata.sign==expectedresults[i].sign&&odata.exponent==expectedresults[i].exponent&&(odata.significant-expectedresults[i].significant<2||expectedresults[i].significant-odata.significant<2))
                    run_failed=0;
                else begin
                    run_failed=1;
                    failed=1;
                end
                
            end
            $display("%s: Addition of %d and %d resulting in %d instead of %d", run_failed?"FAIL":"PASS", inputdata[2*i],inputdata[2*i+1],odata,expectedresults[i]); 
        end
        if(failed)
            $display("Test failed");
        else
            $display("Test passed");
        repeat (3)@(posedge clk)
        $stop; 
    end

    always
        #5ps clk = ~clk; 

endmodule