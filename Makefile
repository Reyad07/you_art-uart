GUI := 0

ifeq ($(GUI), 0)
	XSIM_FLAGS := -runall
else
	XSIM_FLAGS := -gui --autoloadwcfg --view ../uart_tb.wcfg
endif

build:
	@mkdir -p build
	@echo "*" > build/.gitignore

.PHONY: run
run:
	@make -s build
	@cd build && xvlog -sv ../pkg/log_color_pkg.sv ../src/uart_tx.sv ../src/uart_rx.sv ../src/uart_top.sv ../sim/uart_tb.sv
	@cd build && xelab uart_tb -s uart_tb -debug all
	@cd build && xsim uart_tb $(XSIM_FLAGS)

.PHONY: clean
clean:
	@rm -rf build

.PHONY: all
all:
	@make -s clean
	@make -s run