`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries   
// Engineer: Kevin Heyer
// 
// Create Date: 05/08/2020 01:37:51 PM
// Design Name: 
// Module Name: float32_addition
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: functions required for float32 multiplication
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package float32_multiplication;
    import float:: * ; 
    
    //Function msb_search finds the most significant '1' and returns its index
        // input: added_significants is the added significants of two float32s
        // output: int the index of the most significant '1'
        // NOTE: this function could be abstracted more for general purpose
    function automatic int msb_search(input logic [50:0] added_significants); 
        for (int i = 49; i >= 26; i = i-1)begin:unrolling_normalization
            if (added_significants[i + 1])begin
//                $display("msb_search value %d",i);
                msb_search = i; 
                break; 
            end
        end
    endfunction
    
    function automatic float32 multiply_float32(input float32 a, input float32 b);
        logic [50:0] resultant;
        float32 result;
        logic [7:0] shift;
        //multiply significants
        resultant={1'b1,a.significant}*{1'b1,b.significant};
        //normalize resultant
        shift=msb_search(resultant);
        //calculate normalized significant
        result.significant=resultant[shift-:23];
        //calculate exponents
        result.exponent=a.exponent+b.exponent-127+(shift-45);
        //determine sign
        result.sign=a.sign^b.sign;
        //return result
        multiply_float32=result;
    
    endfunction
endpackage