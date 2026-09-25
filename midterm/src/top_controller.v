module top_controller(
    input wire clk,
    input wire rst,
    input wire go,
    input wire M,
    output wire [1:0] S,
    output wire [3:0] LED,
    output wire [1:0] sel
);

    // 這個 top 只是把 controller 跟 datapath 接起來
    controller_fsm u_controller (
        .S(S),
        .go(go),
        .M(M),
        .sel(sel)
    );

    datapath u_datapath (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .S(S),
        .LED(LED)
    );

endmodule
