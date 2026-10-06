module fault_detection (
    input  wire       clk,
    input  wire       rst,
    input  wire       ch1,
    input  wire       ch2,
    input  wire       ch3,
    input  wire       ch4,

    output reg        fault,
    output reg [3:0]  fault_code
);

always @(posedge clk) begin
    if (rst) begin
        fault      <= 1'b0;
        fault_code <= 4'b0000;
    end
    else begin
        if (ch1) begin
            fault      <= 1'b1;
            fault_code <= 4'b1000;
        end
        else if (ch2) begin
            fault      <= 1'b1;
            fault_code <= 4'b0100;
        end
        else if (ch3) begin
            fault      <= 1'b1;
            fault_code <= 4'b0010;
        end
        else if (ch4) begin
            fault      <= 1'b1;
            fault_code <= 4'b0001;
        end
        else begin
            fault      <= 1'b0;
            fault_code <= 4'b0000;
        end
    end
end

endmodule
