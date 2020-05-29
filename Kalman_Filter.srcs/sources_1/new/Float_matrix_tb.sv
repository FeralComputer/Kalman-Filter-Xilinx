`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2020 12:01:29 PM
// Design Name: 
// Module Name: Float_matrix_tb
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


parameter matrix_array_length=1;
parameter matrix_size=2;

module Float_matrix_tb();

    Float_matrix_manipulation_interface i_bus();
    Float_matrix_manipulation # (matrix_array_length,matrix_size) matrix_pu(i_bus);
    
    float32 b_received='b0, b_expected;
    real f_received=0.0, f_expected;
    
    int received_count=0,x_pos,y_pos,i_pos;
    
    
    
    float32 data_sent [0:matrix_array_length*matrix_size*matrix_size-1]= {$shortrealtobits(1.0),$shortrealtobits(2.0),$shortrealtobits(3.0),$shortrealtobits(4.0)};
    float32 data_received [0:matrix_array_length*matrix_size*matrix_size-1];
    
    initial begin
        i_bus.reset_n = 0;
        i_bus.clk=0;
        repeat (1)@(posedge i_bus.clk)
        i_bus.reset_n = 1; 
        i_bus.enable = 1; 
        i_bus.instruction=i_bus.idle;
        i_bus.idata=$shortrealtobits(-99.0);
        
        repeat (1) @ (posedge i_bus.clk) begin
        end
        
        //load matrices
        i_bus.instruction=i_bus.load_matrix;
        repeat (1)@(posedge i_bus.clk) begin
        end
        i_bus.idata_valid=1;
        for(int i=0;i<matrix_array_length;i+=1) begin
            i_bus.address=i;
            for(int y=0;y<matrix_size;y+=1) begin
                i_bus.yindex=y;
                for(int x=0;x<matrix_size;x+=1) begin
                    i_bus.xindex=x;
                    
                    i_bus.idata=data_sent[y*matrix_size+x];
                    repeat (1) @ (posedge i_bus.clk) begin
                    end
                    if(x==matrix_size-1 && y==matrix_size-1) 
                        i_bus.idata_valid=0;
                    
                    
                end
            end
        end
        i_bus.idata=$shortrealtobits(99.0);
        
        i_bus.instruction=i_bus.idle;

        repeat ($urandom_range(10,0)) @ (posedge i_bus.clk) begin
        end
        
        //read matrices
        i_bus.instruction=i_bus.return_matrix;
        
        //read back matrix
        for(int i=0;i<matrix_array_length;i+=1) begin
            i_bus.address=i;
            for(int y=0;y<matrix_size;y+=1) begin
                i_bus.yindex=y;
                for(int x=0;x<matrix_size;x+=1) begin
                    i_bus.xindex=x;
                    
                    if(i_bus.odata_valid) begin
                        data_received[received_count]=i_bus.odata;
                        received_count+=1;
                    end
                    
                    repeat (1) @ (posedge i_bus.clk) begin
                    end
                    
                end
            end
        end
        
        i_bus.instruction=i_bus.idle;
        
        while(i_bus.odata_valid) begin
            data_received[received_count]=i_bus.odata;
            received_count+=1;
            repeat (1) @ (posedge i_bus.clk) begin
            end            
        end
        
        $display("Count of data received is: %d",received_count);
        
        // evaluate result
        for (int i=0;i<matrix_array_length*matrix_size*matrix_size;i+=1) begin
            f_received=$bitstoshortreal(data_received[i]);
            f_expected=$bitstoshortreal(data_sent[i]);
            i_pos=i/matrix_size/matrix_size;
            y_pos=(i-i_pos)/matrix_size;
            x_pos=(i-i_pos)-y_pos;
            if(f_received==f_expected) begin
                $display("PASS: Matrix %d (%d,%d) was successfully written and read",i_pos,x_pos,y_pos);
            end
            else begin
                $display("FAIL: Matrix %d (%d,%d) failed writing and read test (expected: %f, got: %f)",i_pos,x_pos,y_pos,
                        f_expected,f_received);
            end
        end

        repeat (3)@(posedge i_bus.clk) begin
        end
        $stop; 
    end

    always
        #5ps i_bus.clk = ~i_bus.clk; 

    
endmodule
