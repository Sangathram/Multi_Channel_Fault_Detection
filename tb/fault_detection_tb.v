`timescale 1ns/1ps

module fault_detection_tb;

    integer fail_count = 0;
    integer i;

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
        if (fault === 1'b0 && fault_code === 4'b0000) begin
            $display("RESET PASS: Outputs clear on clock edge");
        end else begin
            fail_count = fail_count + 1;
            $display("RESET FAIL: fault=%b code=%b", fault, fault_code);
        end

        rst = 0;

        // Test 1: No fault
        #10;
        if (fault == 0 && fault_code == 4'b0000) begin
            $display("TEST 1 PASS: No fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 1 FAIL");
        end

        // Test 2: CH1 fault
        ch1 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b1000) begin
            $display("TEST 2 PASS: CH1 fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 2 FAIL");
        end

        ch1 = 0;

        // Test 3: CH2 fault
        ch2 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0100) begin
            $display("TEST 3 PASS: CH2 fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 3 FAIL");
        end

        ch2 = 0;

        // Test 4: CH3 fault
        ch3 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0010) begin
            $display("TEST 4 PASS: CH3 fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 4 FAIL");
        end

        ch3 = 0;

        // Test 5: CH4 fault
        ch4 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0001) begin
            $display("TEST 5 PASS: CH4 fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 5 FAIL");
        end

        ch4 = 0;

        // Test 6: Multiple faults
        ch1 = 1;
        ch3 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b1000) begin
            $display("TEST 6 PASS: CH1 priority");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 6 FAIL");
        end

                // Test 7: CH2 priority over CH3 and CH4
        ch1 = 0;
        ch2 = 1;
        ch3 = 1;
        ch4 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0100) begin
            $display("TEST 7 PASS: CH2 priority");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 7 FAIL");
        end

        // Test 8: CH3 priority over CH4
        ch2 = 0;
        ch3 = 1;
        ch4 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b0010) begin
            $display("TEST 8 PASS: CH3 priority");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 8 FAIL");
        end

        // Test 9: Return to no fault
        ch3 = 0;
        ch4 = 0;
        #10;
        if (fault == 0 && fault_code == 4'b0000) begin
            $display("TEST 9 PASS: No fault after clearing");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 9 FAIL");
        end


        // Test 10: All four channels asserted; CH1 has highest priority
        ch1 = 1;
        ch2 = 1;
        ch3 = 1;
        ch4 = 1;
        #10;
        if (fault == 1 && fault_code == 4'b1000) begin
            $display("TEST 10 PASS: CH1 priority when all channels are active");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 10 FAIL: fault=%b code=%b", fault, fault_code);
        end

        // Test 11: Synchronous reset clears an active fault
        rst = 1;
        #10;
        if (fault === 1'b0 && fault_code === 4'b0000) begin
            $display("TEST 11 PASS: Reset clears active fault");
        end else begin
            fail_count = fail_count + 1;
            $display("TEST 11 FAIL: fault=%b code=%b", fault, fault_code);
        end

        rst = 0;
        ch1 = 0;
        ch2 = 0;
        ch3 = 0;
        ch4 = 0;
        #10;

        // Exhaustive test: all 16 input combinations
        $display("================================");
        $display("Starting exhaustive 16-combination test");
        $display("================================");

        rst = 0;

         for (i = 0; i < 16; i = i + 1) begin
            {ch1, ch2, ch3, ch4} = i[3:0];
            #10;

            if (ch1) begin
                if (fault !== 1'b1 || fault_code !== 4'b1000) begin
                    fail_count = fail_count + 1;
                    $display("EXHAUSTIVE FAIL: inputs=%b code=%b",
                             {ch1, ch2, ch3, ch4}, fault_code);
                end
            end else if (ch2) begin
                if (fault !== 1'b1 || fault_code !== 4'b0100) begin
                    fail_count = fail_count + 1;
                    $display("EXHAUSTIVE FAIL: inputs=%b code=%b",
                             {ch1, ch2, ch3, ch4}, fault_code);
                end
            end else if (ch3) begin
                if (fault !== 1'b1 || fault_code !== 4'b0010) begin
                    fail_count = fail_count + 1;
                    $display("EXHAUSTIVE FAIL: inputs=%b code=%b",
                             {ch1, ch2, ch3, ch4}, fault_code);
                end
            end else if (ch4) begin
                if (fault !== 1'b1 || fault_code !== 4'b0001) begin
                    fail_count = fail_count + 1;
                    $display("EXHAUSTIVE FAIL: inputs=%b code=%b",
                             {ch1, ch2, ch3, ch4}, fault_code);
                end
            end else begin
                if (fault !== 1'b0 || fault_code !== 4'b0000) begin
                    fail_count = fail_count + 1;
                    $display("EXHAUSTIVE FAIL: inputs=%b code=%b",
                             {ch1, ch2, ch3, ch4}, fault_code);
                end
            end
        end

        $display("Exhaustive test completed: 16 combinations checked");

        if (fail_count == 0) begin
            $display("================================");
            $display("ALL TESTS PASSED: 28 checks passed (12 original + 16 exhaustive)");
            $display("================================");
            $finish;
        end else begin
            $display("================================");
            $display("TESTBENCH FAILED: %0d check(s) failed", fail_count);
            $display("================================");
            $fatal(1, "Simulation failed");
        end

    end

endmodule
