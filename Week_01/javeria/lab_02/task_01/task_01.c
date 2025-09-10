#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

// Task 1.1: Basic pointer usage
void task1_1() {
    int x = 21;
    int *ptr = &x;
    
    printf("value of x: %d\n",x);
    printf("value pointed by ptr: %d\n" , *ptr);
    printf("address of x: %p\n", &x);
    printf("address of ptr: %p\n", &ptr);
    printf("\n");
    *ptr = 14;
    printf("new value of x: %d\n",x);
    printf("value pointed by ptr: %d\n" , *ptr);
    printf("address of x: %p\n", &x);
    printf("address of ptr: %p\n", &ptr);
}

// Task 1.2: Swap two integers using pointers
void swap(int *a, int *b){
    printf("\nthe value of a %d and b %d \n", *a, *b);
    int swap;
    swap = *a;
    *a = *b;
    *b = swap;
    printf("the value of a %d and b is %d \n", *a, *b);
}

// Task 1.3: Pointer arithmetic on array
void task1_3() {
    int numbers[5] = {1, 2, 3, 4, 5};
    int *ptr = numbers; 
    for (int i = 0; i < 5; i++){
        printf("\n");
        printf(" %d", *(ptr + i)); 
}
    printf("\n");
    int sum = 0; 
    for (int i = 0; i < 5; i++){
        sum += ptr[i];        
}
    printf("\nsum is %d \n", sum);

    int start = 0, end = 4;
    while (start < end) {
        int ptr = numbers[start];
        numbers[start] = numbers[end];
        numbers[end] = ptr;
        start++;
        end--;
    }
    for (int i = 0; i < 5; i++){
        printf("\n");
        printf(" %d", numbers[i]);
    }    
    printf("\n");
}

int main (){
    // --- Part 1 ---
    task1_1();
    int a=5, b=10; 
    swap(&a,&b);
    task1_3();
    return 0;
}