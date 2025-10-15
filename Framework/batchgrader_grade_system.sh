#!/bin/bash

# =====================================================================================
# COP4338 Assignment 2 - Student Grade Management System Batch-Autograder
# Author: Dr. Bhargav Bhatkalkar, KFSCIS, Florida International University  
# Description: This script processes all student submissions and generates grade files
# =====================================================================================

echo "=========================================================================="
echo "  COP4338 Assignment 2 - Student Grade Management System Batch-Autograder "
echo "=========================================================================="
echo "Date: $(date)"
echo

# Check if autograder script exists
if [ ! -f "autograder_grade_system.sh" ]; then
    echo "❌ ERROR: autograder_grade_system.sh not found in current directory!"
    echo "Please place the autograder script in the same directory as this batch script."
    exit 1
fi

# Check if required framework files exist
REQUIRED_FILES=("driver.c" "grade_system.h" "Makefile" "TESTCASES.txt" "EXPECTED_OUTPUT.txt")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ ERROR: Required framework file '$file' not found!"
        echo "Please ensure all framework files are in the current directory."
        exit 1
    fi
done

# Make autograder script executable
chmod +x autograder_grade_system.sh

# Create results directory with fixed name
RESULTS_DIR="GRADING_RESULTS"

# Remove existing results directory if it exists for clean startup
if [ -d "$RESULTS_DIR" ]; then
    echo "Removing existing results directory for clean startup..."
    rm -rf "$RESULTS_DIR"
fi

mkdir -p "$RESULTS_DIR"

# Create summary file
SUMMARY_FILE="$RESULTS_DIR/grading_summary.txt"
echo "COP4338 Assignment 2 - Grade Management System Grading Summary" > "$SUMMARY_FILE"
echo "Generated: $(date)" >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo >> "$SUMMARY_FILE"

# Create detailed log file
LOG_FILE="$RESULTS_DIR/batch_grading.log"
echo "Batch Grading Log - $(date)" > "$LOG_FILE"
echo "=================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

# Master CSV file
MASTER_CSV="$RESULTS_DIR/ALL_GRADES.csv"
echo "zip_filename,final_score" > "$MASTER_CSV"

# Initialize counters
TOTAL_STUDENTS=0
SUCCESSFUL_GRADES=0
FAILED_GRADES=0
PERFECT_SCORES=0

# Required C files for the assignment
REQUIRED_C_FILES=("functions.c")

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to extract student name from filename
extract_student_name() {
    local filename="$1"
    # Remove .zip suffix and try to extract meaningful name
    local base_name=$(basename "$filename" .zip)
    
    # Try different patterns to extract student name
    if [[ "$base_name" =~ ^A2_(.+)$ ]]; then
        # Pattern: A2_FirstName_LastName
        echo "${BASH_REMATCH[1]}" | tr '_' ' '
    elif [[ "$base_name" =~ ^([A-Za-z]+[_\s]+[A-Za-z]+) ]]; then
        # Pattern: FirstName_LastName or FirstName LastName
        echo "${BASH_REMATCH[1]}" | tr '_' ' '
    elif [[ "$base_name" =~ ^([A-Za-z]+_[A-Za-z]+) ]]; then
        # Pattern: FirstName_LastName
        echo "${BASH_REMATCH[1]}" | tr '_' ' '
    else
        # Fallback: use the entire filename (cleaned up)
        echo "$base_name" | tr '_' ' ' | sed 's/[^A-Za-z0-9 ]//g'
    fi
}

# Function to create clean filename
create_clean_name() {
    local name="$1"
    echo "$name" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

# Process all ZIP files in the directory
shopt -s nullglob
zip_files=(*.zip)

if [ ${#zip_files[@]} -eq 0 ]; then
    echo "❌ No ZIP files found in current directory"
    echo "Please ensure student submission ZIP files are in the current directory."
    echo "Supported format: Any .zip file containing the required C implementation files"
    exit 1
fi

log_message "Found ${#zip_files[@]} student submission(s) to process"
log_message ""

# Process each ZIP file
for zip_file in "${zip_files[@]}"; do
    TOTAL_STUDENTS=$((TOTAL_STUDENTS + 1))
    
    # Extract student information
    STUDENT_NAME=$(extract_student_name "$zip_file")
    CLEAN_NAME=$(create_clean_name "$STUDENT_NAME")
    
    # If no meaningful name extracted, use the zip filename
    if [[ -z "$STUDENT_NAME" || "$STUDENT_NAME" =~ ^[[:space:]]*$ ]]; then
        STUDENT_NAME=$(basename "$zip_file" .zip)
        CLEAN_NAME=$(create_clean_name "$STUDENT_NAME")
    fi
    
    log_message "Processing: $STUDENT_NAME ($zip_file)"
    
    # Create temporary directory for extraction
    TEMP_DIR="temp_${CLEAN_NAME}_$$"
    mkdir -p "$TEMP_DIR"
    
    # Extract ZIP file
    log_message "  📦 Extracting submission..."
    if ! unzip -q "$zip_file" -d "$TEMP_DIR" 2>/dev/null; then
        log_message "  ❌ ERROR: Failed to extract $zip_file"
        echo "$STUDENT_NAME: EXTRACTION_FAILED - Could not extract ZIP file" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    # Search for required C files recursively
    log_message "  🔍 Searching for required C files..."
    FOUND_FILES=()
    MISSING_FILES=()
    
    for required_file in "${REQUIRED_C_FILES[@]}"; do
        found_file=$(find "$TEMP_DIR" -name "$required_file" -type f | head -1)
        if [ -n "$found_file" ]; then
            FOUND_FILES+=("$required_file:$found_file")
            log_message "    ✅ Found: $required_file"
        else
            MISSING_FILES+=("$required_file")
            log_message "    ❌ Missing: $required_file"
        fi
    done
    
    # Check for README file recursively (MANDATORY)
    README_FOUND=false
    README_FILE_FOUND=""
    
    found_readme=$(find "$TEMP_DIR" -name "README.pdf" -type f | head -1)
    if [ -z "$found_readme" ]; then
        found_readme=$(find "$TEMP_DIR" -name "README.txt" -type f | head -1)
    fi
    if [ -z "$found_readme" ]; then
        found_readme=$(find "$TEMP_DIR" -name "README.md" -type f | head -1)
    fi
    
    if [ -n "$found_readme" ]; then
        README_FOUND=true
        README_FILE_FOUND=$(basename "$found_readme")
        log_message "    ✅ Found README: $README_FILE_FOUND"
    else
        log_message "    ❌ Missing: README file (MANDATORY - README.pdf, README.txt, or README.md)"
    fi
    
    # Check if at least one required file is found (partial grading)
    if [ ${#FOUND_FILES[@]} -eq 0 ]; then
        log_message "  ❌ ERROR: No required C files found"
        
        # List all C files found for debugging
        log_message "  🔍 All C files found in submission:"
        find "$TEMP_DIR" -name "*.c" -type f | sed 's/^/    /' | tee -a "$LOG_FILE"
        
        echo "$STUDENT_NAME: NO_C_FILES - No required implementation files found" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    # Check for README - MANDATORY
    if [ "$README_FOUND" = false ]; then
        log_message "  ❌ ERROR: No README file found (MANDATORY)"
        echo "$STUDENT_NAME: NO_README - Missing required README" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        rm -rf "$TEMP_DIR"
        continue
    fi
    
    # Copy student files to current directory
    log_message "  📋 Copying student implementation files..."
    for file_info in "${FOUND_FILES[@]}"; do
        file_name=$(echo "$file_info" | cut -d':' -f1)
        file_path=$(echo "$file_info" | cut -d':' -f2)
        
        if ! cp "$file_path" "./$file_name"; then
            log_message "  ❌ ERROR: Failed to copy $file_name"
            echo "$STUDENT_NAME: COPY_FAILED - Could not copy $file_name" >> "$SUMMARY_FILE"
            FAILED_GRADES=$((FAILED_GRADES + 1))
            rm -rf "$TEMP_DIR"
            continue 2
        fi
        
        log_message "    ✅ Copied: $file_name"
    done
    
    # Analyze student's function implementations
    log_message "  🔍 Analyzing function implementations..."

    REQUIRED_FUNCTIONS=(
        "isValidGrade"
        "getLetterGrade"
        "findStudentByID"
        "calculateStudentAverage"
        "addStudent"
        "enterGrade"
        "displayStudentGrades"
        "calculateStatistics"
    )

    IMPLEMENTED_FUNCTIONS=()
    MISSING_FUNCTIONS=()

    for func in "${REQUIRED_FUNCTIONS[@]}"; do
        if grep -q "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]\+${func}[[:space:]]*(" "functions.c" 2>/dev/null; then
            IMPLEMENTED_FUNCTIONS+=("$func")
            log_message "    ✅ Implemented: $func"
        else
            MISSING_FUNCTIONS+=("$func")
            log_message "    ⚠️  Missing: $func (will use stub - 0 points)"
        fi
    done
    
    # Create stub files for missing implementations to prevent compilation errors
    if [ ${#MISSING_FUNCTIONS[@]} -gt 0 ]; then
        log_message "  🔧 Creating stub implementations for missing functions..."
        
        cat >> "functions.c" << 'EOF'

// Stub implementations for missing functions - all return failure/invalid values
EOF

        for func in "${MISSING_FUNCTIONS[@]}"; do
            log_message "    🔧 Adding stub: $func"
            
            case "$func" in
                "isValidGrade")
                    echo "int isValidGrade(float grade) { return OPERATION_INVALID_INPUT; }" >> "functions.c"
                    ;;
                "getLetterGrade")
                    echo "char getLetterGrade(float average) { return 'N'; }" >> "functions.c"
                    ;;
                "findStudentByID")
                    echo "int findStudentByID(int id) { return OPERATION_NOT_FOUND; }" >> "functions.c"
                    ;;
                "calculateStudentAverage")
                    echo "float calculateStudentAverage(int studentIndex) { return -1.0; }" >> "functions.c"
                    ;;
                "addStudent")
                    echo "int addStudent(int studentID) { return OPERATION_INVALID_INPUT; }" >> "functions.c"
                    ;;
                "enterGrade")
                    echo "int enterGrade(int studentID, int assessmentType, float grade) { return OPERATION_INVALID_INPUT; }" >> "functions.c"
                    ;;
                "displayStudentGrades")
                    echo "int displayStudentGrades(int studentID) { return OPERATION_NOT_FOUND; }" >> "functions.c"
                    ;;
                "calculateStatistics")
                    cat >> "functions.c" << 'STUB_EOF'
int calculateStatistics(void) { 
    for(int i = 0; i < 16; i++) assessmentStats[i] = -1.0;
    for(int i = 0; i < 5; i++) gradeDistributionCounts[i] = 0;
    return OPERATION_NOT_FOUND; 
}
STUB_EOF
                    ;;
            esac
        done
    fi
    
    # Look for README file
    README_INFO=""
    if [ -n "$found_readme" ]; then
        README_INFO=$(head -20 "$found_readme" | grep -v "^$")
    fi
    
    # CRITICAL: Clean up any leftover files from previous student
    log_message "  🧹 Pre-cleaning workspace..."
    rm -f STUDENT_OUTPUT.txt grade_system *.o 2>/dev/null
    rm -f expected_*.txt student_*.txt diff_*.txt 2>/dev/null
    rm -f compile_errors.txt runtime_errors.txt 2>/dev/null

    # Ensure we start with a clean build
    if [ -f "Makefile" ]; then
        make clean >/dev/null 2>&1 || true
    fi

    # Look for Makefile (student might have included their own)
    STUDENT_MAKEFILE=$(find "$TEMP_DIR" -iname "makefile*" -type f | head -1)
    if [ -n "$STUDENT_MAKEFILE" ]; then
        log_message "  📄 Found student Makefile: $(basename "$STUDENT_MAKEFILE")"
        log_message "    ⚠️  Using framework Makefile for consistency"
    fi
    
    # Create individual grade report
    GRADE_FILE="$RESULTS_DIR/${CLEAN_NAME}_Grade.txt"

    # CRITICAL: Clean environment before each autograder run
    log_message "  🔄 Ensuring clean environment..."
    unset IS_VALID_GRADE_SCORE GET_LETTER_GRADE_SCORE FIND_STUDENT_SCORE CALCULATE_AVERAGE_SCORE
    unset ADD_STUDENT_SCORE ENTER_GRADE_SCORE DISPLAY_STUDENT_SCORE CALCULATE_STATS_SCORE
    unset COMPILATION_PENALTY RUNTIME_PENALTY
    rm -f STUDENT_OUTPUT.txt grade_system *.o compile_errors.txt runtime_errors.txt 2>/dev/null
    rm -f expected_*.txt student_*.txt diff_*.txt 2>/dev/null
    if [ -f "Makefile" ]; then
        make clean >/dev/null 2>&1 || true
    fi
    sync        # Force filesystem sync
    sleep 1     # Allow for complete cleanup
   
    log_message "  🎯 Running autograder..."
    
    # Generate grade report header
    {
        echo "=========================================================================="
        echo "                   GRADE REPORT FOR: $STUDENT_NAME"
        echo "=========================================================================="
        echo "Submission File: $zip_file"
        echo "Graded on: $(date)"
        echo "Graded by: Grade Management System Autograder"
        echo
        
        if [ -n "$README_INFO" ]; then
            echo "Student Information from README:"
            echo "--------------------------------"
            echo "$README_INFO"
            echo
        fi
        
        echo "Files Submitted:"
        echo "----------------"
        for file_info in "${FOUND_FILES[@]}"; do
            file_name=$(echo "$file_info" | cut -d':' -f1)
            echo "✅ $file_name"
        done
        echo "✅ $README_FILE_FOUND"
        echo
        
        echo "Function Implementation Status:"
        echo "--------------------------------"
        if [ ${#IMPLEMENTED_FUNCTIONS[@]} -gt 0 ]; then
            echo "Implemented (eligible for credit):"
            for func in "${IMPLEMENTED_FUNCTIONS[@]}"; do
                echo "  ✅ $func"
            done
        fi
        
        if [ ${#MISSING_FUNCTIONS[@]} -gt 0 ]; then
            echo
            echo "Not Implemented (0 points - stubs used):"
            for func in "${MISSING_FUNCTIONS[@]}"; do
                echo "  ❌ $func"
            done
        fi
        echo
        
        echo "Implementation Summary: ${#IMPLEMENTED_FUNCTIONS[@]}/${#REQUIRED_FUNCTIONS[@]} functions implemented"
        echo
        echo "Grading Results:"
        echo "================"
        echo
    } > "$GRADE_FILE"
    
    # Run the autograder with timeout protection (18 seconds)
    AUTOGRADER_OUTPUT=$(timeout 18 ./autograder_grade_system.sh 2>&1)
    AUTOGRADER_EXIT_CODE=$?
    
    # Append autograder output to grade file
    echo "$AUTOGRADER_OUTPUT" >> "$GRADE_FILE"
    
    if [ $AUTOGRADER_EXIT_CODE -eq 0 ]; then
        log_message "  ✅ Grading completed successfully"
        
        # Extract final score and percentage from autograder output
        FINAL_SCORE=$(echo "$AUTOGRADER_OUTPUT" | grep "AUTOGRADER TOTAL:" | tail -1 | grep -o '[0-9]\+/[0-9]\+' | head -1)
        PERCENTAGE=$(echo "$AUTOGRADER_OUTPUT" | grep "AUTOGRADER TOTAL:" | grep -o '[0-9]\+%' | head -1)
        
        # Add note about missing functions if applicable
        GRADE_NOTE=""
        if [ ${#MISSING_FUNCTIONS[@]} -gt 0 ]; then
            GRADE_NOTE=" (Missing: ${#MISSING_FUNCTIONS[@]} functions)"
        fi
        
        if [ -n "$FINAL_SCORE" ]; then
            if [ -n "$PERCENTAGE" ]; then
                echo "$STUDENT_NAME: $FINAL_SCORE ($PERCENTAGE)$GRADE_NOTE" >> "$SUMMARY_FILE"
                log_message "  📊 Score: $FINAL_SCORE ($PERCENTAGE)$GRADE_NOTE"
                
                # Export to master CSV
                SCORE_ONLY=$(echo "$FINAL_SCORE" | cut -d'/' -f1)
                echo "$(basename "$zip_file" .zip),$SCORE_ONLY" >> "$MASTER_CSV"
                
                # Check for perfect score (only if no missing functions)
                if [[ "$PERCENTAGE" == "100%" && ${#MISSING_FUNCTIONS[@]} -eq 0 ]]; then
                    PERFECT_SCORES=$((PERFECT_SCORES + 1))
                fi
            else
                echo "$STUDENT_NAME: $FINAL_SCORE$GRADE_NOTE" >> "$SUMMARY_FILE"
                log_message "  📊 Score: $FINAL_SCORE$GRADE_NOTE"
            fi
        else
            echo "$STUDENT_NAME: COMPLETED$GRADE_NOTE - Check individual grade file" >> "$SUMMARY_FILE"
            log_message "  📊 Grading completed$GRADE_NOTE - check grade file for details"
        fi
        
        SUCCESSFUL_GRADES=$((SUCCESSFUL_GRADES + 1))
        
    elif [ $AUTOGRADER_EXIT_CODE -eq 124 ]; then
        log_message "  ⏱️  ERROR: Autograder timed out (18-second limit)"
        echo >> "$GRADE_FILE"
        echo "ERROR: Autograder timed out after 18 seconds" >> "$GRADE_FILE"
        echo "This usually indicates infinite loops in function implementations." >> "$GRADE_FILE"
        echo "Common causes:" >> "$GRADE_FILE"
        echo "- Infinite loops in findStudentByID search function" >> "$GRADE_FILE"
        echo "- Incorrect loop conditions in calculateStatistics" >> "$GRADE_FILE"
        echo "- Missing NULL checks causing segmentation faults" >> "$GRADE_FILE"
        echo "- Incorrect array manipulation in statistics calculations" >> "$GRADE_FILE"
        echo "- Memory allocation issues or array out-of-bounds access" >> "$GRADE_FILE"
        echo "- Infinite loops in grade entry or calculation functions" >> "$GRADE_FILE"
        echo "$STUDENT_NAME: TIMEOUT - Infinite loop or runtime error detected" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
        
    else
        log_message "  ❌ ERROR: Autograder failed (exit code: $AUTOGRADER_EXIT_CODE)"
        echo >> "$GRADE_FILE"
        echo "ERROR: Autograder script failed with exit code: $AUTOGRADER_EXIT_CODE" >> "$GRADE_FILE"
        echo "This could indicate:" >> "$GRADE_FILE"
        echo "- Compilation errors in student code" >> "$GRADE_FILE"
        echo "- Missing function implementations" >> "$GRADE_FILE"
        echo "- Syntax errors or invalid C code" >> "$GRADE_FILE"
        echo "- Incompatible function signatures" >> "$GRADE_FILE"
        echo "- Grade management logic implementation errors" >> "$GRADE_FILE"
        echo "$STUDENT_NAME: AUTOGRADER_FAILED - Compilation or runtime error" >> "$SUMMARY_FILE"
        FAILED_GRADES=$((FAILED_GRADES + 1))
    fi
    
    # Clean up temporary files and student implementation files
    log_message "  🧹 Cleaning up temporary files..."
    chmod -R 755 "$TEMP_DIR" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    
    # Remove student implementation files
    for file in "${REQUIRED_C_FILES[@]}"; do
        rm -f "$file" 2>/dev/null
    done
    
    # Remove any generated files from autograder
    rm -f STUDENT_OUTPUT.txt grade_system *.o 2>/dev/null
    rm -f expected_*.txt student_*.txt diff_*.txt 2>/dev/null
    
    log_message "  💾 Grade saved to: $GRADE_FILE"
    log_message ""
done

# Generate final summary statistics
echo >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo "                        GRADING STATISTICS" >> "$SUMMARY_FILE"
echo "=================================================================" >> "$SUMMARY_FILE"
echo "Total Students Processed: $TOTAL_STUDENTS" >> "$SUMMARY_FILE"
echo "Successfully Graded: $SUCCESSFUL_GRADES" >> "$SUMMARY_FILE"
echo "Failed to Grade: $FAILED_GRADES" >> "$SUMMARY_FILE"
echo "Perfect Scores (100%): $PERFECT_SCORES" >> "$SUMMARY_FILE"

if [ $TOTAL_STUDENTS -gt 0 ]; then
    SUCCESS_RATE=$(( (SUCCESSFUL_GRADES * 100) / TOTAL_STUDENTS ))
    echo "Success Rate: ${SUCCESS_RATE}%" >> "$SUMMARY_FILE"
fi

echo >> "$SUMMARY_FILE"
echo "Common Issues Found:" >> "$SUMMARY_FILE"
echo "- Missing implementation files (results in rejection)" >> "$SUMMARY_FILE"
echo "- Missing README file (results in rejection)" >> "$SUMMARY_FILE"
echo "- Incomplete function implementations (partial credit awarded)" >> "$SUMMARY_FILE"
echo "- Infinite loops in search or calculation functions" >> "$SUMMARY_FILE"
echo "- Array manipulation errors (out-of-bounds access)" >> "$SUMMARY_FILE"
echo "- Incorrect function signatures or return types" >> "$SUMMARY_FILE"
echo "- Compilation errors due to syntax or logic issues" >> "$SUMMARY_FILE"
echo "- Statistics calculation and array population errors" >> "$SUMMARY_FILE"
echo >> "$SUMMARY_FILE"
echo "Individual grade files are in: $RESULTS_DIR/" >> "$SUMMARY_FILE"
echo "Master CSV file: $MASTER_CSV" >> "$SUMMARY_FILE"
echo "Detailed log file: $LOG_FILE" >> "$SUMMARY_FILE"

# Display final results
echo "=========================================================================="
echo "                      BATCH GRADING COMPLETE"
echo "=========================================================================="
echo "📊 Total Students Processed: $TOTAL_STUDENTS"
echo "✅ Successfully Graded: $SUCCESSFUL_GRADES"
echo "❌ Failed to Grade: $FAILED_GRADES"
echo "🌟 Perfect Scores: $PERFECT_SCORES"
[ $TOTAL_STUDENTS -gt 0 ] && echo "📈 Success Rate: ${SUCCESS_RATE}%"
echo
echo "📁 Results Directory: $RESULTS_DIR/"
echo "📋 Summary File: $SUMMARY_FILE"
echo "📊 Master CSV: $MASTER_CSV"
echo "📝 Detailed Log: $LOG_FILE"
echo
echo "📄 Individual Grade Files:"
find "$RESULTS_DIR" -name "*_Grade.txt" -type f | sed 's/^/  /' | sort
echo
echo "⏰ Grading completed at: $(date)"
echo "=========================================================================="

# Final cleanup
echo "🧹 Final cleanup completed."
echo
echo "🎁 Ready for grade submission!"

exit 0