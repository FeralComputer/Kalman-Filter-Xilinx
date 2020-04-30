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
import float:: * ; 
module Float_addition(input logic clk, 
                        input float32 idata, 
                        output float32 odata, 
                        output logic data_ready, 
                        input logic reset_n, 
                        output logic enable
                        ); 
    enum {load_a = 0, load_b = 1, calculate_delta_exponent = 2, equalize_exponent = 3, add_significants = 4, normalize = 5, send_result = 6}state; 
    
    enum {anegbneg,anegbpos,aposbneg,aposbpos,aposbnegagreat,anegbposagreat,aposbnegbgreat,anegbposbgreat} logicstate;

    float32 a, b, result; 
    logic [7:0] delta_exponent; 
    logic [48:0] equalized_smallest_num=0; 
//    genvar i;
        
    always_comb begin
        
    end

    always_ff @(negedge clk)begin
        if (~reset_n)begin
            result <= 0; 
            data_ready <= 0; 
            state<=load_a;
        end
        else if (enable)begin
            case(state)

                load_a:begin 
                    a <= idata; 
                    data_ready <= 0; 
                    state<=load_b;
                    end

                load_b: begin
                    if (idata.exponent>a.exponent) begin
                        a<=idata;
                        b<=a;
                    end
                    else
                        b <= idata; 
                    state<=calculate_delta_exponent;
                    end

                calculate_delta_exponent: begin
                    delta_exponent<=a.exponent-b.exponent;
                    state<=equalize_exponent;
                end

                equalize_exponent:begin
                    equalized_smallest_num<={1'b1,b.significant}<<(24-delta_exponent);
                    state<=add_significants;
                end

                add_significants:begin
                // look at sign bit to determine what to add and subtract
                    if(a.sign) begin
                        // if a is negative
                        if(b.sign) begin
                            // if both a and b are negative
                            equalized_smallest_num<=equalized_smallest_num+({1'b1,a.significant}<<(24));
                            result.sign<=1;
                            logicstate<=anegbneg;
                        end else begin
                            // if a is negative and b is positive
                            if (({1'b1,a.significant}<<(24))>equalized_smallest_num) begin
                                // if a is larger than equalized b
                                result.sign<=1;
                                equalized_smallest_num<=({1'b1,a.significant}<<(24))-equalized_smallest_num;
                                logicstate<=anegbposagreat;
                            end
                            else begin
                                // if equalized b is larger than a
                                result.sign<=0;
                                equalized_smallest_num<=equalized_smallest_num-({1'b1,a.significant}<<(24));
                                logicstate<=anegbposbgreat;
                            end
                        end
                    end
                    else begin
                        // if a is positive
                        if(b.sign) begin
                            //if b is negative and a is positive
                            if ( ({1'b1,a.significant}<<(24))>equalized_smallest_num ) begin
                                // if a is larger than equalized b
                                result.sign<=0;
                                equalized_smallest_num<=({1'b1,a.significant}<<(24))-equalized_smallest_num;
                                logicstate<=aposbnegagreat;
                            end else begin
                                // if equalized b is larger than a
                                result.sign<=1;
                                equalized_smallest_num<=equalized_smallest_num-({1'b1,a.significant}<<(24));
                                logicstate<=aposbnegbgreat;
                            end
                        end else begin
                            // if a and b are positive
                            equalized_smallest_num<=equalized_smallest_num+({1'b1,a.significant}<<(24));
                            result.sign<=0;
                            logicstate<=aposbpos;
                        end
                        // 
                    end
//                    equalized_smallest_num<=equalized_smallest_num+{1'b1,a.significant};
                    state<=normalize;
                end
                
                normalize:begin
//                    if (equalized_smallest_num[24]) begin
////                         if the sum overflowed the originial  
//                        result.exponent<=a.exponent+1;
//                        result.significant<={equalized_smallest_num[23:1]};
//                    end else if (equalized_smallest_num[23]) begin
////                        if the sums normalization didnt change
//                        result.exponent<=a.exponent;
//                        result.significant<=equalized_smallest_num[22:0];
//                    end else if (equalized_smallest_num==0) begin
////                        if the sum equals zero
//                        result.exponent<=0;
//                        result.siginificant<=0;
//                    end else begin
////                        if the sum decreased
//                        result.exponent<=a.exponent-1;
//                        result.significant<={equalized_smallest_num[21:0],1'b0};
//                    end
                    if (equalized_smallest_num==0) begin
                        result.exponent<=0;
                        result.significant<=0;
                        $display("result is zero");
                    end else begin
                        for (int i=47;i>=47-24;i--) begin
                            if(equalized_smallest_num[i+1]) begin
                                $display("i is: %d",i);
                                result.exponent<=a.exponent+(i-46);
                                result.significant<=equalized_smallest_num[i-:23];
                                i=0;
                            end
                        end
                    end
                state<=send_result;

                end

                send_result:begin
                    odata <= result; 
                    data_ready <= 1; 
                    state<=load_a;
                end
                
                default: begin
                    result <= 0; 
                    data_ready <= 0; 
                    state<=load_b;
                end
            endcase
        end
    end
        

    
endmodule