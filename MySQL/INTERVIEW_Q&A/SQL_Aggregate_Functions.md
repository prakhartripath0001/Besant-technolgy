# SQL Aggregate Functions — Hinglish Explanation

SQL mein Aggregate Functions multiple rows ke data ko calculate karke ek single result deti hain.

Simple example: Agar 5 students ke marks diye hain, toh unke total marks, average marks, highest marks ya lowest marks nikalna aggregate functions ka kaam hai.

## 1. Sample table: Students

| id | name  | city   | marks |
| -- | ----- | ------ | ----- |
| 1  | Rahul | Delhi  | 85    |
| 2  | Priya | Mumbai | 92    |
| 3  | Aman  | Delhi  | 70    |
| 4  | Neha  | Pune   | 88    |
| 5  | Karan | Mumbai | 60    |

SQL mein 5 important aggregate functions hain:

1\. COUNT() — Kitne records hain?

```
SELECT COUNT(*) FROM Students;
```

Output: `5`

Meaning: Table mein total 5 rows hain.

2\. SUM() — Total kitna hai?

```
SELECT SUM(marks) FROM Students;
```

Output: `395`

Meaning: Sabhi students ke marks ka total 395 hai.

3\. AVG() — Average kitna hai?

```
SELECT AVG(marks) FROM Students;
```

Output: `79`

Meaning: Average marks 79 hain.

4\. MIN() — Sabse chhoti value

```
SELECT MIN(marks) FROM Students;
```

Output: `60`

Meaning: Sabse kam marks 60 hain.

5\. MAX() — Sabse badi value

```
SELECT MAX(marks) FROM Students;
```

Output: `92`

Meaning: Sabse zyada marks 92 hain.

## 2. Saare functions ek saath

Agar ek hi query mein saari calculations chahiye:

```
SELECT
    COUNT(*) AS total_students,
    SUM(marks) AS total_marks,
    AVG(marks) AS average_marks,
    MIN(marks) AS lowest_marks,
    MAX(marks) AS highest_marks
FROM Students;
```

Output:

| total_students | total_marks | average_marks | lowest_marks | highest_marks |
| -------------- | ----------- | ------------- | ------------ | ------------- |
| 5              | 395         | 79            | 60           | 92            |

`AS` ka use output column ko readable naam dene ke liye hota hai. Isse alias kehte hain.

## 3. GROUP BY ke saath Aggregate Functions

Maan lo har city ke students ke average marks nikalne hain.

```
SELECT city, AVG(marks) AS average_marks
FROM Students
GROUP BY city;
```

Output:

| city   | average_marks |
| ------ | ------------- |
| Delhi  | 77.5          |
| Mumbai | 76            |
| Pune   | 88            |

Yahan `GROUP BY` city-wise groups banata hai aur `AVG()` har group ka average calculate karta hai.

## 4. WHERE vs HAVING with Aggregate Functions

Question: Sirf un cities ko dikhao jahan students ke average marks 80 se zyada hain.

```
SELECT city, AVG(marks) AS average_marks
FROM Students
GROUP BY city
HAVING AVG(marks) > 80;
```

Output:

| city | average_marks |
| ---- | ------------- |
| Pune | 88            |

- `WHERE` individual rows ko filter karta hai, jaise `WHERE marks > 70`.
- `HAVING` grouped aggregate results ko filter karta hai, jaise `HAVING AVG(marks) > 80`.

## 5. COUNT(\*) vs COUNT(column)

Ye interview mein bahut common question hai.

Maan lo table mein `phone` column hai aur kuch students ke phone numbers NULL hain.

```
SELECT COUNT(*) FROM Students;
```

Ye total rows count karega.

```
SELECT COUNT(phone) FROM Students;
```

Ye sirf un rows ko count karega jahan `phone` NULL nahi hai.

Yaad rakho: `COUNT(*)` sabhi rows count karta hai, jabki `COUNT(column)` us column ki non-NULL values count karta hai.

Similarly, `SUM()`, `AVG()`, `MIN()` aur `MAX()` generally NULL values ko ignore karte hain. Agar koi non-NULL input value nahi hai, toh ye functions usually NULL return karte hain.

## 6. Practice questions

Q1. Students ke total marks calculate karo.

395

79

92

5

Check answer

Q2. Students ke average marks calculate karo.

395

79

92

60

Check answer

Q3. Total students count karo.

4

395

5

79

Check answer

Q4. Har city ka highest marks find karo.

Hint: Har city ka alag group banana hoga.

Solution samjhao

Interview ke liye one-line answer: Aggregate functions multiple rows par calculation karke ek result deti hain. Important examples hain `COUNT()`, `SUM()`, `AVG()`, `MIN()` aur `MAX()`.
