module lab2_tb;

    // Inputs to the ExecutionUnit
    reg [31:0] opA;
    reg [31:0] opB;
    reg [2:0]  func;
    reg [6:0]  auxFunc;

    // Output from the ExecutionUnit
    wire [31:0] out;

    // Instantiate the ExecutionUnit
    ExecutionUnit uut (
        .out(out),
        .opA(opA),
        .opB(opB),
        .func(func),
        .auxFunc(auxFunc)
    );

    // Test sequence
    initial begin
        // Initialize inputs
        opA = 0;
        opB = 0;
        func = 0;
        auxFunc = 0;
        
        // Test Case 1: Addition
        opA = 15;
        opB = 10;
        func = 3'b000;    // Function code for addition
        auxFunc = 7'b0000000; // Aux function for normal addition
        #10;  // Wait for the operation to complete

        // Test Case 2: Subtraction
        opA = 10;
        opB = 20;
        func = 3'b000;    // Function code for subtraction
        auxFunc = 7'b0100000; // Aux function for subtraction
        #10;  // Wait for the operation to complete

        // Test Case 3: Shift left logical (sll)
        opA = 4;
        opB = 5;          // Shift by 5 bits
        func = 3'b001;
        #10;

        // Test Case 4: Set less than signed (slt)
        opA = -5;
        opB = 3;
        func = 3'b010;
        #10;

        // Test Case 5: Set less than unsigned (sltu)
        opA = 5;
        opB = 3;
        func = 3'b011;
        #10;

        // Test Case 6: XOR
        opA = 4;
        opB = 1;
        func = 3'b100;
        #10;

        // Test Case 7: Shift right logical (srl)
        opA = 4;
        opB = 1;          // Shift by 1 bit
        func = 3'b101;
        auxFunc = 7'b0000000;
        #10;

        // Test Case 8: Shift right arithmetic (sra)
        opA = -8;         // Negative number to test sign extension
        opB = 1;          // Shift by 1 bit
        func = 3'b101;
        auxFunc = 7'b0100000;
        #10;

        // Test Case 9: OR
        opA = 4;
        opB = 1;
        func = 3'b110;
        #10;

        // Test Case 10: AND
        opA = 4;
        opB = 1;
        func = 3'b111;
        #10;

        // Complete the simulation
        $finish;
    end

    // Monitor changes and display outputs
    initial begin
        $monitor("At time %t, opA = %d, opB = %d, func = %b, auxFunc = %b, Result = %d",
                 $time, opA, opB, func, auxFunc, out);
    end

endmodule 