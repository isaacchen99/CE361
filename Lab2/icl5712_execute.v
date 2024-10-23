/*
  
  Northwestern University
  CompEng361 - Fall 2024
  Lab 2
  
  Name: Isaac Chen
  NetID: icl5712
  
  */
  
module ExecutionUnit(
		     output [31:0] out,
		     input [31:0]  opA,
		     input [31:0]  opB,
		     input [2:0]   func,
		     input [6:0]   auxFunc);
   
   assign out = 
   (func == 3'b000 && auxFunc == 7'b0000000) ? opA + opB :  // add
   (func == 3'b000 && auxFunc == 7'b0100000) ? opA - opB :  // subtract
   (func == 3'b001) ? opA << opB[4:0] : // sll
   (func == 3'b010) ? ( ($signed(opA) < $signed(opB)) ? 1 : 0 ) : // slt
   (func == 3'b011) ? (opA < opB) ? 1 : 0 : // sltu
   (func == 3'b100) ? opA ^ opB : // xor
   (func == 3'b101 && auxFunc == 7'b0000000) ? opA >> opB[4:0] : // srl
   (func == 3'b101 && auxFunc == 7'b0100000) ? $signed(opA) >>> opB[4:0] :  //sra
   (func == 3'b110) ? opA | opB : // or
   (func == 3'b111) ? opA & opB : // and
   0;
   
endmodule // ExecutionUnit