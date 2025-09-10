#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

// Custom strlen using pointers
int my_strlen( char *s) {
    const char *p = s;
    while (*p){
        p++;
    }
    return p-s;
}

// Custom strcpy using pointers
void my_strcpy(char *dest, const char *src) {
    while (*src) {
        *dest++ = *src++; 
    }
    *dest = '\0';
}

// Custom strcmp using pointers
int my_strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {  
        s1++;
        s2++;
    }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

// Task 2.2: Palindrome checker (case-insensitive)
int is_palindrome( char *s) {
    char *end = s + strlen(s) - 1;
    while (s < end) {
        if (*s != *end) {
            return 1;
        }
        char temp = *s;
        *s++ = *end;
        *end-- = temp;
}
    return 0;
}
int main(){
// --- Part 2 ---
    printf("Len = %d\n", my_strlen("Hello"));
    char buf[100]; my_strcpy(buf,"World");
    printf("Copied: %s\n", buf);
    printf("Palindrome? %s\n", is_palindrome("Madam") ? "Yes":"No");
    return 0;
}
