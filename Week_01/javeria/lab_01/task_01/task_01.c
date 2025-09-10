#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

void task01_datatypes() {
    int age = 21;
    float pi = 3.14;
    double precise_pi = 3.14159265359;
    char grade = 'A';
    
    printf("size of int: %zu bytes\n", sizeof(int));
    printf("size of float: %zu bytes\n", sizeof(float));
    printf("size of double: %zu bytes\n", sizeof(double));
    printf("size of char: %zu bytes\n", sizeof(char));
    
    printf("original values:\n");
    printf("age = %d\n", age);
    printf("pie = %f\n", pi);
    printf("precise pi = %lf\n", precise_pi);
    printf("grade = %c\n", grade);
    
    printf("\n");

    int pi_int; 
    pi_int = (int)pi;
    printf("Casting float pi=%.2f to int %d\n", pi, pi_int);
    
    float age_float;
    age_float = (float)age;
    printf("Casting int age=%d to float %.2f\n", age, age_float);
    
    int precise_int; 
    precise_int = (int)precise_pi;
    printf("Casting double precise_pi=%.5lf to int %d\n", precise_pi, precise_int);
    
    int grade_asci;
    grade_asci = (int)grade;
    printf("Casting char grade='%c' to int asci %d\n", grade, grade_asci);
    
    char int_char; 
    int_char = (char)66;  
    printf("Casting int 66 to char %c\n", int_char);
}
int main(){
    task01_datatypes();
    return 0;
}