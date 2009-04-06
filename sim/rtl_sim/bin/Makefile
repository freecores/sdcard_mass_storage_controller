# Icarus Verilog simulation defaults to LXT - but cannot be watched 
# live in GTK wave though - thus VCD option included
sim:
	iverilog -D LXT -osim.out -s  CPUboard_tb -c ../bin/iver.cmd
	./sim.out -lxt
	gtkwave ./wavedump.lxt ../bin/wave_signals.sav &

sim_vcd:
	iverilog -D VCD -osim.out -s CPUboard_tb -c ../bin/iver.cmd
	./sim.out 
	gtkwave ./wavedump.vcd ../bin/wave_signals.sav &

clean:
	rm -rf *.key *.log *.shm INCA* .simvision *.out *.vcd *.lxt *~

all: clean sim

