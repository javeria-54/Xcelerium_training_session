# Makefile for RISC-V Assembly Exercises

# Compiler and emulator
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
SPIKE = spike
PROG = factorial

# Security flags
ASFLAGS = -march=rv64gc
LDFLAGS = -z noexecstack -T linker.ld

# Default target
all: $(PROG)

# Rule to assemble and link
$(PROG): $(PROG).s
	$(AS) $(ASFLAGS) -o $(PROG).o $(PROG).s
	$(LD) $(LDFLAGS) -o $@ $(PROG).o

# Rule to run with Spike
run: $(PROG)
	$(SPIKE) $(PROG)

# Rule to debug with Spike
debug: $(PROG)
	$(SPIKE) -d --log-commits $(PROG)


# Clean up
clean:
	rm -f *.o $(PROG)

.PHONY: all run debug check clean