#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

void task05_reverse_string() {
    int length = 0;
    char str[100];
    printf("enter a string: ");
    scanf("%s", str);
    while (str[length] != '\0') {
        length++;
    }
    int start = 0, end = length - 1;
    char temp;
    while (start < end) {      
        temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
    printf("reversed string: %s\n", str);
}

void task05_second_largest(){
    int second, largest, i, size;

    printf("enter a size of array \n");
    scanf("%d",&size);
    int arr[size];
    printf("enter numbers \n");
    for (i=0; i<size; i++){
        scanf("%d",&arr[i]);
    }
    if (size < 2){
        printf("invalid length \n");
        return;
    }
    if (arr[0] > arr[1]){
        largest = arr[0];
        second = arr[1];
    }else {
        largest = arr[1];
        second = arr[0];
    }
    for (i=2; i<size; i++){
        if (arr[i] > largest){
            second = largest;
            largest = arr[i];            
        }else if ((arr[i] != largest) && (arr[i] > second)){
            second = arr[i];
    }
    }
    if (largest == second){
        printf("elemets are equal \n");
    }else {
        printf("second elemet is %d \n",second);
    }
}
int main(){
    task05_reverse_string();
    task05_second_largest();
    return 0;
}
