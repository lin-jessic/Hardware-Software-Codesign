# LED Controller Midterm Project
這份考試是在做一個拆完整的 LED controller。
整體可以想成一個 2-bit up/down counter，裡面有一個 state register S，用來記現在是哪一個燈要亮。

1. S 是 2-bit，所以可以表示 00、01、10、11，也就是 0 到 3。這個 S 會送到 decoder，decoder 再決定 LED0、LED1、LED2、LED3 哪一顆亮。
2. 這題主要的控制訊號有兩個：go 和 M。
3. go 是啟動訊號。如果 go 是 1，controller 會繼續動；如果 go 是 0，controller 就停在目前的 S，不會回到 0，也不會亂跳。
4. M 是方向選擇。如果 M 是 1，S 會往上數，也就是 00、01、10、11、00 一直循環。如果 M 是 0，S 會往下數，也就是 00、11、10、01、00 一直循環。

## 檔案說明
`a_controller.c` 是第 (a) 題用的 sequential C program。它用 C 語言模擬 controller 的行為，輸入 go 和 M 之後，會更新 S，然後再用 decoder 的概念印出哪一顆 LED 亮。這個檔案主要是先把整個功能用比較直覺的程式方式寫出來。
`controller_fsm.v` 是第 (d) 題的 controller / FSM module。它負責看 go 和 M，然後產生 sel[1:0] 給 datapath 的 MUX 使用。
`datapath.v` 是第 (d) 題的 datapath module。它裡面有 2-bit state register S，也有 I0、I1、I2 三條資料路徑，還有 decoder 輸出 LED[3:0]。
`top_controller.v` 是第 (d) 題用來把 controller_fsm 和 datapath 接在一起的 top module。這樣 controller 和 datapath 就不是分開各做各的，而是真的有連起來。
`tb_top_controller.v` 是第 (e) 題用的 testbench。它會產生 clock、reset、go、M 這些測試訊號，然後把模擬結果輸出成 midterm_controller.vcd，之後可以用 GTKWave 看 waveform。

## 執行方式
先進到 Mid 資料夾，也就是這些檔案放的地方。
第 (a) 題如果要跑 C 程式，先把 a_controller.c 編譯成執行檔，然後執行它。執行後可以輸入 go 和 M，例如連續輸入 1 1 可以看到 S 往上數，輸入 1 0 可以看到 S 往下數，輸入 0 1 或 0 0 可以看到 S 停住。最後輸入 -1 -1 結束程式。
第 (d) 題如果只是要確認 Verilog 有沒有語法錯，可以把 top_controller.v、controller_fsm.v、datapath.v 一起編譯。成功後會產生 top_controller.out。這個 .out 檔只是 Icarus Verilog 編出來的模擬執行檔，不是主要要交的程式碼。
第 (e) 題要做 waveform，所以要把 tb_top_controller.v 也一起編譯。編譯完後執行模擬，會產生 midterm_controller.vcd。這個 vcd 檔就是 waveform 檔，用 GTKWave 打開。
在 GTKWave 裡面，我主要看這幾個訊號：clk、rst、go、M、sel[1:0]、S[1:0]、LED[3:0]。

如果 go=0，sel 會是 00，S 會保持不變。
如果 go=1 且 M=1，sel 會是 01，S 會照 00、01、10、11、00 這樣往上數。
如果 go=1 且 M=0，sel 會是 10，S 會照 00、11、10、01、00 這樣往下數。

LED[3:0] 會跟著 S 改變。S=00 時 LED=0001，S=01 時 LED=0010，S=10 時 LED=0100，S=11 時 LED=1000。

## 我自己的理解
(a) 是先用 C 寫出行為。
(b) 是把 C 的邏輯轉成 FSM。
(c) 是把 FSM 的 RTL operation 變成 datapath。
(d) 是用 Verilog 把 controller 和 datapath 寫出來。
(e) 是用 testbench 和 waveform 證明它真的有照 go 和 M 正確運作。

## 執行前要先準備的工具
我是在 VS Code 裡面做的。

1. C 程式需要 gcc。
2. FSM 圖如果要從 .dot 產生圖片，需要 Graphviz。
3. Verilog 模擬需要 Icarus Verilog，也就是 iverilog 和 vvp。
4. 看 waveform 需要 GTKWave。

## 第 (a) 題 C 程式執行方法
先確認 a_controller.c 在 Mid 資料夾裡。
在 VS Code 打開 terminal，路徑要在 Mid 資料夾。
1. 輸入這行編譯 C 程式：
gcc a_controller.c -o a_controller

2. 編譯成功後，執行：
.\a_controller.exe

執行後可以輸入 go 和 M，可以用這組測試：

1 1
1 1
1 1
1 1
0 1
1 0
1 0
-1 -1

前面幾個 1 1 是測試 count up，會看到 S 從 0 往 1、2、3、0 跑。
0 1 是測試 go=0 的 hold，S 應該要停住。
1 0 是測試 count down，S 會往下數。
-1 -1 是結束程式。

## 第 (d) 題 Verilog 編譯檢查
檔案有：
controller_fsm.v、datapath.v、top_controller.v

1. 在 Mid 資料夾裡輸入：
iverilog -o top_controller.out top_controller.v controller_fsm.v datapath.v
top_controller.out 是 Icarus Verilog 編出來的結果檔，不是主要要看的程式碼，主要要交的還是 .v 原始碼。

第 (d) 題有兩塊:
一塊是 controller_fsm，負責產生 sel。
一塊是 datapath，負責 S register、MUX、+1、-1、decoder。
top_controller 則是把兩塊接起來。

## 第 (e) 題 waveform 模擬方法
第 (e) 題要用 testbench 產生 waveform。
檔案有：
tb_top_controller.v、top_controller.v、controller_fsm.v、datapath.v

1. 在 Mid 資料夾輸入：
iverilog -o sim.out tb_top_controller.v top_controller.v controller_fsm.v datapath.v

2. 然後執行模擬：
vvp sim.out

執行後會產生 midterm_controller.vcd。
3. 接著用 GTKWave 打開：
gtkwave midterm_controller.vcd

打開後，我會把這些 signal 加進 waveform：

clk
rst
go
M
sel[1:0]
S[1:0]
LED[3:0]
如果畫面沒有完整顯示，可以按 Zoom Full。

這張 waveform 有幾個結果:
1. 當 go=0 的時候，sel=00，S 會 hold 不變。
2. 當 go=1 且 M=1 的時候，sel=01，S 會往上數，順序是 00、01、10、11、00。
3. 當 go=1 且 M=0 的時候，sel=10，S 會往下數，順序是 00、11、10、01、00。
4. LED[3:0] 會跟著 decoder output 改變。
5. S=00 時 LED=0001。
6. S=01 時 LED=0010。
7. S=10 時 LED=0100。
8. S=11 時 LED=1000。
