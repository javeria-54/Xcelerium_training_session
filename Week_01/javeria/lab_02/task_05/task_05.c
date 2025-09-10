#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

// Task 5.1: Dynamic array, sum, average
void task5_1_dynamic_array() {
    int *ptr = (int *)malloc(5 * sizeof(int));

    if (ptr == NULL){
        printf("memory allocation failed \n");
    }
    printf("Enter 5 integers:\n");
    for (int i = 0; i < 5; i++) {
        scanf("%d", &ptr[i]);   
    }
    int sum = 0; 
    for (int i = 0; i < 5; i++)
        sum += ptr[i];
        { printf("sum of elements in array : %d \n", sum);
        }
    int avg ;
    avg = sum / 5;
    printf("average of elements in array : %d \n", avg); 

    free(ptr);
}


// Task 5.2: Extend array with realloc
void task5_2_realloc_array() {
    int *ptr = (int *)malloc(5 * sizeof(int)); 
    
    if (ptr == NULL) {
        printf("Initial memory allocation failed\n");
        return;
    }

    printf("Enter 5 integers:\n");
    for (int i = 0; i < 5; i++) {
        scanf("%d", &ptr[i]);   
    }

    printf("Original array: ");
    for (int i = 0; i < 5; i++) {
        printf("%d ", ptr[i]);
    }
    printf("\n");

    int *temp = (int *)realloc(ptr, 10 * sizeof(int));
    if (temp == NULL) {
        printf("Reallocation failed\n");
        free(ptr);
        return;
    }
    ptr = temp;

    printf("Enter 5 integers:\n");
    for (int i = 5; i < 10; i++) {
        scanf("%d", &ptr[i]);   
    }

    printf("Resized array: ");
    for (int i = 0; i < 10; i++) {
        printf("%d ", ptr[i]);
    }
    printf("\n");

    free(ptr); 
}


// Memory Leak Detector (simplified tracking)
#define MAX_PTRS 100
void* allocated_ptrs[MAX_PTRS];
int allocated_count = 0;

void* my_malloc(size_t size) {
    void *ptr = malloc(size);
    if (ptr != NULL) {
        if (allocated_count < MAX_PTRS) {
            allocated_ptrs[allocated_count++] = ptr; 
        } else {
            printf("Error: Too many allocations tracked!\n");
        }
    }
    return ptr;
}

void my_free(void *ptr) {
    if (ptr == NULL) return;

    for (int i = 0; i < allocated_count; i++) {
        if (allocated_ptrs[i] == ptr) {
            free(ptr);
            for (int j = i; j < allocated_count - 1; j++) {
                allocated_ptrs[j] = allocated_ptrs[j+1];
            }
            allocated_count--;
            return;
        }
    }
    printf("Warning: Tried to free untracked pointer %p\n", ptr);
}

void report_leaks() {
    if (allocated_count > 0) {
        printf("(Memory Leak Detected) %d block not freed:\n", allocated_count);
        for (int i = 0; i < allocated_count; i++) {
            printf("  Leak: pointer %p\n", allocated_ptrs[i]);
        }
    } else {
        printf("No memory leaks detected! \n");
    }
}

void task5_3_leak_detector() {
    int *a = (int*) my_malloc(sizeof(int));
    int *b = (int*) my_malloc(5 * sizeof(int));
    int *c;

    *a = 42;
    for (int i = 0; i < 5; i++) b[i] = i + 1;

    my_free(a);
    my_free(b);
    my_free(c);
    report_leaks();
}

int main(){
    // --- Part 5 ---
    task5_1_dynamic_array();
    task5_2_realloc_array();
    task5_3_leak_detector();
    return 0;
}