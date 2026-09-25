module datapath(
    input wire clk,
    input wire rst,
    input wire [1:0] sel,
    output reg [1:0] S,
    output reg [3:0] LED
);

    wire [1:0] I0;
    wire [1:0] I1;
    wire [1:0] I2;
    reg [1:0] next_S;

    assign I0 = S; // hold path
    assign I1 = S + 2'd1; // +1 path，2-bit 會自己繞回 00
    assign I2 = S - 2'd1; // -1 path，00 往下會變 11

    // 這裡就是 (c) 圖上的 3-to-1 MUX
    always @(*) begin
        case (sel)
            2'b00: next_S = I0;
            2'b01: next_S = I1;
            2'b10: next_S = I2;
            default: next_S = I0;
        endcase
    end

    // state register，存現在的 S
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S <= 2'b00;
        end else begin
            S <= next_S;
        end
    end

    // decoder，S 對應到哪顆 LED 亮
    always @(*) begin
        case (S)
            2'b00: LED = 4'b0001;
            2'b01: LED = 4'b0010;
            2'b10: LED = 4'b0100;
            2'b11: LED = 4'b1000;
            default: LED = 4'b0001;
        endcase
    end

endmodule
