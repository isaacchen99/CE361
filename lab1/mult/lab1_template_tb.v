`timescale 1ns/1ps

`define WIDTH 32

module testbench();
   reg clk, rst;
   reg valid;
   reg [`WIDTH-1:0] opA, opB;
   wire [`WIDTH-1:0] product;
   wire 	     done;
   real 	     period;
   
   // Instantiate the design under test...one of the three multiply modules
   MultThree DUT(.done(done), .product(product), .valid(valid), 
		 .opA(opA), .opB(opB), .clk(clk), .rst(rst));
   
   // Set the clock period (based on commandline argument)
   always 
     #(period/2.0) clk = ~clk;

     /* You should compile using the following:

        iverilog -gspecify -o test_mult3 lab1_template_tb.v lib/NangateOpenCellLibrary.v design/MultThree.v

       Don't forget the -gspecifcy

       You should make a separate testbench for each of the designs (MultOne, MultTwo, MultThree)

    */

    integer cycle_count;

   initial begin

      /* 
           The following reads a command line argument that sets the clock period (in nanoseconds).
           Assuming that you named the testbench executable test_mult1 (set by -o <executable-name> in the above iverilog command), you
           could do the following at a prompt:
          
           linux-box:mult userid$  ./test_mult1 +PERIOD=2

           Which would run the testbench with period of 2ns => clockrate = 500 MHz

      */
      if (!$value$plusargs("PERIOD=%0F", period))
        	period = 10.0;  // default is 10ns => 100 MHz 

      $display("Period=%f ns\n", period);

      $sdf_annotate("design/MultThree.sdf", DUT); 

      $monitor($realtime,, "%b %x %x %b %x", valid, opA, opB, done, product);

      doReset;  // Reset the system

      doMultiply(32'h10001001, 32'h10010002);
      doWaitForDone;

      $display("Test sequence complete.");
      $finish; // end simulation <DO NOT DELETE>
    end

    task doReset; // initialize the system
      begin
        clk = 1; rst = 1; valid = 0; opA = 0; opB = 0;
        #(period/2) rst = 0; 
        #(period/2) rst = 1;
        cycle_count = 0; // Reset cycle counter
      end
    endtask

    task doMultiply(input [`WIDTH-1:0] a, input [`WIDTH-1:0] b); // set inputs for mult operation
      begin
        cycle_count = 0; // Reset cycle counter at the start of a multiplication
        valid = 1; opA = a; opB = b;
        #period;
      end
    endtask

    task doWait; // wait for a cycle
      begin
        valid = 0;
        #period;
      end
    endtask

    task doWaitForDone; // Wait for the multiplication to complete
    begin
        while (!done) begin
            @(posedge clk);
            cycle_count = cycle_count + 1; // Increment counter on each clock cycle wait
        end
        $display("Multiplication %h * %h = %h completed in %d clock cycles", opA, opB, product, cycle_count);
    end
    endtask

endmodule
