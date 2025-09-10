#include <stdio.h>
int main() {
    int dividend = 3215;   
    int divisor = -3;
    int quotient = 0;
    int remainder = 0;
    int n = 16;

    int sign = ((dividend < 0) ^ (divisor < 0)) ? -1 : 1;

    int u_dividend = (dividend < 0) ? -dividend : dividend;
    int u_divisor  = (divisor < 0) ? -divisor  : divisor;

    for (int i = n - 1; i >= 0; i--) {
        remainder = remainder << 1;
        int next_bit = (u_dividend >> i) & 1;
        remainder = remainder | next_bit;
        remainder = remainder - u_divisor;
        if (remainder < 0) {
            remainder = remainder + u_divisor;
            quotient = quotient << 1;
        } else {
            quotient = (quotient << 1) | 1;
        }
    }
    quotient = quotient * sign;
    remainder = remainder * sign;
    printf("Final Result: %d ÷ %d = ", dividend, divisor);
    printf("Quotient = %d, Remainder = %d\n", quotient, remainder);
    return 0;
}
