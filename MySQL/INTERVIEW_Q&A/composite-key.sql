# Composite Key in SQL — Hinglish Mein

Composite Key ka matlab hai jab 2 ya 2 se zyada columns ko combine karke ek unique key banayi jaati hai.

Simple words mein: Agar ek column akela kisi row ko uniquely identify nahi kar sakta, toh hum multiple columns ko mila kar unique identity bana sakte hain.

## 1. Example samjho

Maan lo humare paas `Enrollments` table hai:

| student_id | course_id | student_name |
| ---------- | --------- | ------------ |
| 101        | 1         | Aman         |
| 101        | 2         | Aman         |
| 102        | 1         | Rahul        |
| 102        | 2         | Rahul        |

Yahan:

- `student_id` akela unique nahi hai, kyunki ek student multiple courses le sakta hai.
- `course_id` akela unique nahi hai, kyunki ek course mein multiple students ho sakte hain.
- Lekin `student_id + course_id` ka combination unique hai.

Isliye hum dono columns ko mila kar Composite Primary Key bana sakte hain.

## 2. SQL code

```
CREATE TABLE Enrollments (
    student_id INT,
    course_id INT,
    student_name VARCHAR(50),
    PRIMARY KEY (student_id, course_id)
);
```

Ab agar ye insert karoge:

```
INSERT INTO Enrollments
VALUES (101, 1, 'Aman');
```

Toh ye valid hai.

Lekin agar same combination dobara insert karoge:

```
INSERT INTO Enrollments
VALUES (101, 1, 'Aman');
```

Toh error aayega, kyunki `(student_id, course_id)` combination pehle se exist karta hai.

Important: `student_id = 101` alag course ke saath valid hai, jaise `(101, 3)`.

## 3. Composite Key vs Primary Key

| Primary Key                          | Composite Key                                      |
| ------------------------------------ | -------------------------------------------------- |
| Ek ya multiple columns ho sakte hain | Hamesha 2 ya zyada columns ka combination hota hai |
| Row ko uniquely identify karti hai   | Combined values se row uniquely identify hoti hai  |
| Example: `student_id`                | Example: `(student_id, course_id)`                 |

Technically, composite key ek multi-column key hoti hai. Jab ise `PRIMARY KEY` ke roop mein define karte hain, toh woh composite primary key kehlati hai.

## 4. Interview mein kaise answer dein?

Question: What is a composite key?

Answer: A composite key is a key made up of two or more columns that together uniquely identify a row in a table.

Hinglish mein: Composite key multiple columns ko combine karke banayi jaati hai, taaki unka combination har row ko uniquely identify kare.
