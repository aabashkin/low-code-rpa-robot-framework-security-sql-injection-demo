/*
 * Copyright (c) 2023 Anton Abashkin
 * SPDX-License-Identifier: MIT
 */

*** Settings ***
Documentation       SQL injection vulnerability demonstration and remediation
Library    RPA.Database
Library    RPA.Excel.Files
Library    RPA.Tables
Library    String
Library    Collections
Suite Setup    Run Keywords    Connect To Students Database
...                            Initialize Colors
Test Setup    Setup Students Database
Test Teardown    Teardown Students Database

*** Variables ***
${DB_MODULE}=    psycopg2
${DB_NAME}=    students
${DB_USER}=    postgres
${DB_PASSWORD}=    test
${DB_HOST}=    127.0.0.1

${GREEN}=    "\\x1b[32m"
${RED}=    "\\x1b[31m"
${WHITE}=    "\x1b[37m"

*** Tasks ***
Insert Students Using Dynamic Query (Insecure)
    @{list_students}=    Get Students From Excel File    resources/new_students.xlsx
    FOR    ${student_name}    IN    @{list_students}

        # Query is insecurely generated using a typical 'Format String' approach
        ${query}=    Format String    INSERT INTO students (name) VALUES ('{}');    ${student_name}

        Log To Console   \n${white}Executing query:\n${query}
        Query    ${query}
        Log To Console    ${green}Success
    END

    Check If Students Table Still Exists

Insert Students Into Database Using Parameterized Query (Secure)
    @{list_students}=    Get Students From Excel File    resources/new_students.xlsx
    FOR    ${student_name}    IN    @{list_students}

        # Query securely generated using parameterization
        # Each database uses a particular style of formatting. Postgres uses %(data)s.
        # For additional information about specific databases see https://bobby-tables.com/python
        ${query}=    Set Variable    INSERT INTO students (name) VALUES (\%s);  

        Log To Console    \n${white}Executing query:\n${query} \nwith student name ${student_name}
        Query    ${query}  data=("${student_name}", )
        Log To Console    ${green}Success
    END

    Check If Students Table Still Exists

Insert Students Into Database Query With Input Validation (Secure)
    @{list_students}=    Get Students From Excel File    resources/new_students.xlsx

    # Regular expression that only allows characters from the Latin alphabet and hyphens
    ${pattern}=    Set Variable    ^[a-zA-Z-]+$

    FOR    ${student_name}    IN    @{list_students}
        TRY
            Log To Console    \n${white}Validating student name: ${student_name}

            # Validate student name using regular expression from above
            ${result}=    Should Match Regexp    ${student_name}    ${pattern}

            ${query}=    Format String    INSERT INTO students (name) VALUES ('{}');    ${student_name}
            Log To Console    ${green}Validation successful, executing query:\n${white}${query}
            Query    ${query}
            Log To Console    ${green}Success
        EXCEPT   * does not match *    type=glob
            Log To Console    ${red}Input validation failed. Student name does not meet requirements.\n
        END
    END
    
    Check If Students Table Still Exists

Insert Students Into Database Using Query With Escaping (Secure)
    @{list_students}=    Get Students From Excel File    resources/new_students.xlsx
    FOR    ${student_name}    IN    @{list_students}

        # Query escapes untrusted input using double dollar quotes $$
        # Note: This style of escaping only works for PostgreSQL databases. 
        # Please review the relevant documentation regarding escaping in your particular database.
        ${query}=    Format String    INSERT INTO students (name) VALUES ($\${}$$);    ${student_name}

        Log To Console    \n${white}Executing query:\n${query}
        Query    ${query}
        Log To Console    ${green}Success
    END
    
    Check If Students Table Still Exists

# TODO: Add Stored Procedure example and explain why it currently doesn't work

*** Keywords ***
Connect To Students Database
    Connect To Database  ${DB_MODULE}    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    autocommit=${TRUE}

Setup Students Database
    Execute Sql Script    resources/sql/setup_students.sql

Teardown Students Database
    TRY
        Execute Sql Script    resources/sql/teardown_students.sql
    EXCEPT    UndefinedTable    type=start
        Log To Console    \n
    END

Get Students From Database
    @{students}=    Query    Select name FROM students
    ${record_count}=    Get Length    ${students}
    RETURN    ${record_count}

Get Students From Excel File
    [Arguments]    ${excel_file_name}
    @{list_students}=    Create List
    Open Workbook    ${excel_file_name}
    ${new_students}=    Read Worksheet As Table
    ${rows}  ${columns}=    Get table dimensions    ${new_students}
    FOR    ${row}    IN RANGE    ${rows}
        ${student_name}=    Get Table Cell    ${new_students}    ${row}    0
        Append To List    ${list_students}    ${student_name}
    END
    RETURN    ${list_students}

Check If Students Table Still Exists
    TRY
        Log To Console    \nChecking if SQL injection was successful...\n\n
        Get Students From Database
        Log To Console    \n${green}Students table still exists, SQL injection unsuccessful!${white}
    EXCEPT    UndefinedTable    type=start
        Log To Console    \n${red}Students table missing, SQL injection was successful!\n\n${white}
    END

Initialize Colors
  ${green}=  Evaluate  ${GREEN}
  Set Suite Variable  ${green}
  ${red}=  Evaluate  ${RED}
  Set Suite Variable  ${red}
  ${white}=  Evaluate  ${WHITE}
  Set Suite Variable  ${white}
