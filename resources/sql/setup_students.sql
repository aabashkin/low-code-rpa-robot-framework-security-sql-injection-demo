-- Active: 1677570192099@@127.0.0.1@5432@students
CREATE TABLE students (
 id SERIAL PRIMARY KEY,
 name VARCHAR(255) NOT NULL);

INSERT INTO students (name)
VALUES ('Annie'),('Barry'),('Charlie');
