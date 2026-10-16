SQL Aggregate Functions — Hinglish Notes
SQL mein Aggregate Functions multiple rows ke data ko calculate karke ek single result deti hain.
Simple example: Agar 5 students ke marks diye hain, toh unke total marks, average marks, highest marks ya lowest marks nikalna aggregate functions ka kaam hai.
1. Sample Table: Students
id	name	city	marks
1	Rahul	Delhi	85
2	Priya	Mumbai	92
3	Aman	Delhi	70
4	Neha	Pune	88
5	Karan	Mumbai	60


2. Important Aggregate Functions
COUNT() — Kitne records hain?
SELECT COUNT(*) FROM Students;
Output: 5
Meaning: Table mein total 5 rows hain.
SUM() — Total kitna hai?
SELECT SUM(marks) FROM Students;
Output: 395
Meaning: Sabhi students ke marks ka total 395 hai.
AVG() — Average kitna hai?
SELECT AVG(marks) FROM Students;
Output: 79
Meaning: Average marks 79 hain.
MIN() — Sabse chhoti value
SELECT MIN(marks) FROM Students;
Output: 60
Meaning: Sabse kam marks 60 hain.
MAX() — Sabse badi value
SELECT MAX(marks) FROM Students;
Output: 92
Meaning: Sabse zyada marks 92 hain.
3. Saare Functions Ek Saath
SELECT
    COUNT(*) AS total_students,
    SUM(marks) AS total_marks,
    AVG(marks) AS average_marks,
    MIN(marks) AS lowest_marks,
    MAX(marks) AS highest_marks
FROM Students;
Output:
total_students	total_marks	average_marks	lowest_marks	highest_marks
5	395	79	60	92


AS ka use output column ko readable naam dene ke liye hota hai. Isse alias kehte hain.
4. GROUP BY ke Saath Aggregate Functions
Question: Har city ke students ke average marks nikalne hain.
SELECT city, AVG(marks) AS average_marks
FROM Students
GROUP BY city;
Output:
city	average_marks
Delhi	77.5
Mumbai	76
Pune	88


Yahan GROUP BY city-wise groups banata hai aur AVG() har group ka average calculate karta hai.
5. WHERE vs HAVING with Aggregate Functions
Question: Sirf un cities ko dikhao jahan students ke average marks 80 se zyada hain.
SELECT city, AVG(marks) AS average_marks
FROM Students
GROUP BY city
HAVING AVG(marks) > 80;
Output:
city	average_marks
Pune	88


- WHERE individual rows ko filter karta hai, jaise WHERE marks > 70.
- HAVING grouped aggregate results ko filter karta hai, jaise HAVING AVG(marks) > 80.
6. COUNT(*) vs COUNT(column)
Ye interview mein bahut common question hai.
Maan lo table mein phone column hai aur kuch students ke phone numbers NULL hain.
SELECT COUNT(*) FROM Students;
Ye total rows count karega.
SELECT COUNT(phone) FROM Students;
Ye sirf un rows ko count karega jahan phone NULL nahi hai.
Yaad rakho: COUNT(*) sabhi rows count karta hai, jabki COUNT(column) us column ki non-NULL values count karta hai.
Similarly, SUM(), AVG(), MIN() aur MAX() generally NULL values ko ignore karte hain. Agar koi non-NULL input value nahi hai, toh ye functions usually NULL return karte hain.
7. Practice Questions
1. Students ke total marks calculate karo.
2. Students ke average marks calculate karo.
3. Total students count karo.
4. Har city ke highest marks find karo.
Practice Answers
1. Total marks
SELECT SUM(marks) FROM Students;
2. Average marks
SELECT AVG(marks) FROM Students;
3. Total students
SELECT COUNT(*) FROM Students;
4. Har city ka highest marks
SELECT city, MAX(marks)
FROM Students
GROUP BY city;
Interview ke Liye One-Line Answer
Aggregate functions multiple rows par calculation karke ek result deti hain. Important examples hain COUNT(), SUM(), AVG(), MIN() aur MAX().
