`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Heyer Industries
// Engineer: Kevin Heyer
// 
// Create Date: 05/14/2020 12:01:29 PM
// Design Name: 
// Module Name: Float_matrix_tb
// Project Name: Kalman Filter
// Target Devices: 
// Tool Versions: 
// Description: Tests out the load, read, add, multiply, and transpose features of
//              the float_matrix_manipulation module.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import float::*;


parameter matrix_array_length=2;
parameter matrix_size=3;
//Module Float_matrix_tb tests float_matrix_manipulation module
// 
// NOTE: this tb and most other tb's can be improved by moving each section out of the module,
//       and increasing the abstraction. The matrix data could also be loaded from a file.
module Float_matrix_tb();

    Float_matrix_manipulation_interface i_bus();
    Float_matrix_manipulation # (matrix_array_length,matrix_size) matrix_pu(i_bus);
    
    float32 b_received='b0, b_expected;
    real f_received=0.0, f_expected;
    
    int received_count=0,x_pos,y_pos,i_pos;
    
    
    
    float32 data_sent [0:matrix_array_length*matrix_size*matrix_size-1]= {$shortrealtobits(1.0),$shortrealtobits(2.0),$shortrealtobits(3.0),
                                                                          $shortrealtobits(4.0),$shortrealtobits(5.0),$shortrealtobits(6.0),
                                                                          $shortrealtobits(7.0),$shortrealtobits(8.0),$shortrealtobits(9.0),
                                                                          $shortrealtobits(10.0),$shortrealtobits(12.0),$shortrealtobits(13.0),
                                                                          $shortrealtobits(14.0),$shortrealtobits(15.0),$shortrealtobits(16.0),
                                                                          $shortrealtobits(17.0),$shortrealtobits(18.0),$shortrealtobits(19.0)};
    float32 data_received [0:matrix_array_length*matrix_size*matrix_size-1];
    
    task load_data;
        input float32 send_data [0:matrix_size*matrix_size-1];
    
        #1ps i_bus.instruction=i_bus.load_matrix;
//        repeat (1)@(posedge i_bus.clk) begin
//        end
        i_bus.idata_valid=1;
        
        for(int y=0;y<matrix_size;y+=1) begin
            #1ps i_bus.yindex=y;
            for(int x=0;x<matrix_size;x+=1) begin
                #2ps i_bus.xindex=x;
                
                i_bus.idata=send_data[y*matrix_size+x];
                repeat (1) @ (posedge i_bus.clk) begin
                end
                if(x==matrix_size-1 && y==matrix_size-1) 
                    i_bus.idata_valid=0;
                
                
            end
        end

        // check if data is being written when not supposed to
        #1ps i_bus.idata=$shortrealtobits(99.0);
        
        i_bus.instruction=i_bus.idle;
    
    
    endtask
    
    task load_all;
        input float32 send_data[0:matrix_array_length*matrix_size*matrix_size-1];
        for(int i=0; i<matrix_array_length;i+=1) begin
            i_bus.address=i;
            load_data(send_data[i*matrix_size*matrix_size+:matrix_size*matrix_size]);
        end
    endtask
    
    task read_matrix;
        input int index;
        output float32 result_data [0:matrix_size*matrix_size-1];
        output int count;
        //read matrices
        #1ps i_bus.instruction=i_bus.return_matrix;
        count=0;
        i_bus.address=index;
        
        for(int y=0;y<matrix_size;y+=1) begin
            #1ps i_bus.yindex=y;
            for(int x=0;x<matrix_size;x+=1) begin
                #3ps i_bus.xindex=x;
                
                if(i_bus.odata_valid) begin
                    result_data[count]=i_bus.odata;
                    count+=1;
                end
                
                repeat (1) @ (posedge i_bus.clk) begin
                end
                
            end
        end
        
        i_bus.instruction=i_bus.idle;
        
        while(i_bus.odata_valid) begin
            #3ps result_data[count]=i_bus.odata;
            count+=1;
            repeat (1) @ (posedge i_bus.clk) begin
            end            
        end
        
    endtask
    
    
    task read_all;
        output float32 result_data [0:matrix_array_length*matrix_size*matrix_size-1];
        output int count;
        //read matrices
        #1ps i_bus.instruction=i_bus.return_matrix;
        count=0;
        //read back matrix
        for(int i=0;i<matrix_array_length;i+=1) begin
            i_bus.address=i;
            for(int y=0;y<matrix_size;y+=1) begin
                i_bus.yindex=y;
                for(int x=0;x<matrix_size;x+=1) begin
                    #3ps i_bus.xindex=x;
                    
                    if(i_bus.odata_valid) begin
                        result_data[count]=i_bus.odata;
                        count+=1;
                    end
                    
                    repeat (1) @ (posedge i_bus.clk) begin
                    end
                    
                end
            end
        end
        
        i_bus.instruction=i_bus.idle;
        
        while(i_bus.odata_valid) begin
            #3ps result_data[count]=i_bus.odata;
            count+=1;
            repeat (1) @ (posedge i_bus.clk) begin
            end            
        end
    endtask
    
    task test_data;
        input int count;
        input float32 result_data [0:matrix_array_length*matrix_size*matrix_size-1];
        input float32 send_data [0:matrix_array_length*matrix_size*matrix_size-1];
        // this is an indicator if extra bits are being read or not
        if(count==matrix_array_length*matrix_size*matrix_size)
            $display("Count of data received is: %d as expected",count);
        else
            $display("FAIL: Count of data received is: %d and should have been: %d",count,matrix_array_length*matrix_size*matrix_size);
        
        
        // evaluate result
        for (int i=0;i<matrix_array_length*matrix_size*matrix_size;i+=1) begin
            f_received=$bitstoshortreal(result_data[i]);
            f_expected=$bitstoshortreal(send_data[i]);
            i_pos=i/matrix_size/matrix_size;
            y_pos=(i-i_pos*matrix_size*matrix_size)/matrix_size;
            x_pos=(i-i_pos*matrix_size*matrix_size)-y_pos*matrix_size;
            if(f_received==f_expected) begin
                $display("PASS: Matrix %d (%d,%d) was successfully written and read",i_pos,x_pos,y_pos);
            end
            else begin
                $display("FAIL: Matrix %d (%d,%d) failed writing and read test (expected: %f, got: %f)",i_pos,x_pos,y_pos,
                        f_expected,f_received);
            end
        end
    endtask
    
    
    
    initial begin
        i_bus.reset_n = 0;
        i_bus.clk=0;
        repeat (2)@(posedge i_bus.clk) begin
        end
        i_bus.reset_n = 1; 
        i_bus.enable = 1; 
        i_bus.instruction=i_bus.idle;
        i_bus.idata=$shortrealtobits(-99.0);
        
        repeat (1) @ (posedge i_bus.clk) begin
        end
        
        //load all
        load_all(data_sent);
        
        // wait a random amount of time
        repeat ($urandom_range(10,0)) @ (posedge i_bus.clk) begin
        end
        
        //read all
//        read_all(data_received,received_count);
        #1ps i_bus.instruction=i_bus.return_matrix;
        received_count=0;
        //read back matrix
        for(int i=0;i<matrix_array_length;i+=1) begin
            #1ps i_bus.address=i;
            for(int y=0;y<matrix_size;y+=1) begin
                #1ps i_bus.yindex=y;
                for(int x=0;x<matrix_size;x+=1) begin
                    
                    #1ps i_bus.xindex=x;
                    
                    
                    
                    repeat (1) @ (posedge i_bus.clk) begin
                    end
                    if(i_bus.odata_valid) begin
                        data_received[received_count]=i_bus.odata;
                        received_count+=1;
                    end
                    
                end
            end
        end
        
        i_bus.instruction=i_bus.idle;
        repeat (1) @ (posedge i_bus.clk);  
        
        while(i_bus.odata_valid) begin
            data_received[received_count]=i_bus.odata;
            #1ps received_count+=1;
            repeat (1) @ (posedge i_bus.clk);          
        end
     
        //compare sent and received
        test_data(received_count,data_received,data_sent);

        repeat (3)@(posedge i_bus.clk) begin
        end
        $stop; 
    end

    always
        #5ps i_bus.clk = ~i_bus.clk; 

    
endmodule
