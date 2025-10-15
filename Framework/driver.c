/*
 * ============================================================================
 * Description: Test driver for Student Grade Management System * 
 * This driver reads test commands from a file and executes them without
 * user interaction, producing standardized output for autograding.
 * REVISED: Now reads statistics from student-calculated arrays.
 * ============================================================================
 */

#include "grade_system.h"

/* ============================================================================
 * GLOBAL VARIABLE DEFINITIONS
 * ============================================================================ */

/* Student data storage */
int studentCount = 0;
int studentIDs[MAX_STUDENTS];
float quizGrades[MAX_STUDENTS];
float assignmentGrades[MAX_STUDENTS];
float midtermGrades[MAX_STUDENTS];
float finalGrades[MAX_STUDENTS];

/* System statistics */
int totalGradesEntered = 0;

/* Statistics arrays - Students must populate these in calculateStatistics() */
float assessmentStats[16];
int gradeDistributionCounts[5];

/* ============================================================================
 * UTILITY FUNCTIONS
 * ============================================================================ */

void initializeGradeArrays(void) {
    for(int i = 0; i < MAX_STUDENTS; i++) {
        quizGrades[i] = GRADE_NOT_ENTERED;
        assignmentGrades[i] = GRADE_NOT_ENTERED;
        midtermGrades[i] = GRADE_NOT_ENTERED;
        finalGrades[i] = GRADE_NOT_ENTERED;
    }
    
    // Initialize statistics arrays
    for(int i = 0; i < 16; i++) {
        assessmentStats[i] = -1.0;  // -1 indicates no data
    }
    for(int i = 0; i < 5; i++) {
        gradeDistributionCounts[i] = 0;
    }
}

/* ============================================================================
 * OUTPUT FORMATTING FUNCTIONS
 * ============================================================================ */

void formatStudentOutput(int studentIndex) {
    if(studentIndex < 0 || studentIndex >= studentCount) {
        return;
    }
    
    printf("DISPLAY_STUDENT: %d ", studentIDs[studentIndex]);
    
    // Display grades with N/A for unset grades
    if(quizGrades[studentIndex] >= 0) printf("%.1f", quizGrades[studentIndex]);
    else printf("N/A");
    printf(",");
    
    if(assignmentGrades[studentIndex] >= 0) printf("%.1f", assignmentGrades[studentIndex]);
    else printf("N/A");
    printf(",");
    
    if(midtermGrades[studentIndex] >= 0) printf("%.1f", midtermGrades[studentIndex]);
    else printf("N/A");
    printf(",");
    
    if(finalGrades[studentIndex] >= 0) printf("%.1f", finalGrades[studentIndex]);
    else printf("N/A");
    
    // Calculate and display average and letter grade
    float avg = calculateStudentAverage(studentIndex);
    if(avg >= 0) {
        printf(" %.1f %c\n", avg, getLetterGrade(avg));
    } else {
        printf(" N/A N\n");
    }
}

void formatStatisticsOutput(void) {
    if(studentCount == 0) {
        printf("CALCULATE_STATS: NO_STUDENTS\n");
        return;
    }
    
    // REVISED: Read statistics from student-populated arrays instead of calculating here
    printf("CALCULATE_STATS:");
    
    const char* assessmentNames[4] = {"QUIZ", "ASSIGNMENT", "MIDTERM", "FINAL"};
    
    // Display statistics for each assessment type from student calculations
    for(int assess = 0; assess < 4; assess++) {
        int baseIndex = assess * 4;  // 0, 4, 8, 12
        
        // Check if student calculated valid statistics (count > 0)
        if(assessmentStats[baseIndex + 1] > 0) {
            printf(" %s_AVG=%.1f %s_COUNT=%.0f %s_MIN=%.1f %s_MAX=%.1f",
                   assessmentNames[assess], assessmentStats[baseIndex],
                   assessmentNames[assess], assessmentStats[baseIndex + 1],
                   assessmentNames[assess], assessmentStats[baseIndex + 2],
                   assessmentNames[assess], assessmentStats[baseIndex + 3]);
        } else {
            printf(" %s_AVG=N/A %s_COUNT=0 %s_MIN=N/A %s_MAX=N/A",
                   assessmentNames[assess], assessmentNames[assess],
                   assessmentNames[assess], assessmentNames[assess]);
        }
    }
    
    // Display grade distribution from student calculations
    printf(" GRADE_DIST_A=%d GRADE_DIST_B=%d GRADE_DIST_C=%d GRADE_DIST_D=%d GRADE_DIST_F=%d\n",
           gradeDistributionCounts[0], gradeDistributionCounts[1], gradeDistributionCounts[2],
           gradeDistributionCounts[3], gradeDistributionCounts[4]);
}

/* ============================================================================
 * TEST EXECUTION FUNCTIONS
 * ============================================================================ */

void executeAddStudentTest(int studentID) {
    int result = addStudent(studentID);
    
    switch(result) {
        case OPERATION_SUCCESS:
            printf("ADD_STUDENT: SUCCESS\n");
            break;
        case OPERATION_DUPLICATE_ERROR:
            printf("ADD_STUDENT: DUPLICATE_ERROR\n");
            break;
        case OPERATION_INVALID_INPUT:
            printf("ADD_STUDENT: INVALID_INPUT\n");
            break;
        case OPERATION_CAPACITY_ERROR:
            printf("ADD_STUDENT: CAPACITY_ERROR\n");
            break;
        default:
            printf("ADD_STUDENT: UNKNOWN_ERROR\n");
            break;
    }
}

void executeEnterGradeTest(int studentID, int assessmentType, float grade) {
    int result = enterGrade(studentID, assessmentType, grade);
    
    switch(result) {
        case OPERATION_SUCCESS:
            printf("ENTER_GRADE: SUCCESS\n");
            totalGradesEntered++;
            break;
        case OPERATION_NOT_FOUND:
            printf("ENTER_GRADE: STUDENT_NOT_FOUND\n");
            break;
        case OPERATION_INVALID_INPUT:
            printf("ENTER_GRADE: INVALID_INPUT\n");
            break;
        default:
            printf("ENTER_GRADE: UNKNOWN_ERROR\n");
            break;
    }
}

void executeDisplayStudentTest(int studentID) {
    int result = displayStudentGrades(studentID);
    
    if(result == OPERATION_SUCCESS) {
        int studentIndex = findStudentByID(studentID);
        if(studentIndex >= 0) {
            formatStudentOutput(studentIndex);
        }
    } else {
        printf("DISPLAY_STUDENT: STUDENT_NOT_FOUND\n");
    }
}

void executeCalculateStatsTest(void) {
    int result = calculateStatistics();
    
    if(result == OPERATION_SUCCESS || result == OPERATION_NOT_FOUND) {
        formatStatisticsOutput();
    } else {
        printf("CALCULATE_STATS: ERROR\n");
    }
}

void executeValidGradeTest(float grade) {
    int result = isValidGrade(grade);
    
    if(result == OPERATION_SUCCESS) {
        printf("IS_VALID_GRADE: VALID\n");
    } else {
        printf("IS_VALID_GRADE: INVALID\n");
    }
}

void executeLetterGradeTest(float average) {
    char letter = getLetterGrade(average);
    printf("GET_LETTER_GRADE: %c\n", letter);
}

void executeFindStudentTest(int studentID) {
    int result = findStudentByID(studentID);
    
    if(result >= 0) {
        printf("FIND_STUDENT: FOUND %d\n", result);
    } else {
        printf("FIND_STUDENT: NOT_FOUND\n");
    }
}

void executeCalculateAverageTest(int studentID) {
    int studentIndex = findStudentByID(studentID);
    
    if(studentIndex >= 0) {
        float avg = calculateStudentAverage(studentIndex);
        if(avg >= 0) {
            printf("CALCULATE_AVERAGE: %.1f\n", avg);
        } else {
            printf("CALCULATE_AVERAGE: NO_GRADES\n");
        }
    } else {
        printf("CALCULATE_AVERAGE: STUDENT_NOT_FOUND\n");
    }
}

/* ============================================================================
 * MAIN TEST FILE PROCESSOR
 * ============================================================================ */

void processTestFile(const char* filename) {
    FILE* file = fopen(filename, "r");
    if(!file) {
        printf("⚠️ ERROR: Cannot open test file %s. It should be present in this directory.\n", filename);
        printf("💡 NOTE: %s should contain the test cases (it should not be blank).\n", filename);

        return;
    }
    
    char line[256];
    while(fgets(line, sizeof(line), file)) {
        // Remove newline
        line[strcspn(line, "\n")] = 0;
        
        // Skip comments and empty lines
        if(line[0] == '#' || line[0] == '\0') {
            continue;
        }
        
        // Parse test commands
        if(strncmp(line, "TEST_ADD_STUDENT ", 17) == 0) {
            int studentID;
            if(sscanf(line + 17, "%d", &studentID) == 1) {
                executeAddStudentTest(studentID);
            }
        }
        else if(strncmp(line, "TEST_ENTER_GRADE ", 17) == 0) {
            int studentID, assessmentType;
            float grade;
            if(sscanf(line + 17, "%d %d %f", &studentID, &assessmentType, &grade) == 3) {
                executeEnterGradeTest(studentID, assessmentType, grade);
            }
        }
        else if(strncmp(line, "TEST_DISPLAY_STUDENT ", 21) == 0) {
            int studentID;
            if(sscanf(line + 21, "%d", &studentID) == 1) {
                executeDisplayStudentTest(studentID);
            }
        }
        else if(strncmp(line, "TEST_CALCULATE_STATS", 20) == 0) {
            executeCalculateStatsTest();
        }
        else if(strncmp(line, "TEST_IS_VALID_GRADE ", 20) == 0) {
            float grade;
            if(sscanf(line + 20, "%f", &grade) == 1) {
                executeValidGradeTest(grade);
            }
        }
        else if(strncmp(line, "TEST_GET_LETTER_GRADE ", 22) == 0) {
            float average;
            if(sscanf(line + 22, "%f", &average) == 1) {
                executeLetterGradeTest(average);
            }
        }
        else if(strncmp(line, "TEST_FIND_STUDENT ", 18) == 0) {
            int studentID;
            if(sscanf(line + 18, "%d", &studentID) == 1) {
                executeFindStudentTest(studentID);
            }
        }
        else if(strncmp(line, "TEST_CALCULATE_AVERAGE ", 23) == 0) {
            int studentID;
            if(sscanf(line + 23, "%d", &studentID) == 1) {
                executeCalculateAverageTest(studentID);
            }
        }
    }
    
    fclose(file);
}

/* ============================================================================
 * MAIN FUNCTION
 * ============================================================================ */

int main(int argc, char* argv[]) {
    // Initialize system
    initializeGradeArrays();
    
    // Get test file name
    const char* testFile = "TESTCASES.txt";
    if(argc > 1) {
        testFile = argv[1];
    }
    
    // Process test file
    processTestFile(testFile);
    
    return 0;
}