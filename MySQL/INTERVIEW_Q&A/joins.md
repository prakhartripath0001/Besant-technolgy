MySQL JOIN — Hinglish Mein Complete Guide
MySQL mein JOIN ka use do ya zyada tables ka related data combine karne ke liye hota hai.
Simple example: Ek table mein students ke naam hain aur doosre table mein unke courses. JOIN se hum student ka naam aur course ek saath dekh sakte hain.
1. Sample tables
Students
student_id	name	course_id
1	Aman	101
2	Priya	102
3	Rahul	101
4	Neha	NULL
Courses
course_id	course_name
101	Java
102	Python
103	SQL
Ab dekhte hain JOIN ke different types.
2. INNER JOIN







ionos.es


Meaning: Sirf wahi rows return hoti hain jinka match dono tables mein milta hai.
SELECT Students.name, Courses.course_name
FROM Students
INNER JOIN Courses
    ON Students.course_id = Courses.course_id;


Output:
name	course_name
Aman	Java
Priya	Python
Rahul	Java
Neha ka course_id NULL hai, isliye uska matching course nahi mila.
Yaad rakho: INNER JOIN = Only matching records.
3. LEFT JOIN







tableplus.com


Meaning: Left table ki saari rows aayengi, chahe right table mein match mile ya na mile.
SELECT Students.name, Courses.course_name
FROM Students
LEFT JOIN Courses
    ON Students.course_id = Courses.course_id;


Output:
name	course_name
Aman	Java
Priya	Python
Rahul	Java
Neha	NULL
Neha bhi output mein aayegi, kyunki LEFT JOIN left table ke saare students ko preserve karta hai.
Yaad rakho: LEFT JOIN = All left rows + matching right rows.
4. RIGHT JOIN







tableplus.com


Meaning: Right table ki saari rows aayengi, chahe left table mein match ho ya na ho.
SELECT Students.name, Courses.course_name
FROM Students
RIGHT JOIN Courses
    ON Students.course_id = Courses.course_id;


Output:
name	course_name
Aman	Java
Rahul	Java
Priya	Python
NULL	SQL
SQL course ka koi student nahi hai, phir bhi SQL output mein aayega.
Yaad rakho: RIGHT JOIN = All right rows + matching left rows.
5. FULL OUTER JOIN







stratascratch.com


Meaning: Dono tables ki saari rows return hoti hain, matching ho ya na ho.
MySQL mein FULL OUTER JOIN directly supported nahi hai. Iska result LEFT JOIN aur unmatched right-side rows ko UNION karke obtain kar sakte ho.
SELECT Students.name, Courses.course_name
FROM Students
LEFT JOIN Courses
    ON Students.course_id = Courses.course_id

UNION

SELECT Students.name, Courses.course_name
FROM Students
RIGHT JOIN Courses
    ON Students.course_id = Courses.course_id;


Yaad rakho: FULL OUTER JOIN = All left rows + all right rows, matches included.
6. CROSS JOIN







medium.com


Meaning: Dono tables ki har possible combination return hoti hai.
SELECT Students.name, Courses.course_name
FROM Students
CROSS JOIN Courses;


Agar Students mein 4 rows aur Courses mein 3 rows hain, toh output mein \(4 \times 3 = 12\) combinations hongi.
Yaad rakho: CROSS JOIN = Every possible combination.
7. SELF JOIN
Self join mein ek table ko usi table ke saath join karte hain.
Example: Employees aur unke managers find karna.
SELECT
    e.name AS employee,
    m.name AS manager
FROM Employees e
LEFT JOIN Employees m
    ON e.manager_id = m.id;


Yahan e aur m same table ke aliases hain. Is example ke liye Employees table mein manager_id column hona chahiye.
8. Sabhi JOINs ka quick comparison
JOIN type	Kya return karta hai?
INNER JOIN	Sirf matching rows
LEFT JOIN	Saari left rows + matches
RIGHT JOIN	Saari right rows + matches
FULL OUTER JOIN	Dono tables ki saari rows
CROSS JOIN	Har possible combination
SELF JOIN	Table ko khud ke saath join karta hai
