
# SQL: GROUP BY vs HAVING (Hinglish)

Simple words mein samjho:

- `GROUP BY` = Same values wale data ko groups mein divide karna.
- `HAVING` = Un groups par condition lagana.

## 1. Example table: Employees

| id | name  | department | salary |
| -- | ----- | ---------- | ------ |
| 1  | Aman  | IT         | 50000  |
| 2  | Priya | HR         | 40000  |
| 3  | Rahul | IT         | 60000  |
| 4  | Neha  | HR         | 45000  |
| 5  | Karan | Sales      | 35000  |

## 2. GROUP BY kaise kaam karta hai?

Question: Har department mein kitne employees hain?

```
SELECT department, COUNT(*) AS total
FROM Employees
GROUP BY department;
```

Output:

| department | total |
| ---------- | ----- |
| IT         | 2     |
| HR         | 2     |
| Sales      | 1     |

Explanation: `GROUP BY department` same department ke employees ko ek group mein rakhta hai. `COUNT(*)` har group ke employees count karta hai.

## 3. HAVING kaise kaam karta hai?

Question: Sirf un departments ko dikhao jahan 1 se zyada employees hain.

```
SELECT department, COUNT(*) AS total
FROM Employees
GROUP BY department
HAVING COUNT(*) > 1;
```

Output:

| department | total |
| ---------- | ----- |
| IT         | 2     |
| HR         | 2     |

Explanation:

1. `GROUP BY` departments ke groups banata hai.
2. `COUNT(*)` employees count karta hai.
3. `HAVING COUNT(*) > 1` sirf un groups ko rakhta hai jahan employees 1 se zyada hain.

## 4. Main differences

| GROUP BY                                           | HAVING                                                             |
| -------------------------------------------------- | ------------------------------------------------------------------ |
| Groups banata hai                                  | Groups ko filter karta hai                                         |
| Same values ko combine karta hai                   | Group par condition lagata hai                                     |
| Aggregate functions ke saath commonly use hota hai | Aggregate results filter karne ke liye use hota hai                |
| Akela bhi use ho sakta hai                         | Usually grouping ya aggregate results ke context mein use hota hai |

## 5. GROUP BY vs HAVING vs WHERE

Ye interview mein bahut poocha jaata hai.

```
SELECT department, AVG(salary) AS avg_salary
FROM Employees
WHERE salary >= 40000
GROUP BY department
HAVING AVG(salary) > 45000;
```

Is query mein:

- `WHERE` — pehle salary 40,000 se kam wale employees ko hatao.
- `GROUP BY` — baaki employees ko department-wise group karo.
- `HAVING` — sirf un departments ko rakho jinki average salary 45,000 se zyada hai.

Yaad rakhne ka shortcut:

WHERE

Individual rows ko filter karta hai.

GROUP BY

Rows ke groups banata hai.

HAVING

Groups ko filter karta hai.

## 6. Interview practice

Question: Un departments ko find karo jahan total salary 90,000 se zyada hai.

Answer dekho

Interview mein ek line mein bolo: "`GROUP BY` rows ko groups mein organize karta hai, jabki `HAVING` aggregated groups par conditions apply karta hai."
