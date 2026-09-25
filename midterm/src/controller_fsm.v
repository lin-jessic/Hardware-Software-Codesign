module controller_fsm(
    input wire [1:0] S, // 從 datapath 回來的目前 state
    input wire go, // go=1 才會跑，go=0 就 hold
    input wire M, // M=1 往上，M=0 往下
    output reg [1:0] sel // 拿來選 MUX 要走哪一條路
);

    // sel=00 選 hold，sel=01 選 +1，sel=10 選 -1
    always @(*) begin
        if (go == 1'b0) begin
            sel = 2'b00; // go 關掉就維持 S
        end else begin
            if (M == 1'b1) begin
                sel = 2'b01; // 往上數
            end else begin
                sel = 2'b10; // 往下數
            end
        end
    end

endmodule
