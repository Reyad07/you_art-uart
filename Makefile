export SHELL=/bin/bash

export YOU_ART-UART=$(CURDIR)

TOP := uart_tb

FL += $(YOU_ART-UART)/pkg/log_color_pkg.sv 
FL += $(YOU_ART-UART)/src/simple/uart_rx.sv 
FL += $(YOU_ART-UART)/src/simple/uart_tx.sv
FL += $(YOU_ART-UART)/src/simple/uart_top.sv

FL += $(YOU_ART-UART)/sim/uart_tb.sv

BUILD := $(YOU_ART-UART)/BUILD

GUI := 0

EWHL := | grep -iE "Error:|Warning:|" --color=auto

ifneq ($(GUI),0)
	SIM_ARGS += -gui
else
	SIM_ARGS += -runall
endif

$(BUILD):
	@echo "Creating build directory at $@"
	@mkdir -p $@
	@echo "*" > $@/.gitignore

.PHONY: clean
clean:
	@rm -rf $(BUILD)

.PHONY: all
all:
	@make -s compile
	@make -s simulate TOP=$(TOP)

.PHONY: compile
compile:
	@make -s clean
	@make -s $(BUILD)
	@cd $(BUILD) && xvlog -sv $(FL)
	@cd $(BUILD) && xelab $(TOP) -s top -debug all $(EWHL)

.PHONY: simulate
simulate:
	@echo "--testplusarg TOP=$(TOP)" > $(BUILD)/sim_args
	@echo "$(SIM_ARGS)" >> $(BUILD)/sim_args
	@cd $(BUILD) && xsim top -f $(BUILD)/sim_args $(EWHL)
