//package float_matrix;
import float:: * ; 
parameter N=2;
typedef struct{ 
    float32 [N-1:0][N-1:0] matrix; 
}float32_matrix;

//interface float32_matrix #(MATRIX_SIZE=2)();
//    float32 [MATRIX_SIZE-1:0][MATRIX_SIZE-1:0] matrix;
//endinterface

interface float32_matrix_array #(MATRIX_COUNT = 2, MATRIX_SIZE = 2)(); 
    float32_matrix #(MATRIX_SIZE)array;//[MATRIX_COUNT-1:0]; 
endinterface
//endpackage