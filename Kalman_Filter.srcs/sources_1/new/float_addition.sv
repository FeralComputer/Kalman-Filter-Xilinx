`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 04/29/2020 09:12:09 AM
// Design Name: 
// Module Name: Float_addition
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Adding two floats
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// 
// 
// TODO:
//      Pipeline
//////////////////////////////////////////////////////////////////////////////////
import float32_addition::*;
import float:: * ; 

////Structure for add_significants function to return the sign and significants
//// Probably a better way of doing it
//typedef struct packed {
//    logic sign; 
//    logic [48:0] significant; 
//}resulting_signed_significant; 

////Function msb_search finds the most significant '1' and returns its index
//// input: added_significants is the added significants of two float32s
//// output: int the index of the most significant '1'
//// NOTE: this function could be abstracted more for general purpose
//function automatic int msb_search(input logic [48:0] added_significants); 
//    for (int i = 47; i >= 23; i = i-1)begin:unrolling_normalization
//        if (added_significants[i + 1])begin
//            msb_search = i; 
//            break; 
//        end
//    end
//endfunction

////Function normalize_float normalizes the unnormalized summed significant of two float32s
//// input: larger_mag_number is the float with the largest exponent
//// input: unnormalized_sum is the unnormalized significant sum of the addition of two float32s
//// output: float32 containing the exponent and significant of the sum (not the sign)
//function automatic float32 normalize_float(input float32 larger_mag_number, input logic [48:0] unnormalized_sum); 
//    if (unnormalized_sum == 0)begin
//        normalize_float.exponent = 0; 
//        normalize_float.significant = 0; 
//    end else begin
//        int shift = msb_search(unnormalized_sum); 
////        $display("Shift is %d",shift);
//        normalize_float.exponent = larger_mag_number.exponent + shift-46; 
//        normalize_float.significant = unnormalized_sum[shift - :23]; 
//    end
//endfunction

////Function add_significant_floats takes to float32s and determines the sign and significant values
//// input: larger_mag_number is the float with the largest exponent
//// input: smaller_mag_number is the float with the smaller exponent
//// output: resulting_signed_significant containing the resulting sign and unnormalized significant of the addition
//function automatic resulting_signed_significant add_significants_floats(input float32 larger_mag_number, input float32 smaller_mag_number); 
//// look at sign bit to determine what to add and subtract
//    logic [48:0] equalized_smallest_num =  {1'b1,smaller_mag_number.significant}<<(24-(larger_mag_number.exponent - smaller_mag_number.exponent));
//    if(larger_mag_number.sign) begin
//        // if larger_mag_number is negative
//        if(smaller_mag_number.sign) begin
//            // if both larger_mag_number and smaller_mag_number are negative
//            add_significants_floats={1'b1, equalized_smallest_num + ( {1'b1, larger_mag_number.significant} << (24))}; 
//        end else begin
//            // if larger_mag_number is negative and smaller_mag_number is positive
//            if (( {1'b1, larger_mag_number.significant} << (24)) > equalized_smallest_num)begin
//                // if larger_mag_number is larger than equalized smaller_mag_number
//                add_significants_floats =  {1'b1,({1'b1, larger_mag_number.significant} << (24)) - equalized_smallest_num}; 
//            end
//            else begin
//                // if equalized smaller_mag_number is larger than larger_mag_number
//                add_significants_floats =  {01'b0, equalized_smallest_num - ( {1'b1, larger_mag_number.significant} << (24))}; 
//            end
//        end
//    end
//    else begin
//        // if larger_mag_number is positive
//        if (smaller_mag_number.sign)begin
//            //if smaller_mag_number is negative and larger_mag_number is positive
//            if (( {1'b1, larger_mag_number.significant} << (24)) > equalized_smallest_num)begin
//                // if larger_mag_number is larger than equalized smaller_mag_number
//                add_significants_floats = {1'b0, ( {1'b1,larger_mag_number.significant}<<(24))-equalized_smallest_num};
//            end else begin
//                // if equalized smaller_mag_number is larger than larger_mag_number
//                add_significants_floats={1'b1, equalized_smallest_num - ( {1'b1, larger_mag_number.significant} << (24))}; 
//            end
//        end else begin
//            // if larger_mag_number and smaller_mag_number are positive
//            add_significants_floats = {1'b0, equalized_smallest_num + ( {1'b1,larger_mag_number.significant}<<(24))};
//        end
//    end
//endfunction

////Function add_float32_ordered adds two float32s that are ordered relative to their exponents
//// input: larger_mag_number is a float32 that has a larger exponent value than smaller_mag_number
//// input: smaller_mag_number is a float32 that has a smaller exponent value than larger_mag_number
//// output: float32 containing the result of the addition of larger_mag_number and smaller_mag_number
//function automatic float32 add_float32_ordered(input float32 larger_mag_number, input float32 smaller_mag_number);
//    resulting_signed_significant signed_unnormalized;
//    float32 result;
    
//    // add the significants together and determine the sign
//    signed_unnormalized=add_significants_floats(larger_mag_number,smaller_mag_number);
//    // normalize the resulting significant        
//    result= normalize_float(larger_mag_number,signed_unnormalized.significant);
//    result.sign=signed_unnormalized.sign;
//    add_float32_ordered=result;
//endfunction

////Function add_float32 adds two float32s that are ordered relative to their exponents
//// input: a is a float32 to be added with b
//// input: b is a float32 to be added with a
//// output: float32 containing the result of the addition of a and b
//function automatic float32 add_float32(input float32 a, input float32 b);
//    if (a.exponent>b.exponent)
//        add_float32=add_float32_ordered(a,b);
//    else
//        add_float32=add_float32_ordered(b,a);
//endfunction

module Float_addition(input logic clk, 
                        input float32 idata, 
                        output float32 odata, 
                        output logic data_ready, 
                        input logic reset_n, 
                        input logic enable
                        ); 
    enum {load_a = 0, load_b = 1, send_result = 2}state; 

    float32 a, b, next_result;
        
    always_comb begin
        next_result=add_float32(a,b);
    end

    always_ff @(negedge clk)begin
        if (~reset_n)begin
            odata <= 0; 
            data_ready <= 0; 
            state <= load_a; 
        end
        else if (enable)begin
            case(state)

                load_a:begin 
                    a <= idata; 
                    data_ready <= 0; 
                    state <= load_b; 
                    end

                load_b:begin
                    b <= idata; 
                    state <= send_result; 
                    end

                send_result:begin
                    odata <= next_result; 
                    data_ready <= 1; 
                    state<=load_a;
                end
                
                default: begin
                    odata <= 0; 
                    data_ready <= 0; 
                    state<=load_b;
                end
            endcase
        end
    end
        

    
endmodule