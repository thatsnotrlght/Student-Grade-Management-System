/*
 * ============================================================================
 * Description: Header file for Student Grade Management System 
 * This header file contains all global constants, variables, and function
 * prototypes for the Student Grade Management System autograder version.
 * ⚠️ Students should NOT modify this file as it will be used by the autograder.
 * ============================================================================
 */

#ifndef GRADE_SYSTEM_H
#define GRADE_SYSTEM_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ============================================================================
 * GLOBAL CONSTANTS
 * ============================================================================ */

#define MAX_STUDENTS 50             /* Maximum number of students allowed */
#define MIN_GRADE 0.0               /* Minimum valid grade */
#define MAX_GRADE 100.0             /* Maximum valid grade */
#define GRADE_NOT_ENTERED -1.0      /* Indicator for grade not entered */
#define MAX_STUDENT_ID 9999         /* Maximum allowed student ID */

/* ============================================================================
 * RETURN CODE CONSTANTS FOR AUTOGRADER
 * ============================================================================ */

#define OPERATION_SUCCESS 1          /* Function executed successfully */
#define OPERATION_INVALID_INPUT -1   /* Invalid input parameters */
#define OPERATION_CAPACITY_ERROR -2  /* Array at maximum capacity */
#define OPERATION_DUPLICATE_ERROR -3 /* Duplicate student ID */
#define OPERATION_NOT_FOUND -4        /* Student/data not found */

/* ============================================================================
 * ASSESSMENT TYPE CONSTANTS
 * ============================================================================ */

#define ASSESSMENT_QUIZ 1           /* Quiz assessment type */
#define ASSESSMENT_ASSIGNMENT 2     /* Assignment assessment type */
#define ASSESSMENT_MIDTERM 3        /* Midterm assessment type */
#define ASSESSMENT_FINAL 4          /* Final exam assessment type */

/* ============================================================================
 * GLOBAL VARIABLE - System Statistics and Control
 * ============================================================================ */

extern int totalGradesEntered;      /* Static counter for total grade entries */

/* ============================================================================
 * GLOBAL ARRAYS - Student Data Storage
 * 💡All arrays use parallel structure (same index refers to same student)
 * ============================================================================ */

extern int studentCount;                           /* Current number of students */
extern int studentIDs[MAX_STUDENTS];               /* Array of student IDs */
extern float quizGrades[MAX_STUDENTS];             /* Quiz grades array */
extern float assignmentGrades[MAX_STUDENTS];       /* Assignment grades array */
extern float midtermGrades[MAX_STUDENTS];          /* Midterm grades array */
extern float finalGrades[MAX_STUDENTS];            /* Final exam grades array */

/* ============================================================================
 * GLOBAL ARRAYS - Statistics Arrays (STUDENTS MUST POPULATE THESE)
 * 👍Students must calculate and populate these arrays in calculateStatistics()
 * ============================================================================ */

extern float assessmentStats[16];        /* Student-calculated assessment statistics */
extern int gradeDistributionCounts[5];   /* Student-calculated grade distribution */

/*
 * assessmentStats Array Layout (students must populate):
 * [0] = quiz average,      [1] = quiz count,      [2] = quiz min,      [3] = quiz max
 * [4] = assignment avg,    [5] = assignment count,[6] = assignment min,[7] = assignment max  
 * [8] = midterm average,   [9] = midterm count,   [10] = midterm min,  [11] = midterm max
 * [12] = final average,    [13] = final count,    [14] = final min,    [15] = final max
 * 
 * gradeDistributionCounts Array Layout (students must populate):
 * [0] = count of A grades, [1] = count of B grades, [2] = count of C grades
 * [3] = count of D grades, [4] = count of F grades
 */

/* ============================================================================
 * FUNCTION PROTOTYPES - STUDENT IMPLEMENTATION REQUIRED
 * 👍Students must implement these 8 functions in functions.c *
 * ============================================================================ */

/*
 *TODO 1: Validates if a grade is within acceptable range (5 points)
*/
int isValidGrade(float grade);

/*
 *TODO 2: Converts numerical grade to letter grade (5 points)
*/
char getLetterGrade(float average);

/*
 * TODO 3: Searches for a student by ID using linear search (10 points)
 */
int findStudentByID(int id);

/*
 *TODO 4: Calculates average grade for a specific student (10 points)
*/
float calculateStudentAverage(int studentIndex);

/**
 *TODO 5: Adds a new student to the system (10 points)
 */
int addStudent(int studentID);

/**
 * TODO 6: Enters a grade for a specific student and assessment (10 points)
*/
int enterGrade(int studentID, int assessmentType, float grade);

/**
 * TODO 7: Retrieves and formats student grade information (10 points) 
 */
int displayStudentGrades(int studentID);

/**
 * TODO 8: Calculates comprehensive class statistics (30 points)
 */
int calculateStatistics(void);

/* ============================================================================
 * ❌FUNCTION PROTOTYPES - Driver Support Functions (PROVIDED - DO NOT IMPLEMENT)
 * These functions are implemented in driver.c and used for testing
 * ============================================================================ */

/**
 * Initializes all grade arrays to GRADE_NOT_ENTERED
 */
void initializeGradeArrays(void);

/**
 * Processes test commands from input file
 * Parameter: filename - name of test file to process
 */
void processTestFile(const char* filename);

/**
 * Formats and displays student information for autograder output
 * Parameter: studentIndex - index of student to display
 */
void formatStudentOutput(int studentIndex);

/**
 * Formats and displays statistics for autograder output
 * Reads from student-populated assessmentStats and gradeDistributionCounts arrays
 */
void formatStatisticsOutput(void);

/* ============================================================================
 * END OF HEADER FILE
 * ============================================================================ */

#endif /* GRADE_SYSTEM_H */