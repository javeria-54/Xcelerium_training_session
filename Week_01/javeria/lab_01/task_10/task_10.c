#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

int task10_cmd_args(int argc, char *argv[]) {
     if (argc != 3) {
        printf("%s <number1> <number2>\n", argv[0]);
        return 1; 
    }

    int num1 = atoi(argv[1]);
    int num2 = atoi(argv[2]);

    int sum = num1 + num2;

    printf("The sum of %d and %d is %d\n", num1, num2, sum);
    return 0;
}

int main(int argc, char *argv[]){
    task10_cmd_args(argc , argv);
    return 0;
}