SRCS	:= $(wildcard *.vhdl)
LIB		:= work

VLIB := vlib
VLIB_FLAGS :=

VCOM := vcom
VCOM_FLAGS := -2008 -quiet -work $(LIB)

VSIM := vsim
VSIM_GUI_FLAGS := -quiet -do "add wave -group dut /testbench/dut/*; add wave -group tb /testbench/*; run -all"
VSIM_CLI_FLAGS := -do "run -all" -suppress GroupWarning -quiet

VDEL := vdel
VDEL_FLAGS := -all -lib $(LIB)

.PHONY: compile sim clean batch

compile: $(SRCS)
	@if [ ! -d work ]; then $(VLIB) $(VLIB_FLAGS) $(LIB); fi
	@$(VCOM) $(VCOM_FLAGS) $^

sim: compile
	$(VSIM) $(VSIM_GUI_FLAGS) $(LIB).TESTBENCH

batch: compile
	$(VSIM) -c $(VSIM_CLI_FLAGS) $(LIB).TESTBENCH

clean:
	$(VDEL) $(VDEL_FLAGS)
	rm -f *.cr.mti *.mpf *.wlf transcript
