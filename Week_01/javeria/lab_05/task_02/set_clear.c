#include <stdio.h>

int main() {
    unsigned int num;
    int pos, choice;

    printf("Enter a 32-bit number: ");
    scanf("%u", &num);

    printf("Enter bit position (0-31): ");
    scanf("%d", &pos);

    if (pos < 0 || pos > 31) {
        printf("Error: Bit position must be between 0 and 31.\n");
        return 1;
    }

    printf("Enter choice (1 = Set bit, 0 = Clear bit): ");
    scanf("%d", &choice);

    if (choice == 1) {
        num = num | (1U << pos);
        printf("After setting bit %d: %u\n", pos, num);
    } 
    else if (choice == 0) {
        num = num & ~(1U << pos);
        printf("After clearing bit %d: %u\n", pos, num);
    } 
    else {
        printf("Invalid choice! Use 1 for set, 0 for clear.\n");
    }
    return 0;
}
