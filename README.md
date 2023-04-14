# Low Code Robot Framework / RPA Framework Security: SQL Injection (SQLi) Demonstration & Prevention Demo

This project demonstrates an SQL injection (SQLi) vulnerability in the Low Code [RPA Framework](https://rpaframework.org/), which is built on the [Robot Framework](https://robotframework.org/) platform. Additionally, it presents proper remediation techniques.

This side by side comparison of secure and insecure implementations can serve as a useful reference for developers, as well as a starting point for further security research.

<br>

## Setup

```bash
git clone https://github.com/aabashkin/low-code-rpa-robot-framework-security-sql-injection-demo
cd low-code-rpa-robot-framework-security-sql-injection-demo
chmod u+x start_postgres_db.sh
./start_postgres_db.sh
```

Install rcc according to [instructions](https://github.com/robocorp/rcc#installing-rcc-from-command-line)

<br>

## Operation

From the root directory of the repo:

```bash
rcc run
```

<br>

## Sample Output

```
==============================================================================
Tasks :: SQL injection vulnerability demonstration and remediation            
==============================================================================

Insert Students Using Dynamic Query (Insecure)  

Executing query:
INSERT INTO students (name) VALUES ('David');
Success

Executing query:
INSERT INTO students (name) VALUES ('Ethan');
Success

Executing query:
INSERT INTO students (name) VALUES ('Robert'); DROP TABLE students; --');
Success

Checking if SQL injection was successful...

[ ERROR ] relation "students" does not exist
LINE 1: Select name FROM students
                         ^

Students table missing, SQL injection was successful!

[ ERROR ] table "students" does not exist

| PASS |
------------------------------------------------------------------------------

Insert Students Into Database Using Parameterized Query (Secure)   

Executing query:
INSERT INTO students (name) VALUES (%s); 
with student name David
Success

Executing query:
INSERT INTO students (name) VALUES (%s); 
with student name Ethan
Success

Executing query:
INSERT INTO students (name) VALUES (%s); 
with student name Robert'); DROP TABLE students; --
Success

Checking if SQL injection was successful...

Students table still exists, SQL injection unsuccessful!

| PASS |
------------------------------------------------------------------------------

Insert Students Into Database Query With Input Validation (Secure) 

Validating student name: David
Validation successful, executing query:
INSERT INTO students (name) VALUES ('David');
Success

Validating student name: Ethan
Validation successful, executing query:
INSERT INTO students (name) VALUES ('Ethan');
Success

Validating student name: Robert'); DROP TABLE students; --
Input validation failed. Student name does not meet requirements.

Checking if SQL injection was successful...

Students table still exists, SQL injection unsuccessful!

| PASS |
------------------------------------------------------------------------------

Insert Students Into Database Using Query With Escaping (Secure) 
     
Executing query:
INSERT INTO students (name) VALUES ($$David$$);
Success

Executing query:
INSERT INTO students (name) VALUES ($$Ethan$$);
Success

Executing query:
INSERT INTO students (name) VALUES ($$Robert'); DROP TABLE students; --$$);
Success

Checking if SQL injection was successful...

Students table still exists, SQL injection unsuccessful!

| PASS |
------------------------------------------------------------------------------
Tasks :: SQL injection vulnerability demonstration and remediation    | PASS |
4 tasks, 4 passed, 0 failed
==============================================================================
```

<br>

## Licensing

[![license](https://img.shields.io/github/license/bkimminich/juice-shop.svg)](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the [MIT license](LICENSE).
Low Code RPA Robot Framework Security SQL Injection Demo and any contributions are Copyright © by Anton Abashkin
2023.
