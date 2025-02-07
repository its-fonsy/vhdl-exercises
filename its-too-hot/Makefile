SRCS	:= $(wildcard *.vhdl)
LIB		:= work

VLIB := vlib
VLIB_FLAGS :=

VCOM := vcom
VCOM_FLAGS := -2008 -quiet -work $(LIB)

VSIM := vsim
VSIM_FLAGS := -do "add wave -group dut /tb/dut/*; add wave -group tb /tb/*; run -all"

VDEL := vdel
VDEL_FLAGS := -all -lib $(LIB)

.PHONY: compile sim clean

compile: $(SRCS)
	@if [ ! -d work ]; then $(VLIB) $(VLIB_FLAGS) $(LIB); fi
	@$(VCOM) $(VCOM_FLAGS) $^

# Add flag "-c" to execute simulation in batch mode
sim: compile
	$(VSIM) $(VSIM_FLAGS) $(LIB).tb

clean:
	$(VDEL) $(VDEL_FLAGS)
	rm -f *.cr.mti *.mpf *.wlf transcript
