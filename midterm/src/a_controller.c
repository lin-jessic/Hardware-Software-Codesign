#include <stdio.h>

int main() {
    int go, M;
    int S = 0; // 這裡把 S 當 2-bit state register 用，範圍就是 0~3
    int LED0, LED1, LED2, LED3; // decoder 出來的四顆燈

    printf("LED Controller Sequential C Program\n");
    printf("Initial state: S = %d\n", S);
    printf("Rule:\n");
    printf("go = 1 -> controller keeps working\n");
    printf("go = 0 -> controller holds current state\n");
    printf("M  = 1 -> count up   : 0 -> 1 -> 2 -> 3 -> 0 ...\n");
    printf("M  = 0 -> count down : 3 -> 2 -> 1 -> 0 -> 3 ...\n");
    printf("Decoder rule:\n");
    printf("S=0 or 00 -> LED0 ON\n");
    printf("S=1 or 01 -> LED1 ON\n");
    printf("S=2 or 10 -> LED2 ON\n");
    printf("S=3 or 11 -> LED3 ON\n");
    printf("Enter -1 -1 to end the program.\n\n");

    while (1) {
        printf("Enter go and M: ");
        scanf("%d %d", &go, &M);

        if (go == -1 && M == -1) { // 輸入 -1 -1 就結束
            printf("Program terminated.\n");
            break;
        }
        if ((go != 0 && go != 1) || (M != 0 && M != 1)) { // 避免亂輸入
            printf("Invalid input. Please enter only 0 or 1 for go and M.\n\n");
            continue;
        }
        if (go == 1) {
            if (M == 1) {
                S = (S + 1) % 4; // 往上數，3 後面會回到 0
            } else {
                S = (S + 3) % 4; // 往下數，這樣 0 會回到 3
            }
        } else {
            S = S; // go=0 就停在目前這個 state
        }

        LED0 = 0;
        LED1 = 0;
        LED2 = 0;
        LED3 = 0;

        if (S == 0) {
            LED0 = 1;
        } else if (S == 1) {
            LED1 = 1;
        } else if (S == 2) {
            LED2 = 1;
        } else if (S == 3) {
            LED3 = 1;
        }

        printf("Current S = %d\n", S);

        if (S == 0) {
            printf("Binary S = 00\n");
        } else if (S == 1) {
            printf("Binary S = 01\n");
        } else if (S == 2) {
            printf("Binary S = 10\n");
        } else {
            printf("Binary S = 11\n");
        }

        printf("Decoder output: LED0=%d, LED1=%d, LED2=%d, LED3=%d\n",
               LED0, LED1, LED2, LED3);

        printf("LED %d is ON now.\n\n", S);
    }
    return 0;
}
