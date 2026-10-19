IVERILOG = iverilog
VVP = vvp

RTL = rtl/fault_detection.v
TB = tb/fault_detection_tb.v
SIM_BIN = simulation/fault_detection_test

.PHONY: all test clean

all: test

$(SIM_BIN): $(RTL) $(TB)
	$(IVERILOG) -g2012 -o $(SIM_BIN) $(RTL) $(TB)

test: $(SIM_BIN)
	cd simulation && $(VVP) fault_detection_test

clean:
	rm -f $(SIM_BIN)
