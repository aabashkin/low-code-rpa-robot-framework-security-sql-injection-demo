CREATE TABLE students (
 id SERIAL PRIMARY KEY,
 name VARCHAR(255) NOT NULL);

CREATE PROCEDURE insert_student(student_name VARCHAR(255))
LANGUAGE SQL
AS $$
    INSERT INTO students (name) VALUES (student_name);
$$;

DROP TABLE students;