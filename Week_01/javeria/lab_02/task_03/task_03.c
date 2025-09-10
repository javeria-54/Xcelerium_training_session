#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

//Macros
#define SQUARE(x) ((x)*(x))      
#define MAX2(a,b)  ((a) > (b)?(a):(b))     
#define MAX3(a,b,c)  (MAX2(MAX2(a,b), (c)))   
#define MAX4(a,b,c,d) (MAX2(MAX3(a,b,c), (d)))  
#define TO_UPPER(c)  (((c) >= 'a' && (c) <= 'z') ? ((c) - 32) : (c))   

void task3_1_macros() {
    printf("SQUARE(5) = %d\n" , SQUARE(5));

    printf("MAX2(10, 20) = %d \n", MAX2(10, 20));

    printf("MAX3(3, 7, 5) = %d \n", MAX3(3, 7, 5));

    printf("MAX4(1, 2, 3, 4) = %d \n", MAX4(1, 2, 3, 4));

    printf("TO_UPPER('a') = %c \n", TO_UPPER('a'));  
}

struct Student {
    char name[50];
    int roll;
    float gpa;
};

// Task 3.2: File I/O
void task3_2_fileio() {
    struct Student students[5];
    FILE *fp;

    // Input 5 students
    printf("Enter details of 5 students:\n");
    for (int i = 0; i < 5; i++) {
        printf("Student %d name: ", i + 1);
        scanf("%s", students[i].name);

        printf("Student %d roll: ", i + 1);
        scanf("%d", &students[i].roll);

        printf("Student %d GPA: ", i + 1);
        scanf("%f", &students[i].gpa);
    }

    int topIndex = 0;
    for (int i = 1; i < 5; i++) {
        if (students[i].gpa > students[topIndex].gpa) {
            topIndex = i;
        }
    }

    printf("\nTop student: %s (Roll: %d) with GPA %.2f\n",
           students[topIndex].name,
           students[topIndex].roll,
           students[topIndex].gpa);

    // Save to file
    fp = fopen("students.txt", "w");
    if (fp == NULL) {
        printf("Error opening file for writing!\n");
        return;
    }
    for (int i = 0; i < 5; i++) {
        fprintf(fp, "%s %d %.2f\n",
                students[i].name,
                students[i].roll,
                students[i].gpa);
    }
    fclose(fp);
    printf("\nData saved to students.txt\n");

    // Read back from file
    fp = fopen("students.txt", "r");
    if (fp == NULL) {
        printf("Error opening file for reading!\n");
        return;
    }

    printf("\nReading back from file:\n");
    struct Student temp;
    while (fscanf(fp, "%s %d %f",
                  temp.name,
                  &temp.roll,
                  &temp.gpa) == 3) {
        printf("Name: %s, Roll: %d, GPA: %.2f\n",
               temp.name, temp.roll, temp.gpa);
    }
    fclose(fp);
}
int main(){
    // --- Part 3 ---
    task3_1_macros();
    task3_2_fileio();
    return 0;
}
