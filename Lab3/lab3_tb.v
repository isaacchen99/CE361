`define WORD_WIDTH 32
`define NUM_REGS 32
`define OPCODE_COMPUTE    7'b0110011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_LOAD       7'b0000011
`define OPCODE_STORE      7'b0100011 
`define OPCODE_IMMEDIATE  7'b0010011
`define OPCODE_JAL        7'b1101111
`define OPCODE_JALR       7'b1100111
`define OPCODE_LUI        7'b0110111
`define OPCODE_AUIPC      7'b0010111
`define FUNC_ADD          3'b000
`define FUNC_SUB          3'b000
`define FUNC_AND          3'b111
`define FUNC_OR           3'b110
`define FUNC_XOR          3'b100
`define FUNC_SLL          3'b001
`define FUNC_SRL          3'b101
`define FUNC_SRA          3'b101
`define AUX_FUNC_ADD      7'b0000000
`define AUX_FUNC_SUB      7'b0100000
`define AUX_FUNC_SRL      7'b0000000
`define AUX_FUNC_SRA      7'b0100000
`define AUX_FUNC_MUL_DIV  7'b0000001
`define SIZE_BYTE         2'b00
`define SIZE_HWORD        2'b01
`define SIZE_WORD         2'b10

`timescale 1ns/1ps

module lab3_tb;

  // Inputs
  reg [31:0] opA;
  reg [31:0] opB;
  reg [31:0] PC;
  reg [6:0] opCode;
  reg [2:0] func;
  reg [6:0] auxFunc;
  reg [11:0] imm;
  reg [19:0] imm20;

  // Output
  wire [31:0] out;

  // Instantiate the ExecutionUnit module (now in lab3.v)
  ExecutionUnit uut (
    .opA(opA), 
    .opB(opB), 
    .PC(PC), 
    .opCode(opCode), 
    .func(func), 
    .auxFunc(auxFunc), 
    .imm(imm), 
    .imm20(imm20), 
    .out(out)
  );

  initial begin
    // Initialize inputs
    PC = 32'd0;
    imm = 12'd0;
    imm20 = 20'd0;

    // Test cases for division and remainder operations
    opCode = `OPCODE_COMPUTE;
    func = 3'b100;           // DIV operation
    auxFunc = `AUX_FUNC_MUL_DIV;
    opA = 32'd100;
    opB = 32'd10;
    #10;
    $display("DIV: opA = %d, opB = %d, out = %d", opA, opB, out);

    func = 3'b100;
    opA = 32'd200;
    opB = 32'd20;
    #10;
    $display("DIVU: opA = %d, opB = %d, out = %d", opA, opB, out);

    func = 3'b100;
    opA = 32'd35;
    opB = 32'd6;
    #10;
    $display("REM: opA = %d, opB = %d, out = %d", opA, opB, out);

    func = 3'b100;
    opA = 32'd35;
    opB = 32'd6;
    #10;
    $display("REMU: opA = %d, opB = %d, out = %d", opA, opB, out);

    // Division by zero cases
    opA = 32'd100;
    opB = 32'd0;
    func = 3'b100;  // DIV
    #10;
    $display("DIV by zero: opA = %d, opB = %d, out = %h", opA, opB, out);

    func = 3'b100;  // DIV
    opA = 32'd50;
    opB = 32'd0;
    #10;
    $display("DIVU by zero: opA = %d, opB = %d, out = %h", opA, opB, out);

    func = 3'b100;  // DIV
    opA = 32'd35;
    opB = 32'd0;
    #10;
    $display("REM by zero: opA = %d, opB = %d, out = %h", opA, opB, out);

    func = 3'b100;  // REMU
    opA = 32'd35;
    opB = 32'd3;
    #10;
    $display("REMU by zero: opA = %d, opB = %d, out = %h", opA, opB, out);

    $finish;
  end

endmodule
