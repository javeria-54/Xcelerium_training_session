#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

void task08_enum_weekday() {
    enum Weekday {  MONDAY = 1,
                    TUESDAY,
                    WEDNESDAY, 
                    THURSDAY, 
                    FRIDAY, 
                    SATURDAY, 
                    SUNDAY };
    int num;
    printf("enter number 1-7");
    scanf("%d", &num);

    enum Weekday day = num;   

    switch (day) {
        case MONDAY: 
            printf("Monday\n"); 
            break;
        case TUESDAY: 
            printf("Tuesday\n"); 
            break;
        case WEDNESDAY: 
            printf("Wednesday\n"); 
            break;
        case THURSDAY: 
            printf("Thursday\n"); 
            break;
        case FRIDAY: 
            printf("Friday\n"); 
            break;
        case SATURDAY: 
            printf("Saturday\n"); 
            break;
        case SUNDAY: 
            printf("Sunday\n"); 
            break;
        default:  printf("invalid number \n");
    }
}
int main(){
    task08_enum_weekday();
    return 0;
}