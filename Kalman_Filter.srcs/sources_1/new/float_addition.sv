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
//      After loads move largest number to a and remove all the extra if else statements
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

    float32 a, b, result; 
    logic [7:0] delta_exponent; 
    logic [25:0] equalized_smallest_num; 
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
                    b <= idata; 
                    state<=calculate_delta_exponent;
                    end

                calculate_delta_exponent: begin
                    if (a.exponent>b.exponent)
                        delta_exponent<=a.exponent-b.exponent;
                    else
                        delta_exponent<=b.exponent-a.exponent;
                    state<=equalize_exponent;
                end

                equalize_exponent:begin
                    if (a.exponent>b.exponent)
                        equalized_smallest_num<={1'b1,b.significant}>>delta_exponent;
                    else
                        equalized_smallest_num<={1'b1,a.significant}>>delta_exponent;
                    state<=add_significants;
                end

                add_significants:begin
                    if (a.exponent>b.exponent)
                        equalized_smallest_num<=equalized_smallest_num+{1'b1,a.significant};
                    else
                        equalized_smallest_num<=equalized_smallest_num+{1'b1,b.significant};
                    state<=normalize;
                end
                
                normalize:begin
                    if (equalized_smallest_num[24]) begin
                        if (a.exponent>b.exponent)
                            result.exponent<=a.exponent+1;
                        else
                            result.exponent<=b.exponent+1;
                        result.significant<={equalized_smallest_num[23:1]};
                    end
                    else begin
                        if (a.exponent>b.exponent)
                            result.exponent<=a.exponent;
                        else
                            result.exponent<=b.exponent;
                        result.significant<=equalized_smallest_num[22:0];
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