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

    logic clk = 0, reset_n = 0, enable = 0, data_ready; 
    float32 idata, odata, expected; 
    Float_addition adder(clk, idata, odata, data_ready, reset_n, enable); 
    int failed = 0,number_of_tests=0; 
    logic run_failed = 0; 
    shortreal ij = 0; 

    initial begin
        reset_n = 0; 
        repeat (1)@(posedge clk)
        reset_n = 1; 
        enable = 1; 
        for (shortreal i = -10; i < 10; i += 0.31456)begin
            for (shortreal j = -10; j < 10; j += 0.645156)begin
                number_of_tests=number_of_tests+1;
                idata = $shortrealtobits(i); 
                repeat (1)@(posedge clk)
                idata = $shortrealtobits(j); 
                ij = i + j; 
                expected= $shortrealtobits(ij);
    //            wait(data_ready)
                repeat (2)@(posedge clk)
                clk = clk; 
                
                if ($bitstoshortreal(odata) - (ij) >= 0.001 || 
                    (ij) - $bitstoshortreal(odata) >= 0.001)begin
                        run_failed = 1; 
                        failed = failed + 1; 
//                        Only dispays the failed tests
                        $display("%s: %d Addition of %f and %f resulting in %f instead of %f with an error of %f", run_failed?"FAIL":"PASS", i, 
                (i), (j), $bitstoshortreal(odata), (ij), $bitstoshortreal(odata) - (ij)); 
                end else
                    run_failed = 0; 
            end
        end
        
        
        if (failed)
            $display("Test failed with %d failures out of %d tests", failed,number_of_tests); 
        else
            $display("Test passed | Number of Tests: %d", number_of_tests); 
        repeat (3)@(posedge clk)
        $stop; 
    end

    always
        #5ps clk = ~clk; 

endmodule