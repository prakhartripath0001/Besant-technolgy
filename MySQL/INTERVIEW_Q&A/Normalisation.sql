# SQL Normalization (1NF, 2NF, 3NF) — Detailed Hinglish Notes

Normalization database ko properly organize karne ki technique hai, jisse duplicate data kam hota hai aur data ko insert, update aur delete karna easy hota hai.

Hum sirf 1NF, 2NF aur 3NF cover karenge, examples aur SQL tables ke saath.

## 1. Normalization kya hai?

Maan lo hum ek college database bana rahe hain jisme students, courses aur departments ki information store hoti hai.

Agar hum saara data ek hi table mein rakh dein, toh same student ka naam, course ka naam aur department ki details baar-baar repeat ho sakti hain.

Isse 3 problems aati hain:

- Insertion anomaly: Naya data insert karne mein problem hoti hai.
- Update anomaly: Ek information multiple jagah update karni padti hai.
- Deletion anomaly: Ek record delete karne par galti se doosri important information bhi lose ho sakti hai.

Normalization ka goal in problems ko reduce karna hai.

## 2. First Normal Form (1NF)

Rule: Atomic values

Definition: Table 1NF mein tab hoti hai jab har cell mein ek single, atomic value ho aur repeating groups na hon.

Simple Hinglish mein: Ek cell ke andar multiple values store nahi karni chahiye.

### Example: 1NF se pehle

| student_id | student_name | courses      |
| ---------- | ------------ | ------------ |
| 101        | Aman         | Java, Python |
| 102        | Priya        | SQL, C++     |

Problem: `courses` column ke ek cell mein multiple course names hain.

### 1NF mein convert karo

| student_id | student_name | course |
| ---------- | ------------ | ------ |
| 101        | Aman         | Java   |
| 101        | Aman         | Python |
| 102        | Priya        | SQL    |
| 102        | Priya        | C++    |

Ab har cell mein ek hi course hai.

### SQL example

```
CREATE TABLE StudentCourses (
    student_id INT,
    student_name VARCHAR(50),
    course VARCHAR(50)
);
```

```
INSERT INTO StudentCourses VALUES
(101, 'Aman', 'Java'),
(101, 'Aman', 'Python'),
(102, 'Priya', 'SQL'),
(102, 'Priya', 'C++');
```

Ab har row mein ek course ki value store hoti hai.

### 1NF ke important points

- Har field mein atomic value honi chahiye.
- Ek cell mein comma-separated multiple values store karne se bachna chahiye.
- Repeating groups nahi hone chahiye.
- 1NF automatically duplicate data ko completely remove nahi karti.

Interview answer: 1NF ensures that each field contains a single atomic value and that repeating groups are eliminated.

## 3. Second Normal Form (2NF)

Rule: No partial dependency

Definition: Table 2NF mein tab hoti hai jab woh 1NF mein ho aur har non-prime attribute poori candidate key par depend kare, sirf uske kisi proper subset par nahi.

Simple Hinglish mein: Agar primary key 2 columns se bani hai, toh baaki information dono columns ke combination par depend honi chahiye, sirf ek column par nahi.

### Pehle composite key samjho

Composite key woh key hoti hai jo 2 ya zyada columns se milkar banti hai.

Example:

`(student_id, course_id)`

Maan lo ek student multiple courses le sakta hai aur har course mein multiple students ho sakte hain. Toh student aur course ka combination enrollment ko uniquely identify kar sakta hai.

### Example: 2NF se pehle

| student_id | course_id | student_name | course_name |
| ---------- | --------- | ------------ | ----------- |
| 101        | 1         | Aman         | Java        |
| 101        | 2         | Aman         | Python      |
| 102        | 1         | Priya        | Java        |

Composite primary key:

`(student_id, course_id)`

Ab dependencies dekho:

- `student_id → student_name`
- `course_id → course_name`

Yahan `student_name` sirf `student_id` par depend karta hai. `course_name` sirf `course_id` par depend karta hai.

Ye partial dependency hai, kyunki non-key information composite key ke sirf ek part par depend kar rahi hai.

### 2NF mein convert kaise karein?

Data ko 3 tables mein divide kar do.

Table 1: Students

| student_id (PK) | student_name |
| --------------- | ------------ |
| 101             | Aman         |
| 102             | Priya        |

Table 2: Courses

| course_id (PK) | course_name |
| -------------- | ----------- |
| 1              | Java        |
| 2              | Python      |

Table 3: Enrollments

| student_id (PK, FK) | course_id (PK, FK) |
| ------------------- | ------------------ |
| 101                 | 1                  |
| 101                 | 2                  |
| 102                 | 1                  |

Ab student ka naam `Students` table mein aur course ka naam `Courses` table mein store hoga. `Enrollments` sirf relationship maintain karega.

### SQL example

```
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50)
);

CREATE TABLE Enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
```

### 2NF ke important points

- Table pehle 1NF mein honi chahiye.
- Partial dependency nahi honi chahiye.
- Ye concept particularly composite candidate keys ke case mein important hai.
- Agar table ki har candidate key single-column hai, toh 1NF ke baad partial dependency nahi ho sakti.

Interview answer: 2NF removes partial dependencies, ensuring that every non-prime attribute depends on the whole candidate key.

## 4. Third Normal Form (3NF)

Rule: No transitive dependency

Definition: Table 3NF mein tab hoti hai jab woh 2NF mein ho aur non-prime attributes ki key par inappropriate transitive dependency na ho.

Simple Hinglish mein: Non-key column ko kisi doosre non-key column par indirectly depend nahi karna chahiye.

### Example: 3NF se pehle

| student_id | student_name | department_id | department_name  |
| ---------- | ------------ | ------------- | ---------------- |
| 101        | Aman         | 10            | Computer Science |
| 102        | Priya        | 20            | Mathematics      |
| 103        | Rahul        | 10            | Computer Science |

Maan lo `student_id` primary key hai.

Dependencies:

- `student_id → student_name`
- `student_id → department_id`
- `department_id → department_name`

Iska matlab:

`student_id → department_id → department_name`

Student ID se department name indirectly determine hota hai.

Ye transitive dependency hai.

Problem: Computer Science ka naam multiple rows mein repeat ho raha hai. Department ka naam change karne par multiple rows update karni pad sakti hain.

### 3NF mein convert kaise karein?

Do tables bana do.

Table 1: Students

| student_id (PK) | student_name | department_id (FK) |
| --------------- | ------------ | ------------------ |
| 101             | Aman         | 10                 |
| 102             | Priya        | 20                 |
| 103             | Rahul        | 10                 |

Table 2: Departments

| department_id (PK) | department_name  |
| ------------------ | ---------------- |
| 10                 | Computer Science |
| 20                 | Mathematics      |

Ab department ka naam sirf `Departments` table mein store hoga.

### SQL example

```
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);
```

### 3NF ke important points

- Table pehle 2NF mein honi chahiye.
- Inappropriate transitive dependency remove karni hoti hai.
- Non-key information ko us table mein rakho jahan uski dependency properly represent hoti ho.
- Data redundancy aur update anomalies reduce hoti hain.

Interview answer: 3NF removes inappropriate transitive dependencies so that non-key attributes depend on keys, the whole key, and nothing but the key.

## 5. 1NF vs 2NF vs 3NF

| Feature                | 1NF                                 | 2NF                                             | 3NF                                      |
| ---------------------- | ----------------------------------- | ----------------------------------------------- | ---------------------------------------- |
| Main rule              | Atomic values                       | No partial dependency                           | No inappropriate transitive dependency   |
| Requires previous form | Basic form                          | 1NF                                             | 2NF                                      |
| Main issue addressed   | Multiple values in one field        | Composite key ke ek part par dependency         | Non-key attribute ki indirect dependency |
| Example solution       | Courses ko separate rows mein rakho | Students, Courses aur Enrollments separate karo | Departments ko separate table mein rakho |

Easy trick:

- 1NF: One cell = one value.
- 2NF: Whole key par dependency.
- 3NF: Non-key attribute ki transitive dependency remove karo.

## 6. Interview practice

Q1. Ek cell mein 'Java, Python' store hai. Kaunsi normal form violate ho sakti hai?

1NF

2NF

3NF

Check answer

Q2. Composite key (student_id, course_id) hai aur student_name sirf student_id par depend karta hai. Problem kya hai?

Atomicity

Partial dependency

Transitive dependency

Check answer

Q3. department_id se department_name determine hota hai, jabki student_id se department_id determine hota hai. Ye kya hai?

Partial dependency

Transitive dependency

No dependency

Check answer

Q4. 2NF achieve karne se pehle table ko kis form mein hona chahiye?

1NF

3NF

BCNF

Check answer

Q5. 3NF ka main goal kya hai?

Har column ko primary key banana

Transitive dependency ko address karna

Saare JOINs remove karna

Check answer

## Final revision

Normalization database tables ko systematically organize karne ka process hai.

- 1NF: Har cell mein atomic value.
- 2NF: Partial dependency nahi.
- 3NF: Inappropriate transitive dependency nahi.

In teen definitions ke saath har normal form ka ek example yaad kar lo. Interview mein definition, dependency aur table decomposition explain kar paoge.
