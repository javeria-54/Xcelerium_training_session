#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

int add(int a, int b, int q, int q_1) {
    int sum, difference;

    sum = a + b;             
    difference = a - b;      

    if ((q & 1) == 1 && q_1 == 0) {
        a = difference;
    } else if ((q & 1) == 0 && q_1 == 1) {
        a = sum;
    }
    
    a &= 0xFF;
    q &= 0xFF;

    int combined = (a << 9) | (q << 1) | q_1;

    if (a & 0x80) { 
        combined = (combined >> 1) | (1 << 16);  
    } else {
        combined >>= 1;
    }

    a   = (combined >> 9) & 0xFF;
    q   = (combined >> 1) & 0xFF;
    q_1 = combined & 1;

    return (a << 16) | (q << 8) | q_1;
}

int booth_multiply(int multiplicand, int multiplier) {
    int a = 0;
    int b = multiplicand & 0xFF; 
    int q = multiplier & 0xFF;   
    int q_1 = 0;

    for (int count = 0; count < 8; count++) {
        int packed = add(a, b, q, q_1);
        a   = (packed >> 16) & 0xFF;
        q   = (packed >> 8) & 0xFF;
        q_1 = packed & 1;
    }

    int result = (a << 8) | q;
    return (int16_t)result;  
}

void test_booth() {
    int a = 13, b = -3;
    int product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = -7; b = 0;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = 25; b = 4;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = -27; b = -8;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = -67; b = 56;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = 259; b = 4;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);

    a = -257; b = -4;
    product = booth_multiply(a, b);
    printf("%d x %d = %d\n", a, b, product);
}
int main(){   
    // --- Final Task ---
    test_booth();

    return 0;
}
