`timescale 1ns/1ps

module tb_top_controller;

    reg clk;
    reg rst;
    reg go;
    reg M;

    wire [1:0] S;
    wire [3:0] LED;
    wire [1:0] sel;

    top_controller uut (
        .clk(clk),
        .rst(rst),
        .go(go),
        .M(M),
        .S(S),
        .LED(LED),
        .sel(sel)
    );

    always #5 clk = ~clk; // clock 10ns 變一次週期

    initial begin
        $dumpfile("midterm_controller.vcd");
        $dumpvars(0, tb_top_controller);

        clk = 0;
        rst = 1;
        go = 0;
        M = 0;

        #10;
        rst = 0; // reset 完就讓電路開始正常跑

        go = 0;
        M = 0;
        #30; // case: hold

        go = 0;
        M = 1;
        #30; // case: 還是 hold，因為 go=0

        go = 1;
        M = 1;
        #60; // case: count up

        go = 0;
        M = 1;
        #30; // case: 中間停一下

        go = 1;
        M = 0;
        #60; // case: count down

        go = 0;
        M = 0;
        #30; // case: 最後再 hold

        $finish;
    end

    initial begin
        $monitor("time=%0t | rst=%b go=%b M=%b sel=%b S=%b LED=%b",
                 $time, rst, go, M, sel, S, LED);
    end

endmodule
