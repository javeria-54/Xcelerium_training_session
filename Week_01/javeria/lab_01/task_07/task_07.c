#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

void task07_bitwise_ops() {
    int a,b;
    char op;

    printf("enter two integers");
    scanf("%d %d", &a, &b);

    printf("choose op (&, |, ^, ~, r, l): ");
    scanf(" %c", &op);   

    switch (op) {
        case '&':
            printf("result %d\n", a & b);
            break;
        case '|':
            printf("result %d\n", a | b);
            break;
        case '^':
            printf("result %d\n", a ^ b);
            break;
        case '~':
            printf("result a , b %d, %d,\n", ~a , ~b);
            break;
        case 'r':
                printf("result a , b  %d , %d\n", a<<1 , b<<1);
            break;
        case 'l':
                printf("result a , b %d , %d\n", a>>1 , b>>1);
            break;
        default:
            printf("invalid operator\n");
    }
}
void task07_power_2(){ 
    int num;

    printf("enter an integer");
    scanf("%d", &num);

    if (num > 0 && (num & (num - 1)) == 0) {
        printf("%d is a power of 2\n", num);
    } else {
        printf("%d is not a power of 2\n", num);
    }
}

int main(){
    task07_bitwise_ops();
    task07_power_2();
    return 0;
}