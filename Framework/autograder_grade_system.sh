#!/bin/bash

# ===============================================================================
# COP4338 Assignment 2 - Student Grade Management System Autograder
# Author: Dr. Bhargav Bhatkalkar, KFSCIS, Florida International University  
# ===============================================================================

echo "=========================================================================="
echo "   COP4338 Assignment 2 - Student Grade Management System Autograder      "
echo "=========================================================================="
echo "Date: $(date)"
echo

set -euo pipefail

# Configuration
readonly STUDENT_EXEC="grade_system"
readonly TESTCASE_FILE="TESTCASES.txt"
readonly EXPECTED_OUTPUT="EXPECTED_OUTPUT.txt"
readonly STUDENT_OUTPUT="STUDENT_OUTPUT.txt"
readonly MAKEFILE="Makefile"
readonly TIMEOUT_SECONDS=30

# Color codes
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly LIGHT_GREEN='\033[1;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Score tracking - Initialize properly
IS_VALID_GRADE_SCORE=0
GET_LETTER_GRADE_SCORE=0
FIND_STUDENT_SCORE=0
CALCULATE_AVERAGE_SCORE=0
ADD_STUDENT_SCORE=0
ENTER_GRADE_SCORE=0
DISPLAY_STUDENT_SCORE=0
CALCULATE_STATS_SCORE=0
COMPILATION_PENALTY=0
RUNTIME_PENALTY=0

readonly TOTAL_AUTOGRADER_POINTS=90

#==============================================================================
# Utility Functions (Adapted from Reference)
#==============================================================================

log_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

log_info() {
    echo "INFO: $1"
}

log_success() {
    echo -e "${LIGHT_GREEN}SUCCESS: $1${NC}"
}

cleanup() {
    rm -f "$STUDENT_OUTPUT" compile_errors.txt runtime_errors.txt
    rm -f expected_*.txt student_*.txt diff_*.txt
    if [ -f "$MAKEFILE" ]; then
        make clean >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

#==============================================================================
# Section Extraction Functions (Direct from Reference - Proven Algorithms)
#==============================================================================

extract_section_data() {
    local section_prefix="$1"
    local content="$2"  # Content parameter instead of file parameter
    
    if [[ -z "$content" ]]; then
        echo ""
        return
    fi
    
    # Process content directly - exact reference implementation
    echo "$content" | awk -v prefix="^${section_prefix}:" '
        $0 ~ prefix { 
            gsub(/^[[:space:]]+|[[:space:]]+$/, ""); 
            print 
        }' 2>/dev/null || echo ""
}

compare_section_data() {
    local expected_data="$1"
    local student_data="$2"
    local section_name="$3"
    
    # Exact reference logic - handles all edge cases
    if [[ -z "$expected_data" && -z "$student_data" ]]; then
        echo "100"
        return
    fi
    
    if [[ -z "$expected_data" || -z "$student_data" ]]; then
        echo "0"
        return
    fi
    
    # Convert to arrays for line-by-line comparison - reference algorithm
    local -a expected_lines
    local -a student_lines
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            expected_lines+=("$(echo "$line" | tr -s ' ')")
        fi
    done <<< "$expected_data"
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            student_lines+=("$(echo "$line" | tr -s ' ')")
        fi
    done <<< "$student_data"
    
    # Line-by-line comparison - exact reference implementation
    local total_lines=${#expected_lines[@]}
    local correct_lines=0
    
    for ((i=0; i<total_lines; i++)); do
        if [[ i -lt ${#student_lines[@]} && "${expected_lines[i]}" == "${student_lines[i]}" ]]; then
            ((correct_lines++))
        fi
    done
    
    # Penalize extra lines in student output - reference penalty system
    if [[ ${#student_lines[@]} -gt $total_lines ]]; then
        local penalty=$(( ${#student_lines[@]} - total_lines ))
        correct_lines=$(( correct_lines > penalty ? correct_lines - penalty : 0 ))
    fi
    
    # Calculate percentage - reference calculation
    local percentage=0
    if [[ $total_lines -gt 0 ]]; then
        percentage=$(( (correct_lines * 100) / total_lines ))
    fi
    
    echo "$percentage"
}

show_section_differences() {
    local expected_data="$1"
    local student_data="$2"
    local section_name="$3"
    
    # Exact reference display logic
    echo "   Expected Output for $section_name:"
    if [[ -n "$expected_data" ]]; then
        echo "$expected_data" | sed 's/^/      /'
    else
        echo "      (No expected output)"
    fi
    
    echo "   Your Output for $section_name:"
    if [[ -n "$student_data" ]]; then
        # Create arrays for line-by-line comparison - reference method
        local -a expected_lines
        local -a student_lines
        
        # Read expected lines into array
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                expected_lines+=("$(echo "$line" | tr -s ' ')")
            fi
        done <<< "$expected_data"
        
        # Read student lines into array
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                student_lines+=("$(echo "$line" | tr -s ' ')")
            fi
        done <<< "$student_data"
        
        # Compare line by line by position - reference comparison
        for ((i=0; i<${#student_lines[@]}; i++)); do
            local student_line="${student_lines[i]}"
            local mark="❌"
            
            # Check if this line matches the expected line at same position
            if [[ i -lt ${#expected_lines[@]} && "$student_line" == "${expected_lines[i]}" ]]; then
                mark="✅"
            fi
            
            echo "      $mark $student_line"
        done
        
        # Show if student output is missing lines
        if [[ ${#student_lines[@]} -lt ${#expected_lines[@]} ]]; then
            echo "      ❌ (Missing lines...)"
        fi
    else
        echo "      (No output generated)"
    fi
    echo ""
}

#==============================================================================
# Main Functions (Adapted from Reference Structure)
#==============================================================================

check_files() {
    log_info "Checking required files..."
    
    local missing_files=()
    local required_files=("$TESTCASE_FILE" "$EXPECTED_OUTPUT" "$MAKEFILE" 
                         "grade_system.h" "driver.c" "functions.c")
    
    for file in "${required_files[@]}"; do
        [ ! -f "$file" ] && missing_files+=("$file")
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        log_error "Missing files: ${missing_files[*]}"
        exit 1
    fi
    
    echo "All required files found"
}

compile_code() {
    log_info "Compiling student code..."
    
    # Reference compilation logic with penalty system
    if make 2>compile_errors.txt; then
        if [ -s compile_errors.txt ]; then
            log_warning "Compilation warnings detected"
            COMPILATION_PENALTY=2
        else
            echo "Compilation successful"
        fi
    else
        log_error "Compilation failed"
        cat compile_errors.txt
        exit 1
    fi
    
    if [ ! -x "$STUDENT_EXEC" ]; then
        log_error "Executable not created"
        exit 1
    fi
}

run_program() {
    log_info "Running student program..."
    
    # Reference execution logic with sophisticated error handling
    if timeout "$TIMEOUT_SECONDS" ./"$STUDENT_EXEC" "$TESTCASE_FILE" > "$STUDENT_OUTPUT" 2>runtime_errors.txt; then
        echo "Program executed successfully"
        if [ -s runtime_errors.txt ]; then
            log_warning "Runtime warnings detected"
            RUNTIME_PENALTY=1
        fi
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_error "Program timed out (possible infinite loop)"
            RUNTIME_PENALTY=5
        else
            log_error "Program crashed"
            RUNTIME_PENALTY=10
        fi
        # Continue with partial grading - reference approach
    fi
}

grade_functions() {
    log_info "Grading individual function implementations..."
    
    # Cache file contents once - reference efficiency approach
    local expected_content=""
    local student_content=""
    
    if [[ -f "$EXPECTED_OUTPUT" ]]; then
        expected_content=$(cat "$EXPECTED_OUTPUT")
    fi
    
    if [[ -f "$STUDENT_OUTPUT" ]]; then
        student_content=$(cat "$STUDENT_OUTPUT")
    fi
    
    echo ""
    echo "🔍 Testing Function Implementations..."
    echo ""
    
    # Define function sections with updated point distribution
    local sections=("IS_VALID_GRADE:5" "GET_LETTER_GRADE:5" "FIND_STUDENT:10" 
                   "CALCULATE_AVERAGE:10" "ADD_STUDENT:10" "ENTER_GRADE:10"
                   "DISPLAY_STUDENT:10" "CALCULATE_STATS:30")
    
    for section_info in "${sections[@]}"; do
        local section=$(echo "$section_info" | cut -d':' -f1)
        local max_points=$(echo "$section_info" | cut -d':' -f2)
        
        echo "   Testing $section..."
        
        # Extract section data using proven reference algorithms
        local expected_data=$(extract_section_data "$section" "$expected_content")
        local student_data=$(extract_section_data "$section" "$student_content")
        
        # Count lines for debugging - reference debugging approach
        local expected_count=$(echo "$expected_data" | grep -c "^$section:" 2>/dev/null || echo "0")
        local student_count=$(echo "$student_data" | grep -c "^$section:" 2>/dev/null || echo "0")
        
        echo "   Lines found: Expected=$expected_count, Student=$student_count"
        
        # Compare data using reference comparison algorithm
        local match_percentage=0
        if [[ -n "$expected_data" && -n "$student_data" ]]; then
            match_percentage=$(compare_section_data "$expected_data" "$student_data" "$section")
        elif [[ -z "$expected_data" && -z "$student_data" ]]; then
            match_percentage=100
        fi
        
        # Calculate points with reference validation
        local points=0
        if [[ "$match_percentage" =~ ^[0-9]+$ ]]; then
            points=$(( (max_points * match_percentage) / 100 ))
        fi
        
        # Store scores WITHOUT applying penalties per section
        case $section in
            "IS_VALID_GRADE") IS_VALID_GRADE_SCORE=$points ;;
            "GET_LETTER_GRADE") GET_LETTER_GRADE_SCORE=$points ;;
            "FIND_STUDENT") FIND_STUDENT_SCORE=$points ;;
            "CALCULATE_AVERAGE") CALCULATE_AVERAGE_SCORE=$points ;;
            "ADD_STUDENT") ADD_STUDENT_SCORE=$points ;;
            "ENTER_GRADE") ENTER_GRADE_SCORE=$points ;;
            "DISPLAY_STUDENT") DISPLAY_STUDENT_SCORE=$points ;;
            "CALCULATE_STATS") CALCULATE_STATS_SCORE=$points ;;
        esac
        
        # Show results using reference display logic
        if [[ $match_percentage -eq 100 ]]; then
            log_success "$section: Perfect match ($points/$max_points points)"
        else
            log_warning "$section: $match_percentage% match ($points/$max_points points)"
            show_section_differences "$expected_data" "$student_data" "$section"
        fi
    done
}

generate_report() {
    # Calculate raw total score first
    local raw_total=$((IS_VALID_GRADE_SCORE + GET_LETTER_GRADE_SCORE + FIND_STUDENT_SCORE + 
                       CALCULATE_AVERAGE_SCORE + ADD_STUDENT_SCORE + ENTER_GRADE_SCORE + 
                       DISPLAY_STUDENT_SCORE + CALCULATE_STATS_SCORE))
    
    # Apply penalties ONCE to the total score
    local total_score=$((raw_total - COMPILATION_PENALTY - RUNTIME_PENALTY))
    if [[ $total_score -lt 0 ]]; then
        total_score=0
    fi
    
    # Calculate percentage
    local percentage=0
    if [[ $TOTAL_AUTOGRADER_POINTS -gt 0 ]]; then
        percentage=$(( (total_score * 100) / TOTAL_AUTOGRADER_POINTS ))
    fi
    
    echo ""
    echo "=================================================================="
    echo "              AUTOGRADER REPORT"
    echo "=================================================================="
    echo "Date: $(date)"
    echo "Student: $(whoami)"
    echo ""
    echo "COMPILATION & RUNTIME:"
    echo "Compilation: $([ $COMPILATION_PENALTY -eq 0 ] && echo "SUCCESS" || echo "WARNINGS (-$COMPILATION_PENALTY points)")"
    echo "Execution: $([ $RUNTIME_PENALTY -eq 0 ] && echo "SUCCESS" || echo "ISSUES (-$RUNTIME_PENALTY points)")"
    echo ""
    echo "FUNCTION IMPLEMENTATION SCORES:"
    echo "--------------------------------------------------------------"
    echo "Grade Validation (isValidGrade):      $IS_VALID_GRADE_SCORE/5 points ($((IS_VALID_GRADE_SCORE * 100 / 5))%)"
    echo "Letter Grade Conversion:              $GET_LETTER_GRADE_SCORE/5 points ($((GET_LETTER_GRADE_SCORE * 100 / 5))%)"
    echo "Student Search (findStudentByID):     $FIND_STUDENT_SCORE/10 points ($((FIND_STUDENT_SCORE * 100 / 10))%)"
    echo "Average Calculation:                  $CALCULATE_AVERAGE_SCORE/10 points ($((CALCULATE_AVERAGE_SCORE * 100 / 10))%)"
    echo "Student Management (addStudent):      $ADD_STUDENT_SCORE/10 points ($((ADD_STUDENT_SCORE * 100 / 10))%)"
    echo "Grade Entry (enterGrade):             $ENTER_GRADE_SCORE/10 points ($((ENTER_GRADE_SCORE * 100 / 10))%)"
    echo "Student Display:                      $DISPLAY_STUDENT_SCORE/10 points ($((DISPLAY_STUDENT_SCORE * 100 / 10))%)"
    echo "Statistics Calculation:               $CALCULATE_STATS_SCORE/30 points ($((CALCULATE_STATS_SCORE * 100 / 30))%)"
    echo "--------------------------------------------------------------"
    echo "Raw Score (before penalties):         $raw_total/$TOTAL_AUTOGRADER_POINTS points"
    echo "Penalties Applied:                    -$((COMPILATION_PENALTY + RUNTIME_PENALTY)) points"
    echo "--------------------------------------------------------------"
    echo "AUTOGRADER TOTAL:                     $total_score/$TOTAL_AUTOGRADER_POINTS points ($percentage%)"
    echo ""    
    echo "--------------------------------------------------------------"
    echo "Remaining 10 points are manually graded by the instructor based on:"
    echo "• Clear code structure and organization"
    echo "• Meaningful comments and documentation"
    echo "• Well-written README file"
    echo "• Overall code readability and style"    
    echo "--------------------------------------------------------------"    
    
    # Reference performance classification
    if [ $percentage -ge 90 ]; then
        echo "🎉 Autograder Performance: Excellent (A range)"
    elif [ $percentage -ge 80 ]; then
        echo "🌟 Autograder Performance: Good (B range)"
    elif [ $percentage -ge 70 ]; then
        echo "👍 Autograder Performance: Acceptable (C range)"
    elif [ $percentage -ge 60 ]; then
        log_warning "Autograder Performance: Below expectations (D range)"
    else
        log_warning "❌ Autograder Performance: Significant issues (F range)"
    fi
    echo "==================================================================" 
    echo ""
    
    # Reference debug information
    echo "📄 Debug files available for your reference:"
    echo "   - STUDENT_OUTPUT.txt (your program's output)"
    echo "   - EXPECTED_OUTPUT.txt (reference output)"  
    echo "   Run 'diff STUDENT_OUTPUT.txt EXPECTED_OUTPUT.txt' for detailed comparison"
    echo ""
}

#==============================================================================
# Main Execution (Reference Structure)
#==============================================================================

main() {
    # Complete reset for batch grading consistency - reference approach
    unset IS_VALID_GRADE_SCORE GET_LETTER_GRADE_SCORE FIND_STUDENT_SCORE CALCULATE_AVERAGE_SCORE
    unset ADD_STUDENT_SCORE ENTER_GRADE_SCORE DISPLAY_STUDENT_SCORE CALCULATE_STATS_SCORE
    unset COMPILATION_PENALTY RUNTIME_PENALTY
    
    IS_VALID_GRADE_SCORE=0
    GET_LETTER_GRADE_SCORE=0  
    FIND_STUDENT_SCORE=0
    CALCULATE_AVERAGE_SCORE=0
    ADD_STUDENT_SCORE=0
    ENTER_GRADE_SCORE=0
    DISPLAY_STUDENT_SCORE=0
    CALCULATE_STATS_SCORE=0
    COMPILATION_PENALTY=0
    RUNTIME_PENALTY=0
    
    echo "Starting Grade Management System Autograder"
    echo "Grading Rubric: isValidGrade(5) + getLetterGrade(5) + findStudent(10) + calculateAverage(10)"
    echo "               + addStudent(10) + enterGrade(10) + displayStudent(10) + calculateStats(30) = 90 points"
    echo "================================================================================================"
    
    check_files
    compile_code
    run_program
    grade_functions
    generate_report
    
    # Return appropriate exit code - reference exit logic
    local total_score=$((IS_VALID_GRADE_SCORE + GET_LETTER_GRADE_SCORE + FIND_STUDENT_SCORE + 
                         CALCULATE_AVERAGE_SCORE + ADD_STUDENT_SCORE + ENTER_GRADE_SCORE + 
                         DISPLAY_STUDENT_SCORE + CALCULATE_STATS_SCORE))
    
    # Apply penalties to final score
    total_score=$((total_score - COMPILATION_PENALTY - RUNTIME_PENALTY))
    if [[ $total_score -lt 0 ]]; then
        total_score=0
    fi
    
    local percentage=$(( (total_score * 100) / TOTAL_AUTOGRADER_POINTS ))
    
   exit 0
}

# Execute main function
main "$@"