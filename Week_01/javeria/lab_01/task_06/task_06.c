#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

void task06_file_io() {
    int number[5];

    printf("enter 5 numbers \n");
    for (int i=0; i < 5; i++){
        scanf("%d",&number[i]);
    }
    FILE *file;
    file = fopen ("number.txt", "w");
    if (file == NULL){
        printf("unable to write in file \n");
        return;
    }
    for (int i=0; i < 5; i++){
        fprintf (file, "%d\n", number[i]);
    }
    fclose(file);
    file = fopen ("number.txt","r");
    if (file == NULL){
        printf("unable to read from file \n");
        return;
    } 
    printf("number reading from file \n");
    for (int i=0; i<5; i++){
        fscanf(file, "%d", &number[i]);
        printf("%d\n",number[i]);
    }
    fclose(file);
}

int main(){
    task06_file_io();
    return 0;
}
