## Makefile for Verilog Compile
CC = iverilog
FLAG = -o
LOCATION = tb

cpu:
	$(CC) $(FLAG) $(LOCATION)/mips_cpu_tb.o $(LOCATION)/mips_cpu_tb.v
	vvp $(LOCATION)/mips_cpu_tb.o

register_file:
	$(CC) $(FLAG) $(LOCATION)/register_file_tb.o $(LOCATION)/register_file_tb.v
	vvp $(LOCATION)/register_file_tb.o

sign_extender:
	$(CC) $(FLAG) $(LOCATION)/sign_extender_tb.o $(LOCATION)/sign_extender_tb.v
	vvp $(LOCATION)/sign_extender_tb.o

alu:
	$(CC) $(FLAG) $(LOCATION)/alu_tb.o $(LOCATION)/alu_tb.v
	vvp $(LOCATION)/alu_tb.o

data_memory:
	$(CC) $(FLAG) $(LOCATION)/data_memory_tb.o $(LOCATION)/data_memory_tb.v
	vvp $(LOCATION)/data_memory_tb.o
clean:
	rm $(LOCATION)/*.o || true
	rm $(LOCATION)/*.vcd || true
	rm *.vcd || true

all: register_file sign_extender alu data_memory
	make register_file
	make sign_extender
	make alu
	make data_memory