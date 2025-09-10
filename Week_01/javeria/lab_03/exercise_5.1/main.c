#include <stdio.h>

int add_numbers(int a, int b);
int multiply_numbers(int a, int b);

int main() {
    printf("Starting program...\n");
    
    int result = add_numbers(5, 3);
    printf("5 + 3 = %d\n", result);
    
    result = multiply_numbers(4, 6);
    printf("4 * 6 = %d\n", result);
    
    printf("Program completed!\n");
    return 0;
}

