# SQL Clauses in Hinglish

SQL mein **clause query ka ek part hota hai jo specific kaam karta hai**, jaise data select karna, filter karna, group karna ya sort karna.

## Sample Table: Students

| id | name | city | marks |
|---:|---|---|---:|
| 1 | Rahul | Delhi | 85 |
| 2 | Priya | Mumbai | 92 |
| 3 | Aman | Delhi | 70 |
| 4 | Neha | Pune | 88 |
| 5 | Karan | Mumbai | 60 |

## 1. SELECT — Kya data chahiye?

Specific columns choose karne ke liye `SELECT` use hota hai.

```sql
SELECT name, marks
FROM Students;
```

**Meaning:** Sirf students ke naam aur marks dikhao.

## 2. FROM — Data kahan se lena hai?

`FROM` batata hai ki data kis table se lena hai.

```sql
SELECT *
FROM Students;
```

**Meaning:** Students table ka saara data dikhao. `*` ka matlab all columns hai.

## 3. WHERE — Kaunsi rows chahiye?

`WHERE` condition ke basis par rows filter karta hai.

```sql
SELECT *
FROM Students
WHERE marks > 80;
```

**Meaning:** Sirf un students ko dikhao jinke marks 80 se zyada hain.

## 4. GROUP BY — Same values ko group karo

`GROUP BY` same values wali rows ko groups mein arrange karta hai. Aksar aggregate functions ke saath use hota hai.

```sql
SELECT city, COUNT(*) AS total_students
FROM Students
GROUP BY city;
```

Result:

| city | total_students |
|---|---:|
| Delhi | 2 |
| Mumbai | 2 |
| Pune | 1 |

**Meaning:** Har city mein kitne students hain, woh count karo.

## 5. HAVING — Groups par condition lagao

`HAVING` grouped results ko filter karta hai.

```sql
SELECT city, COUNT(*) AS total_students
FROM Students
GROUP BY city
HAVING COUNT(*) > 1;
```

**Meaning:** Sirf woh cities dikhao jahan ek se zyada students hain.

**Yaad rakho:** `WHERE` rows ko filter karta hai, jabki `HAVING` grouped results ko filter karta hai.

## 6. ORDER BY — Data ko sort karo

```sql
SELECT *
FROM Students
ORDER BY marks DESC;
```

- `ASC` = chhote se bade order mein.
- `DESC` = bade se chhote order mein.

**Meaning:** Sabse zyada marks wale student ko pehle dikhao.

## 7. LIMIT — Kitni rows chahiye?

```sql
SELECT *
FROM Students
ORDER BY marks DESC
LIMIT 3;
```

**Meaning:** Marks ke according top 3 students dikhao.

## 8. DISTINCT — Duplicate values hatao

```sql
SELECT DISTINCT city
FROM Students;
```

**Meaning:** Har city ka naam sirf ek baar dikhao.

## 9. JOIN — Tables ka data combine karo

Maan lo `Students` table mein `course_id` hai aur doosri `Courses` table mein course names hain.

```sql
SELECT Students.name, Courses.course_name
FROM Students
INNER JOIN Courses
    ON Students.course_id = Courses.id;
```

**Meaning:** Students ke naam ke saath unke course names dikhao, jahan matching record ho.

## 10. OFFSET — Shuru ki rows skip karo

```sql
SELECT *
FROM Students
ORDER BY id
LIMIT 2 OFFSET 2;
```

**Meaning:** Pehli 2 rows skip karo aur agali 2 rows dikhao.

## SQL Clauses ka Logical Processing Order

SQL query likhte waqt `SELECT` pehle aata hai, lekin logical processing ka order generally yeh hota hai:

1. `FROM` — table choose karo.
2. `WHERE` — rows filter karo.
3. `GROUP BY` — groups banao.
4. `HAVING` — groups filter karo.
5. `SELECT` — columns/expressions choose karo.
6. `DISTINCT` — duplicate result rows hatao.
7. `ORDER BY` — result sort karo.
8. `LIMIT` / `OFFSET` — returned rows control karo.

Note: Yeh conceptual logical order hai; database ka physical execution plan alag ho sakta hai.

## Practice Question

Is query ka output kya hoga?

```sql
SELECT city, AVG(marks) AS average_marks
FROM Students
WHERE marks >= 70
GROUP BY city
HAVING AVG(marks) > 80
ORDER BY average_marks DESC;
```

### Step-by-step explanation

1. `WHERE marks >= 70`: Karan (60) filter ho jayega.
2. `GROUP BY city`: Remaining students city-wise group honge.
3. `AVG(marks)`: Har city ka average niklega.
4. `HAVING AVG(marks) > 80`: Sirf 80 se zyada average wali cities rahengi.
5. `ORDER BY average_marks DESC`: Average highest se lowest order mein aayega.

Result:

| city | average_marks |
|---|---:|
| Delhi | 77.5 |
| Mumbai | 92 |
| Pune | 88 |

**Correction:** Delhi ka average `(85 + 70) / 2 = 77.5` hai, isliye `HAVING AVG(marks) > 80` ki wajah se Delhi result mein nahi aayega. Final correct result:

| city | average_marks |
|---|---:|
| Mumbai | 92 |
| Pune | 88 |

## Interview ke liye sabse important

In clauses ko achhe se practice karo:

- `SELECT`
- `FROM`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `LIMIT`
- `DISTINCT`
- `JOIN`
- `OFFSET`

Yeh SQL queries ki foundation hain.
