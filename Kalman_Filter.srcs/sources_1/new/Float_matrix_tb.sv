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


parameter matrix_array_length=4;
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
                                                                          $shortrealtobits(11.0),$shortrealtobits(12.0),$shortrealtobits(13.0),
                                                                          $shortrealtobits(14.0),$shortrealtobits(15.0),$shortrealtobits(16.0),
                                                                          $shortrealtobits(17.0),$shortrealtobits(18.0),$shortrealtobits(19.0),
                                                                          $shortrealtobits(1.0),$shortrealtobits(0.0),$shortrealtobits(0.0),
                                                                          $shortrealtobits(0.0),$shortrealtobits(1.0),$shortrealtobits(0.0),
                                                                          $shortrealtobits(0.0),$shortrealtobits(0.0),$shortrealtobits(1.0),
                                                                          $shortrealtobits(1.0),$shortrealtobits(0.0),$shortrealtobits(0.0),
                                                                          $shortrealtobits(0.0),$shortrealtobits(1.0),$shortrealtobits(0.0),
                                                                          $shortrealtobits(0.0),$shortrealtobits(0.0),$shortrealtobits(1.0)};
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
                
                #1ps i_bus.xindex=x;
                
                
                
                repeat (1) @ (posedge i_bus.clk) begin
                end
                if(i_bus.odata_valid) begin
                    result_data[count]=i_bus.odata;
                    count+=1;
                end
                
            end
        end
        
        i_bus.instruction=i_bus.idle;
        repeat (1) @ (posedge i_bus.clk);  
        
        while(i_bus.odata_valid) begin
            result_data[count]=i_bus.odata;
            #1ps count+=1;
            repeat (1) @ (posedge i_bus.clk);          
        end
        
    endtask
    
    
    task read_all;
        output float32 result_data [0:matrix_array_length*matrix_size*matrix_size-1];
        output int count;
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
                        result_data[count]=i_bus.odata;
                        count+=1;
                    end
                    
                end
            end
        end
        
        i_bus.instruction=i_bus.idle;
        repeat (1) @ (posedge i_bus.clk);  
        
        while(i_bus.odata_valid) begin
            result_data[count]=i_bus.odata;
            #1ps count+=1;
            repeat (1) @ (posedge i_bus.clk);          
        end
    endtask
    
    task test_all_ram;
        input int count;
        input float32 result_data [0:matrix_array_length*matrix_size*matrix_size-1];
        input float32 send_data [0:matrix_array_length*matrix_size*matrix_size-1];
        input string name;
        string modified_name;

        for(int i=0;i<matrix_array_length;i+=1) begin
            $sformat(modified_name, "%s index %d", name, i);
            read_all(result_data,count);
            compare_matrix(send_data[i*matrix_size*matrix_size+:matrix_size*matrix_size],
            result_data[i*matrix_size*matrix_size+:matrix_size*matrix_size], name);
        end
    endtask
    
    task read_write_matrix;
        input int index;
        input float32 send_data [0:matrix_size*matrix_size-1];
        output float32 result_data [0:matrix_size*matrix_size-1];
        output int count;
        
        #1ps i_bus.instruction = i_bus.read_write;
        count=0;
        i_bus.address=index;
        for(int y=0;y<matrix_size;y+=1) begin
            #1ps i_bus.yindex=y;
            for(int x=0;x<matrix_size;x+=1) begin
                #1ps i_bus.xindex=x;
                i_bus.idata=send_data[y*matrix_size+x];
                repeat (1) @ (posedge i_bus.clk) ;
                if(i_bus.odata_valid) begin
                    result_data[count]=i_bus.odata;
                    count+=1;
                end
                
            end
        end
        
        i_bus.instruction=i_bus.idle;
        repeat (1) @ (posedge i_bus.clk);  
        
        while(i_bus.odata_valid) begin
            result_data[count]=i_bus.odata;
            #1ps count+=1;
            repeat (1) @ (posedge i_bus.clk);          
        end
    endtask
    
    task add_matrix;
        input int index1, index2, index_result;
        #1ps
        i_bus.operator1 = index1;
        i_bus.operator2 = index2;
        i_bus.operator_result = index_result;
        i_bus.instruction = i_bus.add_matrix;
        wait (i_bus.operation_done);
        #1ps 
        i_bus.instruction = i_bus.idle;
    endtask
    
    task compare_matrix;
        input float32 expected [0:matrix_size*matrix_size-1], received [0:matrix_size*matrix_size-1];
        input string name;
        float32 f_received, f_expected;
        int x_pos, y_pos;
        int errors;
        // evaluate result
        errors=0;
        for (int i=0;i<matrix_size*matrix_size;i+=1) begin
            f_received=$bitstoshortreal(received[i]);
            f_expected=$bitstoshortreal(expected[i]);
            y_pos=(i)/matrix_size;
            x_pos=(i)-y_pos*matrix_size;
            if(f_received==f_expected) begin
//                $display("PASS: Index (%d,%d) contains expected value",x_pos,y_pos);
                //pass silently
            end
            else begin
                $display("FAIL: %s (%d,%d) does not contain expected value(expected: %f, got: %f)",name,x_pos,y_pos,
                        f_expected,f_received);
                errors+=1;
            end
        end
        
        if(errors>0) begin
            $error("FAILED: %s has %d errors",name,errors);
        end else begin
            $display("PASS: %s", name);
        end
        
        
    endtask
    
    task add_matricies;
        input int index1, index2, index_result;
        float32 matrix1 [0:matrix_size*matrix_size-1],matrix2 [0:matrix_size*matrix_size-1];
        float32 result_data [0:matrix_size*matrix_size-1], result_expected [0:matrix_size*matrix_size-1];
        int count;
        // get initial values from matricies
        read_matrix(index1, matrix1, count);
        read_matrix(index2, matrix2, count);
        
        //calculate expected result
        for(int y=0;y<matrix_size;y+=1) begin
            for(int x=0;x<matrix_size;x+=1) begin
                result_expected[y*matrix_size + x] = $shortrealtobits($bitstoshortreal(matrix1[y*matrix_size + x]) + 
                                                        $bitstoshortreal(matrix2[y*matrix_size + x]));
            end
        end
        
        //add the matricies
        add_matrix(index1, index2, index_result);
        
        //read result
        read_matrix(index_result, result_data, count);
        
        //compare results
        compare_matrix(result_expected,result_data,"add matricies");
        
    endtask
    
    task multiply_matrix;
        input int index1, index2, index_result;
        #1ps
        i_bus.operator1 = index1;
        i_bus.operator2 = index2;
        i_bus.operator_result = index_result;
        i_bus.instruction = i_bus.multiply_matrix;
        wait (i_bus.operation_done);
        #1ps 
        i_bus.instruction = i_bus.idle;
    endtask
    
    task multiply_matricies;
        input int index1, index2, index_result;
        float32 matrix1 [0:matrix_size*matrix_size-1],matrix2 [0:matrix_size*matrix_size-1];
        float32 result_data [0:matrix_size*matrix_size-1], result_expected [0:matrix_size*matrix_size-1];
        int count;
        string modified_name;
        float32 sum;
        // get initial values from matricies  
        read_matrix(index1, matrix1, count); 
        read_matrix(index2, matrix2, count);
        
        //calculate expected result
        for(int y=0;y<matrix_size;y+=1) begin
            for(int x=0;x<matrix_size;x+=1) begin
                sum = 0;
                for(int i = 0 ; i < matrix_size; i+=1) begin
                    sum += $shortrealtobits($bitstoshortreal(matrix1[y*matrix_size + i]) *
                                                         $bitstoshortreal(matrix2[(i)*matrix_size + x]));
                    $display("sum is %f: m1(%d)*m2(%d)",$bitstoshortreal(sum),i+y*matrix_size,x+i*matrix_size);
                end
                result_expected[y*matrix_size + x] = sum;
            end
        end
        
        //multiply the matricies
//        multiply_matrix(index1, index2, index_result);
        
        //read result
        read_matrix(index_result, result_data, count);
        
        //compare results
        $sformat(modified_name, "%s index %d", "Mult matrix", index_result);
        compare_matrix(result_expected,result_data,modified_name);
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
        
        test_all_ram(received_count,data_received,data_sent, "testing read write");
        
        // wait a random amount of time
        repeat ($urandom_range(10,0)) @ (posedge i_bus.clk) begin
        end
        
        multiply_matricies(0,2,3);
        
        // wait a random amount of time
        repeat ($urandom_range(10,0)) @ (posedge i_bus.clk) begin
        end
        
//        add_matrix(0,2,2); 
        
        // wait a random amount of time
        repeat ($urandom_range(10,0)) @ (posedge i_bus.clk) begin
        end
        
//        add_matrix(0,2,2);
        
        //read all
//        read_all(data_received,received_count);   
        repeat (3)@(posedge i_bus.clk) ;
        
        repeat (3)@(posedge i_bus.clk) ;
        
        $stop; 
    end

    always
        #5ps i_bus.clk = ~i_bus.clk; 

    
endmodule
