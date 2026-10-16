SQL Triggers — Hinglish Mein Samjho
SQL mein Trigger ek aisa database object hai jo automatically execute hota hai jab koi specific event hota hai, jaise INSERT, UPDATE ya DELETE.
Simple example: Jaise hi company mein koi naya employee add ho, database automatically uski entry ek audit table mein bhi save kar de. Iske liye trigger use kar sakte hain.
1. Trigger kaise kaam karta hai?
Step 1: Event hota hai
INSERT / UPDATE / DELETE

Step 2: Trigger execute hota hai
Database automatically action leta hai

Step 3: Action perform hota hai
Jaise audit log mein record save karna


2. Trigger ke types
Type	Meaning
BEFORE INSERT	Naya record insert hone se pehle
AFTER INSERT	Naya record insert hone ke baad
BEFORE UPDATE	Record update hone se pehle
AFTER UPDATE	Record update hone ke baad
BEFORE DELETE	Record delete hone se pehle
AFTER DELETE	Record delete hone ke baad
Ye common MySQL trigger types hain.
3. Practical example in MySQL
Maan lo humare paas Employees table hai.
CREATE TABLE Employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(30)
);


Ab ek audit table banate hain jisme employee insert hone ka record save hoga.
CREATE TABLE Employee_Audit (
    employee_id INT,
    action_type VARCHAR(20),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


Ab trigger create karo
CREATE TRIGGER after_employee_insert
AFTER INSERT ON Employees
FOR EACH ROW
INSERT INTO Employee_Audit (employee_id, action_type)
VALUES (NEW.id, 'INSERT');


Trigger ko test karo
INSERT INTO Employees
VALUES (1, 'Aman', 'IT');


Ab audit table check karo:
SELECT * FROM Employee_Audit;


Expected result:
employee_id	action_type	action_time
1	INSERT	Current timestamp
Dekha? Humne Employee_Audit mein manually insert nahi kiya. Trigger ne automatically record add kar diya.
4. NEW aur OLD kya hote hain?
- NEW: Nayi row ki values ko access karta hai.
- OLD: Purani row ki values ko access karta hai.
Event	NEW	OLD
INSERT	Haan	Nahi
UPDATE	Haan	Haan
DELETE	Nahi	Haan
Example:
-- UPDATE trigger ke andar
OLD.salary  -- Update se pehle ki salary
NEW.salary  -- Update ke baad ki salary


Is example ke liye Employees table mein salary column hona chahiye.
5. Trigger ke real-world uses
- Employee changes ka audit log maintain karna.
- Product stock changes track karna.
- Salary ya account-related changes ki history rakhna.
- Database mein kuch business rules enforce karna.
6. Trigger vs Stored Procedure
Trigger	Stored Procedure
Specific event par automatically run hota hai	Usually explicitly call karna padta hai
INSERT, UPDATE, DELETE se linked ho sakta hai	Reusable SQL operations ka collection
Event-driven hota hai	Application ya user call kar sakta hai
7. Interview mein kaise answer dena hai?
Question: What is a trigger in SQL?
Answer:
"A trigger is a database object that automatically executes when a specified event, such as INSERT, UPDATE, or DELETE, occurs on a table. It is commonly used for audit logging, tracking changes, and enforcing certain business rules."
Simple Hinglish mein: Trigger database ka automatic helper hai jo specified event hone par khud execute hota hai.
