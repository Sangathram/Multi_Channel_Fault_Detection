`timescale 1ns/1ps

module fault_detection_tb;

    reg clk;
    reg rst;
    reg ch1, ch2, ch3, ch4;

    wire fault;
    wire [3:0] fault_code;

    fault_detection dut (
        .clk(clk),
        .rst(rst),
        .ch1(ch1),
        .ch2(ch2),
        .ch3(ch3),
        .ch4(ch4),
        .fault(fault),
        .fault_code(fault_code)
    );

    always #5 clk = ~clk;

    initial begin
         $dumpfile("../simulation/waveform.vcd");
         $dumpvars(0, fault_detection_tb);

        clk = 0;
        rst = 1;
        ch1 = 0;
        ch2 = 0;
        ch3 = 0;
        ch4 = 0;

        #10;
        rst = 0;

        // Test 1: No fault
        #10;
        if (fault == 0 && fault_code == 4'b0000)
            $display("TEST 1 PASS: No fault");
        else
            $display("TEST 1 FAIL");

        // Test 2: CH1 fault
        ch1 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b1000)
            $display("TEST 2 PASS: CH1 fault");
        else
            $display("TEST 2 FAIL");

        ch1 = 0;

        // Test 3: CH2 fault
        ch2 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0100)
            $display("TEST 3 PASS: CH2 fault");
        else
            $display("TEST 3 FAIL");

        ch2 = 0;

        // Test 4: CH3 fault
        ch3 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0010)
            $display("TEST 4 PASS: CH3 fault");
        else
            $display("TEST 4 FAIL");

        ch3 = 0;

        // Test 5: CH4 fault
        ch4 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0001)
            $display("TEST 5 PASS: CH4 fault");
        else
            $display("TEST 5 FAIL");

        ch4 = 0;

        // Test 6: Multiple faults
        ch1 = 1;
        ch3 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b1000)
            $display("TEST 6 PASS: CH1 priority");
        else
            $display("TEST 6 FAIL");

        #10;
        $finish;

    end

endmodule
