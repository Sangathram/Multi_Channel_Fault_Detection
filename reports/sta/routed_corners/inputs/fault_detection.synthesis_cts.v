module fault_detection (ch1,
    ch2,
    ch3,
    ch4,
    clk,
    fault,
    rst,
    VPWR,
    VGND,
    fault_code);
 input ch1;
 input ch2;
 input ch3;
 input ch4;
 input clk;
 output fault;
 input rst;
 input VPWR;
 input VGND;
 output [3:0] fault_code;

 sky130_fd_sc_hd__inv_2 _08_ (.A(net1),
    .Y(_05_));
 sky130_fd_sc_hd__nor2_1 _09_ (.A(_05_),
    .B(net5),
    .Y(_03_));
 sky130_fd_sc_hd__inv_2 _10_ (.A(net5),
    .Y(_06_));
 sky130_fd_sc_hd__and3_1 _11_ (.A(_05_),
    .B(_06_),
    .C(net2),
    .X(_02_));
 sky130_fd_sc_hd__and4b_1 _12_ (.A_N(net2),
    .B(_06_),
    .C(_05_),
    .D(net3),
    .X(_01_));
 sky130_fd_sc_hd__or2_1 _13_ (.A(net2),
    .B(net3),
    .X(_07_));
 sky130_fd_sc_hd__and4b_1 _14_ (.A_N(_07_),
    .B(_06_),
    .C(net4),
    .D(_05_),
    .X(_00_));
 sky130_fd_sc_hd__o31a_1 _15_ (.A1(net1),
    .A2(net4),
    .A3(_07_),
    .B1(_06_),
    .X(_04_));
 sky130_fd_sc_hd__dfxtp_1 _16_ (.D(_00_),
    .Q(net7),
    .CLK(clknet_1_1_0_clk));
 sky130_fd_sc_hd__dfxtp_1 _17_ (.D(_01_),
    .Q(net8),
    .CLK(clknet_1_1_0_clk));
 sky130_fd_sc_hd__dfxtp_1 _18_ (.D(_02_),
    .Q(net9),
    .CLK(clknet_1_0_0_clk));
 sky130_fd_sc_hd__dfxtp_1 _19_ (.D(_03_),
    .Q(net10),
    .CLK(clknet_1_0_0_clk));
 sky130_fd_sc_hd__dfxtp_1 _20_ (.D(_04_),
    .Q(net6),
    .CLK(clknet_1_0_0_clk));
 sky130_fd_sc_hd__decap_3 PHY_0 ();
 sky130_fd_sc_hd__decap_3 PHY_1 ();
 sky130_fd_sc_hd__decap_3 PHY_2 ();
 sky130_fd_sc_hd__decap_3 PHY_3 ();
 sky130_fd_sc_hd__decap_3 PHY_4 ();
 sky130_fd_sc_hd__decap_3 PHY_5 ();
 sky130_fd_sc_hd__decap_3 PHY_6 ();
 sky130_fd_sc_hd__decap_3 PHY_7 ();
 sky130_fd_sc_hd__decap_3 PHY_8 ();
 sky130_fd_sc_hd__decap_3 PHY_9 ();
 sky130_fd_sc_hd__decap_3 PHY_10 ();
 sky130_fd_sc_hd__decap_3 PHY_11 ();
 sky130_fd_sc_hd__decap_3 PHY_12 ();
 sky130_fd_sc_hd__decap_3 PHY_13 ();
 sky130_fd_sc_hd__decap_3 PHY_14 ();
 sky130_fd_sc_hd__decap_3 PHY_15 ();
 sky130_fd_sc_hd__decap_3 PHY_16 ();
 sky130_fd_sc_hd__decap_3 PHY_17 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_18 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_19 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_20 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_21 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 PHY_22 ();
 sky130_fd_sc_hd__buf_1 input1 (.A(ch1),
    .X(net1));
 sky130_fd_sc_hd__buf_1 input2 (.A(ch2),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_1 input3 (.A(ch3),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_1 input4 (.A(ch4),
    .X(net4));
 sky130_fd_sc_hd__buf_1 input5 (.A(rst),
    .X(net5));
 sky130_fd_sc_hd__clkbuf_2 output6 (.A(net6),
    .X(fault));
 sky130_fd_sc_hd__clkbuf_2 output7 (.A(net7),
    .X(fault_code[0]));
 sky130_fd_sc_hd__clkbuf_2 output8 (.A(net8),
    .X(fault_code[1]));
 sky130_fd_sc_hd__clkbuf_2 output9 (.A(net9),
    .X(fault_code[2]));
 sky130_fd_sc_hd__clkbuf_2 output10 (.A(net10),
    .X(fault_code[3]));
 sky130_fd_sc_hd__clkbuf_16 clkbuf_0_clk (.A(clk),
    .X(clknet_0_clk));
 sky130_fd_sc_hd__clkbuf_1 clkbuf_1_0_0_clk (.A(clknet_0_clk),
    .X(clknet_1_0_0_clk));
 sky130_fd_sc_hd__clkbuf_1 clkbuf_1_1_0_clk (.A(clknet_0_clk),
    .X(clknet_1_1_0_clk));
endmodule
