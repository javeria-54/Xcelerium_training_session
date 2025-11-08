CC = gcc
TARGET = bitops
TEST_TARGET = bitops.sh

all: build test 

.PHONY: all build test clean

build: $(TARGET)

$(TARGET): bitops.c
	$(CC) -Wall  bitops.c -o $(TARGET)

test: $(TARGET)
	chmod +x $(TEST_TARGET)
	./$(TEST_TARGET)

clean:
	rm -f $(TARGET)
	