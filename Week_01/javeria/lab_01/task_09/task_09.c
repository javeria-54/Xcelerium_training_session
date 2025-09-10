#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

struct Point {
    int x;
    int y;
};

void task09_struct_distance() {
    struct Point p1, p2;
    float distance;

    printf("enter point (x y): ");
    scanf("%d %d", &p1.x, &p1.y);

    printf("enter second point (x y): ");
    scanf("%d %d", &p2.x, &p2.y);

    int diff1 , diff2, sum;
    diff1 = pow(p2.x - p1.x, 2);
    diff2 = pow(p2.y - p1.y, 2);
    sum = diff1 + diff2;
    distance = sqrt(sum);

    printf("euclidean distance = %.2f\n", distance);
}
int main(){
    task09_struct_distance();
    return 0;
}