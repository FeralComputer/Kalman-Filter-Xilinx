`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 10:44:52 AM
// Design Name: 
// Module Name: Float_MAC_tb
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Tests the multiplication of two float32s
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float:: * ; 

module Float_MAC_tb(); 

    logic clk = 0, reset_n = 0, enable = 0, request_result_and_reset=0,result_ready,idata_valid=0; 
    float32 a, b, result, expected; 
    MAC mac(a, b, result, clk, reset_n, enable, request_result_and_reset,idata_valid, result_ready);
    int failed = 0,number_of_tests=0, wait_cycles; 
    logic run_failed = 0; 
    shortreal ij = 0; 
    shortreal i_max=10, i_increment=0.31456;
    shortreal j_max=10, j_increment=0.645156;
    
    

    initial begin
        reset_n = 0; 
        repeat (2)@(posedge clk) begin
        end
        reset_n = 1; 
        enable = 1; 
        
        
        for(int k=0;k<30;k=k+1) begin
            i_increment=$itor($urandom_range(1000000,100000))/1000000.0;//create random itterator with a range between 0.1 and 1
            j_increment=$itor($urandom_range(1000000,100000))/1000000.0;
            number_of_tests=number_of_tests+1;
            ij=0;
            idata_valid=1;
            //randomish data going into one mac (error is on the order of 0.1
            for (shortreal i = -10; i < i_max; i += i_increment)begin
                
                for (shortreal j = -10; j < j_max; j += j_increment)begin
                    
                    a = $shortrealtobits(i); 
                    b = $shortrealtobits(j); 
                    ij = ij + i * j;
                    expected= $shortrealtobits(ij);
                    wait_cycles=$urandom_range(3,1);
                    //allow delays in new data testing
                    if(wait_cycles>0) begin
                        idata_valid=0;
                        repeat(wait_cycles-1)@(posedge clk) begin
                        end
                        idata_valid=1;
                    end 
                    repeat (1)@(posedge clk) begin
                    end
                    
                end
            end
            
            request_result_and_reset=1;

            repeat (1)@(posedge clk) begin
            end
            
            request_result_and_reset=0;
            
    
            wait (result_ready==1) begin
            end
          
            if ($bitstoshortreal(result) - (ij) >= 0.1 || 
                (ij) - $bitstoshortreal(result) >= 0.1)begin
                    run_failed = 1; 
                    failed = failed + 1; 
    //                        Only dispays the failed tests
                    $display("%s: MAC resulting in %f instead of %f with an error of %f", run_failed?"FAIL":"PASS", $bitstoshortreal(result), (ij), $bitstoshortreal(result) - (ij)); 
            end else
                run_failed = 0; 
        end
    
        if (failed) begin
                $display("Test failed with %d failures out of %d tests", failed,number_of_tests); 
        end else
            $display("Test passed | Number of Tests: %d", number_of_tests); 
        repeat (3)@(posedge clk) begin
        end
        $stop; 
    end

    always
        #5ps clk = ~clk; 

endmodule
