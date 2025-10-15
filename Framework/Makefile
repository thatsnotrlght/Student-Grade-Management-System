# ============================================================================
# Compiler settings
CC = gcc
CFLAGS = -std=c17 -Wall -Wextra -Werror -g -O0
LDFLAGS = 

# ============================================================================
# Project settings - Student Grade Management System
TARGET = grade_system
#SOURCES = driver.c functions.c
SOURCES = $(wildcard *.c)
#HEADERS = grade_system.h
HEADERS = $(wildcard *.h)
# ============================================================================
# Build Rules
# ============================================================================

# Default target - builds the grade management system
all: $(TARGET)

# Main build rule - creates the executable
$(TARGET): $(SOURCES) $(HEADERS)
	@echo "Building $(TARGET)..."
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET) $(LDFLAGS)
	@echo "Build successful! Run with: ./$(TARGET)"

# Run the program with simple test cases
test-simple: $(TARGET)
	@echo "Running with simple test cases..."
	./$(TARGET) TESTCASES_SIMPLE.txt

# Run moderate test cases
test-moderate: $(TARGET)
	@echo "Running moderate test cases..."
	./$(TARGET) TESTCASES_MODERATE.txt

# Run rigorous test cases  
test-rigorous: $(TARGET)
	@echo "Running rigorous test cases..."
	./$(TARGET) TESTCASES_RIGOROUS.txt

# Run all test levels
test-all: $(TARGET)
	@echo "Running all test levels..."
	@echo "=== SIMPLE TESTS ==="
	./$(TARGET) TESTCASES_SIMPLE.txt > STUDENT_OUTPUT_SIMPLE.txt
	@echo "=== MODERATE TESTS ==="
	./$(TARGET) TESTCASES_MODERATE.txt > STUDENT_OUTPUT_MODERATE.txt
	@echo "=== RIGOROUS TESTS ==="
	./$(TARGET) TESTCASES_RIGOROUS.txt > STUDENT_OUTPUT_RIGOROUS.txt
	@echo "All test outputs saved!"

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f $(TARGET) *.o STUDENT_OUTPUT*.txt
	@echo "Cleanup complete."

# Rebuild everything from scratch
rebuild: clean all

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make           - Build the program"
	@echo "  make test-simple - Build and run with simple test cases"
	@echo "  make test-moderate - Run moderate test cases"
	@echo "  make test-rigorous - Run rigorous test cases"
	@echo "  make test-all  - Run all test levels and save outputs"
	@echo "  make clean     - Remove generated files"
	@echo "  make rebuild   - Clean and build from scratch"

# Declare phony targets
.PHONY: all test-simple test-moderate test-rigorous test-all clean rebuild help