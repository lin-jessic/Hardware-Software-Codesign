# Hardware-Software Codesign

長庚大學資訊工程學系「軟硬體協同設計」課程成果整理。

本課程實作從 Sequential C 描述系統行為開始，再將控制邏輯轉換為 Controller / FSM 與 Datapath，最後以 Verilog 完成 RTL 實作，並透過 Testbench 與 Waveform 驗證硬體行為。

期中實作以一個 2-bit Up / Down LED Controller 為題，透過 `go` 與 `M` 控制系統保持、向上計數或向下計數，並將目前 State 經 Decoder 對應至四個 LED 輸出。

**Course:** 軟硬體協同設計  
**Institution:** 長庚大學 資訊工程學系  
**Instructor:** 謝萬雲教授  
**Languages:** C / Verilog HDL  
**Development Environment:** Visual Studio Code  
**Simulation:** Icarus Verilog / GTKWave

---

## Repository Structure

```text
Hardware-Software-Codesign/
│
├── midterm/
│   ├── src/
│   │   ├── a_controller.c
│   │   ├── controller_fsm.v
│   │   ├── datapath.v
│   │   ├── top_controller.v
│   │   └── tb_top_controller.v
│   │
│   ├── simulation/
│   │   └── midterm_controller.vcd
│   │
│   └── midterm_report.docx
│
├── final/
│   └── final_exam.pdf
│
├── README.md
└── .gitignore
```

---

## Midterm Project — LED Controller

期中實作為一個 2-bit Up / Down Controller。

系統內部以 `S[1:0]` 作為 State Register，可表示：

```text
00
01
10
11
```

目前的 State 會經由 Decoder 轉換成四個 LED 的輸出：

| State `S` | LED Output | Result |
| --- | --- | --- |
| `00` | `0001` | LED0 ON |
| `01` | `0010` | LED1 ON |
| `10` | `0100` | LED2 ON |
| `11` | `1000` | LED3 ON |

系統主要有兩個控制輸入：

### `go`

決定 Controller 是否更新 State。

```text
go = 0 → Hold
go = 1 → Update State
```

### `M`

當 `go = 1` 時決定計數方向。

```text
M = 1 → Count Up
M = 0 → Count Down
```

因此：

```text
Count Up:
00 → 01 → 10 → 11 → 00 → ...

Count Down:
00 → 11 → 10 → 01 → 00 → ...
```

---

## Design Flow

這次實作不是直接從 Verilog 開始，而是依序將系統由軟體行為描述轉換成硬體架構。

```text
Sequential C
     │
     ▼
Behavior Definition
     │
     ▼
Controller / FSM
     │
     ▼
Datapath
     │
     ▼
Verilog RTL
     │
     ▼
Top Module
     │
     ▼
Testbench
     │
     ▼
Waveform Verification
```

### 1. Sequential C

先以 C 語言描述 Controller 的行為。

`a_controller.c` 使用變數 `S` 模擬 2-bit State Register，依照 `go` 與 `M` 更新狀態，再以 Decoder 邏輯決定目前亮起的 LED。

這個階段主要用來確認系統的功能與狀態轉換規則。

---

### 2. Controller / FSM

`controller_fsm.v` 負責根據 `go` 與 `M` 產生 Datapath 所需的 `sel[1:0]`。

| go | M | sel | Operation |
| --- | --- | --- | --- |
| 0 | X | `00` | Hold |
| 1 | 1 | `01` | S + 1 |
| 1 | 0 | `10` | S - 1 |

Controller 本身不直接更新 State，而是決定 Datapath 應該選擇哪一條資料路徑。

---

### 3. Datapath

`datapath.v` 負責實際的資料運算與 State 儲存。

Datapath 包含三條主要資料路徑：

```text
I0 = S
I1 = S + 1
I2 = S - 1
```

由 Controller 產生的 `sel` 控制 3-to-1 MUX：

```text
               ┌──── I0 = S
               │
S ─────────────┼──── I1 = S + 1
               │
               └──── I2 = S - 1
                       │
                       ▼
                   3-to-1 MUX
                       │
                     next_S
                       │
                       ▼
                 State Register
                       │
                       ▼
                    S[1:0]
                       │
                       ▼
                    Decoder
                       │
                       ▼
                   LED[3:0]
```

---

### 4. Top Module

`top_controller.v` 將 Controller 與 Datapath 連接成完整系統。

```text
             go / M
                │
                ▼
       ┌────────────────┐
       │ Controller FSM │
       └───────┬────────┘
               │ sel
               ▼
       ┌────────────────┐
       │    Datapath    │
       │                │
clk ──►│ State Register │
rst ──►│ MUX / Decoder  │
       └───────┬────────┘
               │
          ┌────┴────┐
          ▼         ▼
        S[1:0]   LED[3:0]
```

---

## Source Files

| File | Description |
| --- | --- |
| `a_controller.c` | 使用 Sequential C 描述 Controller 行為 |
| `controller_fsm.v` | Controller / FSM，依 `go`、`M` 產生 `sel` |
| `datapath.v` | State Register、MUX、加減運算與 LED Decoder |
| `top_controller.v` | 整合 Controller 與 Datapath |
| `tb_top_controller.v` | Testbench，用於產生測試訊號與 Waveform |

---

## Simulation & Verification

Testbench 依序測試：

1. Reset
2. `go = 0` → Hold
3. `go = 1, M = 1` → Count Up
4. 執行途中 Hold
5. `go = 1, M = 0` → Count Down
6. 最後再次 Hold

主要觀察訊號：

```text
clk
rst
go
M
sel[1:0]
S[1:0]
LED[3:0]
```

預期結果：

```text
go = 0
→ sel = 00
→ S holds

go = 1, M = 1
→ sel = 01
→ 00 → 01 → 10 → 11 → 00

go = 1, M = 0
→ sel = 10
→ 00 → 11 → 10 → 01 → 00
```

`LED[3:0]` 則隨 `S[1:0]` 經 Decoder 改變。

---

## How to Run

本專案開發與測試環境為 Visual Studio Code。

### Requirements

需要安裝：

- GCC
- Icarus Verilog
- GTKWave

---

### Sequential C

進入：

```text
midterm/src/
```

編譯：

```bash
gcc a_controller.c -o a_controller
```

Windows 執行：

```bash
.\a_controller.exe
```

可使用以下輸入測試：

```text
1 1
1 1
1 1
1 1
0 1
1 0
1 0
-1 -1
```

其中：

```text
1 1   → Count Up
0 1   → Hold
1 0   → Count Down
-1 -1 → Exit
```

---

### Verilog Compilation

確認 Controller、Datapath 與 Top Module 可以正常編譯：

```bash
iverilog -o top_controller.out top_controller.v controller_fsm.v datapath.v
```

---

### Testbench Simulation

編譯 Testbench：

```bash
iverilog -o sim.out tb_top_controller.v top_controller.v controller_fsm.v datapath.v
```

執行：

```bash
vvp sim.out
```

執行後會產生：

```text
midterm_controller.vcd
```

---

### Waveform

使用 GTKWave 開啟：

```bash
gtkwave midterm_controller.vcd
```

建議加入：

```text
clk
rst
go
M
sel[1:0]
S[1:0]
LED[3:0]
```

即可觀察 Controller、Datapath 與 LED Output 是否依測試條件正確運作。

---

## Documents

- [`Midterm Report`](./midterm/midterm_report.docx) — 期中實作內容與作答
- [`Final Exam`](./final/final_exam.pdf) — 期末課程成果

---

## What I Learned

這次實作讓我更具體理解軟體中的演算法與控制流程，如何逐步轉換成硬體可實現的架構。

一開始先以 Sequential C 描述系統行為，再將控制條件抽離成 Controller / FSM，並把 State Register、MUX、運算與 Decoder 分離成 Datapath，最後以 Verilog 實作並透過 Testbench 與 Waveform 驗證。

相較於只撰寫 C 程式或單獨完成 Verilog Module，這個過程讓我實際理解 Controller 與 Datapath 的分工，以及從行為描述、RTL 設計到模擬驗證之間的關係。

---

> 本 Repository 為大學課程成果整理，內容以課程期間實際完成之程式、模擬結果與文件為主。
