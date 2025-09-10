#include <stdio.h>
#include <stdint.h>
#include <string.h>

// this function can count the number of countbits 
int countbits(int a){
    int count = 0 ;
    while (a) {
        count = count + (a & 1);
        a = a >> 1; 
}
    return count;
}

// this function can count number of revrese bits
unsigned int reversebits(unsigned int a) {
    unsigned int reverse = 0;
    for (int i = 0; i < 32; i++){
        reverse = reverse << 1;
        reverse = reverse | (a & 1);
        a = a >> 1;
    } 
    return reverse;
}

// this function can check is the number is pow of 2 or not
int power2(int a) {
    int result;
    result = (a > 0) && (a & (a - 1));
    if (result == 0){
        return 1;
    }else {
        return 0;
    }
}

// this function can set any bit between 0-31
unsigned int setbit(unsigned int a, int pos) {
    unsigned int result = 0;
    result = (a | (1U << pos));
    return result;
}

// this function can clear bits between 0-31 
unsigned int clearbit(unsigned int a, int pos) {
    unsigned int result = 0;
    result = (a & ~(1U << pos));
    return result;
}

// this function can toggle bit between 0-31
unsigned int togglebit(unsigned int a, int pos) {
    unsigned int result = 0;
    result = (a ^ (1U << pos));
    return result;
}

int main() {
    int a;
    char op[20];
    int pos;

    scanf("%d", &a);
    scanf("%19s", op);

   if (strcmp(op, "countbit") == 0) {
        printf("number of set bits %d\n", countbits(a));
    }
    else if (strcmp(op, "reverse") == 0) {
        printf("reversed bits %u\n", reversebits(a));
    }
    else if (strcmp(op, "pow_2") == 0) {
        if (power2(a)) 
            printf("%d is power of 2\n", a);
        else 
            printf("%d is not power of 2\n", a);
    }
    else if (strcmp(op, "set") == 0) {
        printf("enter bit position (0-31) \n");
        scanf("%d", &pos);
        printf("the number after set is %u\n",setbit(a, pos));
    }
    else if (strcmp(op, "clear") == 0) {
        printf("enter bit position (0-31) \n");
        scanf("%d", &pos);
        printf("the number after clear is %u\n",clearbit(a, pos));
    }
    else if (strcmp(op, "toggle") == 0) {
        printf("enter bit position (0-31) \n");
        scanf("%d", &pos);
        printf("the number after toggle is %u\n",togglebit(a, pos));
    }
    else {
        printf("invalid operator\n");
    }

    printf("\n");
}

