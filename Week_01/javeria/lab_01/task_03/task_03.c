#include<stdio.h>
#include <stdlib.h>
#include<time.h>

void task03_fibonacci() {
    int i, n;
    int t1 = 0, t2 = 1;
    int nextterm = t1 + t2;
    printf("\n");
    printf("enter number of terms ");
    scanf("%d", &n);
    printf("fibonacci series: %d, %d, ", t1, t2);
    for (i = 3; i <= n; ++i) {
        printf("%d, ", nextterm);
        t1 = t2;
        t2 = nextterm;
        nextterm = t1 + t2;
    }
}

void task03_guessing_game() {
    int secret_number, guess;
    srand(time(0));
    secret_number = rand() % 100 + 1; 
    printf("\n");
    printf("guess the number between 1 and 100\n");
    while (1) {
        printf("enter your guess: ");
        scanf("%d", &guess);
        if (guess < secret_number) {
            printf("too low \n");
        } else if (guess > secret_number) {
            printf("too high \n");
        } else {
            printf("correct you guessed the number\n");
            break;
        }
    }
}
int main(){
    task03_guessing_game();
    task03_fibonacci();
    return 0;
}