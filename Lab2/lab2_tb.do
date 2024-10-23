#!/bin/bash

# Set environment variables
setenv LMC_TIMEUNIT -9

# Create and map the working library
vlib work
vmap work work

# Compile the Verilog source files into the 'work' library
vlog -work work "lab2_tb.v"
vlog -work work "icl5712_execute.v"

# Simulate the testbench
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.lab2_tb -wlf lab2_tb.wlf

# Add signals to waveform
add wave -noupdate -group TOP -radix binary /*

# Run the simulation
run -all