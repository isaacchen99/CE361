//Groupname: Isaac Hao
//NetIDs: icl5712, 

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

module SingleCycleCPU(halt, clk, rst);
  output halt;
  input clk, rst;

  wire [`WORD_WIDTH-1:0] PC, InstWord;
  wire [`WORD_WIDTH-1:0] DataAddr, StoreData, DataWord;
  wire [1:0] MemSize;
  wire MemWrEn;

  wire [4:0] Rsrc1, Rsrc2, Rdst;
  wire [`WORD_WIDTH-1:0] Rdata1, Rdata2, RWrdata;
  wire RWrEn;

  wire [`WORD_WIDTH-1:0] NPC, PC_Plus_4;
  wire [6:0] opcode;
  wire [6:0] funct7;
  wire [2:0] funct3;

  wire invalid_op;
  wire branch_taken;

  // Halt if invalid operation
  assign halt = invalid_op;
  assign invalid_op = !(opcode == `OPCODE_COMPUTE || opcode == `OPCODE_BRANCH ||
                        opcode == `OPCODE_LOAD || opcode == `OPCODE_STORE ||
                        opcode == `OPCODE_IMMEDIATE || opcode == `OPCODE_JAL ||
                        opcode == `OPCODE_JALR || opcode == `OPCODE_LUI || opcode == `OPCODE_AUIPC);
  
  // System State 
  Mem MEM(.InstAddr(PC), .InstOut(InstWord), 
          .DataAddr(DataAddr), .DataSize(MemSize), .DataIn(StoreData), .DataOut(DataWord), .WE(MemWrEn), .CLK(clk));

  RegFile RF(.AddrA(Rsrc1), .DataOutA(Rdata1), 
             .AddrB(Rsrc2), .DataOutB(Rdata2), 
             .AddrW(Rdst), .DataInW(RWrdata), .WenW(RWrEn), .CLK(clk));

  Reg PC_REG(.Din(NPC), .Qout(PC), .WE(1'b1), .CLK(clk), .RST(rst));

  // Instruction Decode
  assign opcode = InstWord[6:0];   
  assign Rdst = InstWord[11:7]; 
  assign Rsrc1 = InstWord[19:15]; 
  assign Rsrc2 = InstWord[24:20];
  assign funct3 = InstWord[14:12];
  assign funct7 = InstWord[31:25];

  // Branch Condition Logic in SingleCycleCPU
  assign branch_taken = (opcode == `OPCODE_BRANCH) && (
    (funct3 == 3'b000 && Rdata1 == Rdata2) ||           // beq
    (funct3 == 3'b001 && Rdata1 != Rdata2) ||           // bne
    (funct3 == 3'b100 && $signed(Rdata1) < $signed(Rdata2)) || // blt
    (funct3 == 3'b101 && $signed(Rdata1) >= $signed(Rdata2)) || // bge
    (funct3 == 3'b110 && Rdata1 < Rdata2) ||            // bltu
    (funct3 == 3'b111 && Rdata1 >= Rdata2)              // bgeu
  );

  // Program Counter Update Logic
  assign PC_Plus_4 = PC + 4;
  wire [`WORD_WIDTH-1:0] branch_target = PC + {{19{InstWord[31]}}, InstWord[7], InstWord[30:25], InstWord[11:8], 1'b0}; // Branch offset
  wire [`WORD_WIDTH-1:0] jal_target = PC + {{12{InstWord[31]}}, InstWord[19:12], InstWord[20], InstWord[30:21], 1'b0};  // JAL offset
  wire [`WORD_WIDTH-1:0] jalr_target = (Rdata1 + {{20{InstWord[31]}}, InstWord[31:20]}) & ~32'b1; // JALR target with LSB masked

  assign NPC = (opcode == `OPCODE_JAL) ? jal_target : 
               (opcode == `OPCODE_JALR) ? jalr_target : 
               (opcode == `OPCODE_BRANCH && branch_taken) ? branch_target : 
               PC_Plus_4;

  // Memory Write Enable and Size
  assign MemWrEn = (opcode == `OPCODE_STORE);
  assign MemSize = (funct3 == 3'b000) ? `SIZE_BYTE :
                   (funct3 == 3'b001) ? `SIZE_HWORD :
                   (funct3 == 3'b010) ? `SIZE_WORD :
                   (funct3 == 3'b100) ? `SIZE_BYTE : 
                   (funct3 == 3'b101) ? `SIZE_HWORD : 2'bXX;

  // Register Write Enable
  assign RWrEn = (opcode == `OPCODE_COMPUTE || opcode == `OPCODE_IMMEDIATE || 
                  opcode == `OPCODE_LOAD || opcode == `OPCODE_LUI || opcode == `OPCODE_AUIPC ||
                  opcode == `OPCODE_JAL || opcode == `OPCODE_JALR);

  // Execution Unit
  ExecutionUnit EU(
    .out(RWrdata), 
    .opA(Rdata1), 
    .opB(Rdata2), 
    .PC(PC),
    .opCode(opcode),
    .func(funct3), 
    .auxFunc(funct7),
    .imm(InstWord[31:20]), 
    .imm20(InstWord[31:12])
  );

endmodule // SingleCycleCPU

module ExecutionUnit(
  input wire[31:0] opA, 
  input wire[31:0] opB, 
  input wire[31:0] PC,
  input wire[6:0] opCode,
  input wire[2:0] func,
  input wire[6:0] auxFunc,
  input wire[11:0] imm,
  input wire[19:0] imm20,

  output wire[31:0] out
);

  // compute operations
  wire [`WORD_WIDTH-1:0] computeRes;
  wire [`WORD_WIDTH-1:0] signedOpA = $signed(opA);
  wire [`WORD_WIDTH-1:0] signedOpB = $signed(opB);
  assign computeRes = 
    // traditional operations
    (func == 3'b000 && auxFunc == `AUX_FUNC_ADD) ? opA + opB :  // add
    (func == 3'b000 && auxFunc == `AUX_FUNC_SUB) ? opA - opB :  // sub
    (func == 3'b001 && auxFunc != `AUX_FUNC_MUL_DIV) ? opA << opB[4:0] : // sll
    (func == 3'b010 && auxFunc != `AUX_FUNC_MUL_DIV) ? ( ($signed(opA) < $signed(opB)) ? 1 : 0 ) : // slt
    (func == 3'b011 && auxFunc != `AUX_FUNC_MUL_DIV) ? (opA < opB) ? 1 : 0 : // sltu
    (func == 3'b100 && auxFunc != `AUX_FUNC_MUL_DIV) ? opA ^ opB : // xor
    (func == 3'b101 && auxFunc == `AUX_FUNC_SRL) ? opA >> opB[4:0] : // srl
    (func == 3'b101 && auxFunc == `AUX_FUNC_SRA) ? $signed(opA) >>> opB[4:0] :  //sra
    (func == 3'b110 && auxFunc != `AUX_FUNC_MUL_DIV) ? opA | opB : // or
    (func == 3'b111 && auxFunc != `AUX_FUNC_MUL_DIV) ? opA & opB : // and
    // multiplication/division operations
    (func == 3'b000 && auxFunc == `AUX_FUNC_MUL_DIV) ? (opA * opB) :                     // mul
    (func == 3'b001 && auxFunc == `AUX_FUNC_MUL_DIV) ? (($signed(opA) * $signed(opB)) >> 32) : // mulh
    (func == 3'b010 && auxFunc == `AUX_FUNC_MUL_DIV) ? (($signed(opA) * opB) >> 32) :      // mulhsu
    (func == 3'b011 && auxFunc == `AUX_FUNC_MUL_DIV) ? ((opA * opB) >> 32) :               // mulhu
    (func == 3'b100 && auxFunc == `AUX_FUNC_MUL_DIV) ? ((opB != 0) ? $signed(opA) / $signed(opB) : 32'hXXXXXXXX):
    (func == 3'b101 && auxFunc == `AUX_FUNC_MUL_DIV) ? ((opB != 0) ? opA / opB : 32'hXXXXXXXX) :                           // divu
    (func == 3'b110 && auxFunc == `AUX_FUNC_MUL_DIV) ? (($signed(opB) != 0) ? $signed(opA) % $signed(opB) : 32'hXXXXXXXX) : // rem
    (func == 3'b111 && auxFunc == `AUX_FUNC_MUL_DIV) ? ((opB != 0) ? opA % opB : opA) :                           // remu
    32'hXXXXXXXX;


  // immediate operations
  wire [`WORD_WIDTH-1:0] immediateRes;
  wire [`WORD_WIDTH-1:0] imm_ext = {{20{imm[11]}}, imm}; // sign-extend imm to 32 bits
  wire [4:0] shamt = imm[4:0]; // shift amount
  assign immediateRes =
    (func == 3'b000) ? (opA + imm_ext) : // addi
    (func == 3'b010) ? (($signed(opA) < $signed(imm_ext)) ? 32'b1 : 32'b0) : // slti
    (func == 3'b011) ? ((opA < imm_ext) ? 32'b1 : 32'b0) : // sltiu
    (func == 3'b100) ? (opA ^ imm_ext) : // xori
    (func == 3'b110) ? (opA | imm_ext) : // ori
    (func == 3'b111) ? (opA & imm_ext) : // andi
    (func == 3'b001) ? (opA << shamt) : // slli
    (func == 3'b101 && imm[11:5] == 7'b0000000) ? (opA >> shamt) : // srli
    (func == 3'b101 && imm[11:5] == 7'b0100000) ? ($signed(opA) >>> shamt) : // srai
    32'hXXXXXXXX;

  // lui
  wire [`WORD_WIDTH-1:0] luiRes;
  assign luiRes = {imm20, 12'b0}; // load upper immediate (20 bit)

  // auipc
  wire [`WORD_WIDTH-1:0] auipcRes;
  assign auipcRes = PC + {imm20, 12'b0}; // add upper immediate (20 bit) to PC

  // load/store
  wire [`WORD_WIDTH-1:0] ldStrRes;
  assign ldStrRes = opA + imm_ext; // imm_ext is previously defined under immediate operations

  // jump and link
  wire [`WORD_WIDTH-1:0] jalRes;
  assign jalRes = PC + 4; // return address of the next instruction

  // jump and link register
  wire [`WORD_WIDTH-1:0] jalrRes;
  assign jalrRes = (opA + imm_ext) & ~32'b1; // mask off LSB for JALR

  // output assignment mux
  assign out = 
  (opCode == `OPCODE_COMPUTE) ? computeRes : 
  (opCode == `OPCODE_IMMEDIATE) ? immediateRes : 
  (opCode == `OPCODE_LUI) ? luiRes :
  (opCode == `OPCODE_AUIPC) ? auipcRes : 
  (opCode == `OPCODE_LOAD || opCode == `OPCODE_STORE) ? ldStrRes : 
  (opCode == `OPCODE_JAL) ? jalRes :
  (opCode == `OPCODE_JALR) ? jalrRes :
  32'hXXXXXXXX;
   
endmodule // ExecutionUnit

