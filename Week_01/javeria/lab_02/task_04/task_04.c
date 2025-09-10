#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

struct Node {
    int data;
    struct Node *next;
};

struct Node* insert_begin(struct Node *head, int value) {
    struct Node *newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = value;
    newNode->next = head;
    return newNode; 
}

struct Node* delete_value(struct Node *head, int value) {
    struct Node *temp = head,
            *prev = NULL;                     

    if (temp != NULL && temp->data == value) {
        head = temp->next;  
        free(temp);         
        return head;
    }
    while (temp != NULL && temp->data != value) {
        prev = temp;
        temp = temp->next;
    }
    if (temp == NULL) return head;

    prev->next = temp->next;
    free(temp);

    return head;
}

void print_list(struct Node *head) {
    struct Node *curr = head;
    while (curr != NULL) {
        printf("%d -> ", curr->data);
        curr = curr->next;
    }
    printf("NULL\n");
}

void task4_1_linkedlist() {
    struct Node *head = NULL;

    head = insert_begin(head, 10);
    head = insert_begin(head, 20);
    head = insert_begin(head, 30);

    printf("List after insertions: ");
    print_list(head);

    head = delete_value(head, 20);

    printf("List after deleting 20: ");
    print_list(head);

    head = delete_value(head, 100);

    printf("List after trying to delete 100: ");
    print_list(head);
}

int main(){
    // --- Part 4 ---
    task4_1_linkedlist();
    return 0;
}
