#!/bin/csh
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# Compile lab3_tb.v and lab3.v
vlog -work work "lab3_tb.v"
vlog -work work "lab3.v"

# Simulate with vsim
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.lab3_tb -wlf lab3_tb.wlf

# Waveform settings
add wave -noupdate -group TOP -radix binary lab3_tb/*

# Run the simulation
run -all
