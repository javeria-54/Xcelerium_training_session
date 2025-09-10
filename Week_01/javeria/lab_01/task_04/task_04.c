#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

int isPrime(int n) {
    if (n <= 1){
        return 0; 
    }
    int i;
    for (i = 2;  i < n; i++) {
        if ((n % i) == 0){
            return 0; 
        }
    }
    return 1;
}

void task04_prime_numbers() {
    printf("prime numbers between 1 and 100:\n");
    int i;
    for (i = 1; i <= 100; i++) {
        if (isPrime(i)) {
            printf("%d ", i);
        }
    }
    printf("\n");
}

int factorial(int n) {
    if (n == 0 || n == 1){ 
        return 1;
    }
    n = n * factorial(n - 1); 
    return n;
}

int main(){
    task04_prime_numbers();
    printf("Factorial of 5 = %d\n", factorial(5));
}