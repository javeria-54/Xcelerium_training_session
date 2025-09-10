#include<stdio.h>
void task02_calculator() {
   int a, b;
    char op;

    printf("Enter two integers: ");
    scanf("%d %d", &a, &b);

    printf("Choose operation (+ - * / %%): ");
    scanf(" %c", &op);   

    switch (op) {
        case '+':
            printf("result: %d\n", a + b);
            break;
        case '-':
            printf("result: %d\n", a - b);
            break;
        case '*':
            printf("result: %d\n", a * b);
            break;
        case '/':
            if (b != 0)
                printf("result: %d\n", a / b);
            else
                printf("error we canot divide any number by zero\n");
            break;
        case '%':
            if (b != 0)
                printf("result: %d\n", a % b);
            else
                printf("error we cannot take modulus by zero\n");
            break;
        default:
            printf("invalid operator\n");
    }
}
int main(){
    task02_calculator();
    return 0;
}