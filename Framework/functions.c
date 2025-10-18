/*
 * ============================================================================
 * Description: Student implementation template for Grade Management System
 * 
 * INSTRUCTIONS FOR STUDENTS:
 * 1. Rename this file to "functions.c" before compilation
 * 2. Implement all 8 TODO functions below
 * 3. Do NOT modify function signatures (names, parameters, return types)
 *
 * GRADING: 90 points total distributed among these 8 functions * 
 * ============================================================================
 */

#include "grade_system.h"

#define MIN_GRADE 0.0
#define MAX_GRADE 100.0
#define MAX_STUDENTS 50  
#define ASSESSMENT_QUIZ 1    
#define ASSESSMENT_ASSIGNMENT 2   
#define ASSESSMENT_MIDTERM 3 
#define ASSESSMENT_FINAL 4
extern int studentCount;
extern int studentIDs[MAX_STUDENTS];
extern int gradeDistributionCounts[5];  
extern float assessmentStats[16]; 
extern float quizGrades[MAX_STUDENTS];          
extern float assignmentGrades[MAX_STUDENTS];    
extern float midtermGrades[MAX_STUDENTS];         
extern float finalGrades[MAX_STUDENTS];



/* ============================================================================
 *TODO 1: Validates if a grade is within acceptable range (5 points)
 * ============================================================================
 * Parameter: grade - grade value to validate
 * Returns: OPERATION_SUCCESS (1) if valid, OPERATION_INVALID_INPUT (-1) if invalid
 * Logic: Check if grade is between MIN_GRADE and MAX_GRADE inclusive
*/

int isValidGrade(float grade) {
    // TODO: Implement grade validation logic
    // 🕵️‍♀️HINT: Use MIN_GRADE and MAX_GRADE constants
    return (grade >= MIN_GRADE && grade <= MAX_GRADE) ? OPERATION_SUCCESS : OPERATION_INVALID_INPUT;
}

/* ============================================================================
 * TODO 2: Converts numerical grade to letter grade (5 points)
 * ============================================================================ 
 * Parameter: average - numerical average to convert
 * Returns: letter grade character (A, B, C, D, F, N for no grades)
 * 
 * GRADING SCALE:
 * A: 90.0 and above
 * B: 80.0 to 89.9
 * C: 70.0 to 79.9
 * D: 60.0 to 69.9
 * F: Below 60.0
 * N: Negative input (no grades) 
 */

char getLetterGrade(float average) {
    // TODO: Implement letter grade conversion
    // 🕵️‍♀️HINT: Use if-else ladder with the grading scale above
    if (average >= 90.0) {
        return 'A';
    } else if (average >= 80.0) {
        return 'B';
    } else if (average >= 70.0) {
        return 'C';
    } else if (average >= 60.0) {
        return 'D';
    } else if (average >= 0.0) {
        return 'F';
    } else {
        return 'N';
    }
}

/* ============================================================================
 * TODO 3: Searches for a student by ID using linear search (10 points)
 * ============================================================================ 
 * Parameter: id - student ID to search for
 * Returns: array index if found, OPERATION_NOT_FOUND (0) if not found
 */

int findStudentByID(int id) {
    // TODO: Implement linear search algorithm
    // 🕵️‍♀️HINT: Use for loop and comparison  
    for (int i = 0; i < studentCount; i++) {
        if (studentIDs[i] == id) {
            return i;
        }
    }
    return OPERATION_NOT_FOUND;
}

/* ============================================================================
 * TODO 4: Calculates average grade for a specific student (10 points)
 * ============================================================================ 
 * Calculates average grade for a specific student
 * Parameter: studentIndex - index in the global arrays
 * Returns: average grade or -1.0 if no grades entered or invalid index
 */

float calculateStudentAverage(int studentIndex) {
    // TODO: Implement average calculation
    // 🕵️‍♀️HINT: Count valid grades (>= 0), sum them, return average

    if (studentIndex < 0 || studentIndex >= studentCount) {
        return -1.0;
    }

    float sumOfGrades = 0.0;
    int gradeCount = 0;
    
    if (quizGrades[studentIndex] >= 0.0) {
        sumOfGrades += quizGrades[studentIndex];
        gradeCount++;
    }
    if (assignmentGrades[studentIndex] >= 0.0) {
        sumOfGrades += assignmentGrades[studentIndex];
        gradeCount++;
    }
    if (midtermGrades[studentIndex] >= 0.0) {
        sumOfGrades += midtermGrades[studentIndex];
        gradeCount++;
    }
    if (finalGrades[studentIndex] >= 0.0) {
        sumOfGrades += finalGrades[studentIndex];
        gradeCount++;
    }

    if (gradeCount > 0) {
        return sumOfGrades / gradeCount;
    } else {
        return -1.0;
    }
}

/* ============================================================================
 *  TODO 5: Adds a new student to the system (10 points)
 * ============================================================================ 
 * Parameter: studentID - ID of student to add
 * Returns: Success/error codes based on validation results 
 * 
 * 🕵️‍♀️IMPLEMENTATION HINT:
 * 1. if studentCount >= MAX_STUDENTS, return OPERATION_CAPACITY_ERROR
 * 2. Validate studentID (> 0 and <= MAX_STUDENT_ID), return OPERATION_INVALID_INPUT if invalid
 * 3. Check for duplicate using findStudentByID(), return OPERATION_DUPLICATE_ERROR if found
 * 4. Add student to arrays and initialize grades to GRADE_NOT_ENTERED
 * 5. Increment studentCount
 * 6. Return OPERATION_SUCCESS
 */

int addStudent(int studentID) {
    // TODO: Implement student addition with full validation 
    // 🕵️‍♀️HINT: Validate ID, check duplicates, check capacity, add to arrays 
    if (studentCount >= MAX_STUDENTS) {
        return OPERATION_CAPACITY_ERROR;
    }

    if (!(studentID > 0 && studentID <= MAX_STUDENT_ID)) {
        return OPERATION_INVALID_INPUT;
    }

    int funcIndex = findStudentByID(studentID);
    if (funcIndex != OPERATION_NOT_FOUND) {
        return OPERATION_DUPLICATE_ERROR;
    }

    int studentIdx = studentCount;

    studentIDs[studentIdx] = studentID;

    quizGrades[studentIdx] = GRADE_NOT_ENTERED;          
    assignmentGrades[studentIdx] = GRADE_NOT_ENTERED;     
    midtermGrades[studentIdx] = GRADE_NOT_ENTERED;          
    finalGrades[studentIdx] = GRADE_NOT_ENTERED; 
    
    studentCount++;

    return OPERATION_SUCCESS;
    
}

/* ============================================================================
 *  TODO 6: Enters a grade for a specific student and assessment (10 points)
 * ============================================================================ 
 * Parameters: studentID - ID of student
 *            assessmentType - type of assessment (1-4)
 *            grade - grade value to enter
 * Returns: Success/error codes based on validation
 * 
 * 🕵️‍♀️IMPLEMENTATION HINTS:
 * 1. Find student using findStudentByID(), return OPERATION_NOT_FOUND if not found
 * 2. Validate grade using isValidGrade(), return OPERATION_INVALID_INPUT if invalid
 * 3. Validate assessmentType (1-4), return OPERATION_INVALID_INPUT if invalid
 * 4. Use switch statement to assign grade to correct array based on assessmentType
 * 5. Return OPERATION_SUCCESS
 */

int enterGrade(int studentID, int assessmentType, float grade) {
    // TODO: Implement grade entry with validation
    // 🕵️‍♀️HINT: Find student, validate inputs, update appropriate grade array
    // 🕵️‍♀️HINT: Use switch statement for assessmentType (1=quiz, 2=assignment, 3=midterm, 4=final)

    int studentIdx = findStudentByID(studentID);
    if (studentIdx == OPERATION_NOT_FOUND) {
        return OPERATION_NOT_FOUND;
    }

    if (isValidGrade(grade) != OPERATION_SUCCESS) {
        return OPERATION_INVALID_INPUT;
    }

    if (!(assessmentType >= ASSESSMENT_QUIZ && assessmentType <= ASSESSMENT_FINAL)) {
        return OPERATION_INVALID_INPUT;
    }

    switch (assessmentType){
        case ASSESSMENT_QUIZ:
            quizGrades[studentIdx] = grade;
            break;
        case ASSESSMENT_ASSIGNMENT:
            assignmentGrades[studentIdx] = grade;
            break;
        case ASSESSMENT_MIDTERM:
            midtermGrades[studentIdx] = grade;
            break;
        case ASSESSMENT_FINAL:
            finalGrades[studentIdx] = grade;
            break;
    }

    return OPERATION_SUCCESS;
}

/* ============================================================================
 TODO 7: Retrieves and formats student grade information (10 points)
 * ============================================================================ 
 * Parameter: studentID - ID of student to display
 * Returns: OPERATION_SUCCESS if found, OPERATION_NOT_FOUND if not found
 * 
 * 🕵️‍♀️IMPLEMENTATION HINT:
 * 1. Use findStudentByID() to locate student
 * 2. Return OPERATION_NOT_FOUND if student not found
 * 3. Driver will handle formatting and display
 * 4. Return OPERATION_SUCCESS if student found
 * 
 * NOTE: This function works with the driver to display formatted output
 */

int displayStudentGrades(int studentID) {
    // TODO: Implement student lookup for display
    // 🕵️‍♀️HINT: Find student, get all grades, calculate average and letter grade
    // 🕵️‍♀️HINT: Use findStudentByID() to check if student exists

    int studentIdx = findStudentByID(studentID);

    if (studentIdx == OPERATION_NOT_FOUND) {
        return OPERATION_NOT_FOUND;
    }

    float studentAvg = calculateStudentAverage(studentIdx);
    char letterGrade = getLetterGrade(studentAvg);

    (void)letterGrade;
    (void)studentAvg;

    return OPERATION_SUCCESS;
}

/* ====================================================================================
 * TODO 8: Calculates comprehensive class statistics (30 points) - MAJOR IMPLEMENTATION
 * ===================================================================================== 
 * Parameters: None (uses global arrays)
 * Returns: OPERATION_SUCCESS if calculated, OPERATION_NOT_FOUND if no students
 * 
 * REQUIREMENT: Students must calculate ALL statistics and populate global arrays
 * - assessmentStats[16]: average, count, min, max for each assessment type
 * - gradeDistributionCounts[5]: count of A, B, C, D, F grades
 * 
 * IMPLEMENTATION HINTS:
 * 1. Initialize both global arrays to default values
 * 2. Check if studentCount > 0, return OPERATION_NOT_FOUND if no students
 * 3. For each assessment type (Quiz, Assignment, Midterm, Final): *   
 *    a. Count valid grades
 *    b. Calculate sum, find min and max
 *    c. Calculate average
 *    d. Store results in assessmentStats[i] array
 * 4. Calculate grade distribution: *    
 *    a. Calculate each student's average using calculateStudentAverage()
 *    b. Convert to letter grade using getLetterGrade()
 *    c. Count occurrences of each letter grade
 *    d. Store the letter grade counts in gradeDistributionCounts array
 * 5. Return OPERATION_SUCCESS
 * 
 * ARRAY LAYOUTS:
 * assessmentStats[16]:
 * [0-3] = Quiz: average, count, min, max
 * [4-7] = Assignment: average, count, min, max  
 * [8-11] = Midterm: average, count, min, max
 * [12-15] = Final: average, count, min, max
 * 
 * gradeDistributionCounts[5]:
 * [0] = A count, [1] = B count, [2] = C count, [3] = D count, [4] = F count
 */

int calculateStatistics(void) {
    // Step 1: Initialize global arrays to default values
    for(int i = 0; i < 16; i++) {
        assessmentStats[i] = -1.0;  // -1 indicates no data available
    }
    for(int i = 0; i < 5; i++) {
        gradeDistributionCounts[i] = 0;
    }
    
    // Step 2: Check if students exist
    if(studentCount <= 0) {
        return OPERATION_NOT_FOUND;
    }
    
    // TODO: STUDENTS MUST IMPLEMENT THE ASSESSMENT STATISTICS CALCULATIONS    
    // Step 3: Calculate statistics for each assessment type
    float* gradeArrays[] = {
        quizGrades,
        assignmentGrades,
        midtermGrades,
        finalGrades
    };

    for (int assessment = 0; assessment < 4; assessment++) {
        float sum = 0.0;
        int count = 0;
        float min = MAX_GRADE + 1.0;
        float max = MIN_GRADE - 1.0;

        int statsOffset = assessment * 4;

        for (int i = 0; i < studentCount; i++) {
            float grade = gradeArrays[assessment][i];

            if (grade != GRADE_NOT_ENTERED) {
                sum += grade;
                count++;

                if (grade < min) {
                    min = grade;
                }
                if (grade > max) {
                    max = grade;
                }
            }
        }

        if (count > 0) {
            assessmentStats[statsOffset + 0] = sum / count;
            assessmentStats[statsOffset + 1] = (float)count;
            assessmentStats[statsOffset + 2] = min;
            assessmentStats[statsOffset + 3] = max;
        }

    }

    // TODO: STUDENTS MUST IMPLEMENT GRADE DISTRIBUTION CALCULATION:
    // Step 4: Calculate grade distribution    
    for (int i = 0; i < studentCount; i++) {
        float studentAvg = calculateStudentAverage(i);

        if (studentAvg == GRADE_NOT_ENTERED) {
            continue;
        }

        char letterGrade = getLetterGrade(studentAvg);

        switch(letterGrade) {
            case 'A':
                gradeDistributionCounts[0]++; 
                break;
            case 'B':
                gradeDistributionCounts[1]++; 
                break;
            case 'C':
                gradeDistributionCounts[2]++; 
                break;
            case 'D':
                gradeDistributionCounts[3]++; 
                break;
            case 'F':
                gradeDistributionCounts[4]++; 
                break;
        }
    }
    return OPERATION_SUCCESS; // Only return this after implementing all calculations above
}

