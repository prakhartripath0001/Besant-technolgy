/*
===============================================================================
SQL CORPORATE TRAINING NOTES + INTERVIEW Q&A + MYSQL LABS
Topics requested:
1. SQL clauses
2. GROUP BY vs HAVING
3. Aggregate functions
4. Triggers
5. Views and impact of dropping a view
6. Purpose of GROUP BY
7. UNIQUE vs PRIMARY KEY
8. SQL vs MySQL
9. WHERE vs HAVING (including aggregate conditions)
10. SQL commands: DDL and DML
11. TRUNCATE vs DELETE
12. Pattern matching
13. Joins and types
14. DISTINCT
15. Constraints
16. CTE (Common Table Expression)
17. OFFSET
18. Normalization
19. Additional practice and mock interview queries

HOW TO USE:
- Open this file in MySQL Workbench.
- Run it from top to bottom in a practice environment.
- Detailed theory is written as SQL comments so it remains readable in a .sql file.
- Examples use MySQL syntax.
- Some examples intentionally demonstrate transactions with ROLLBACK.
- The script creates a database named sql_corporate_notes and training tables.
- Do not run destructive statements against production data.
===============================================================================

===============================================================================
SECTION 0 — DATABASE SETUP AND TRAINING DATA
===============================================================================
*/

CREATE DATABASE IF NOT EXISTS sql_corporate_notes;
USE sql_corporate_notes;

DROP VIEW IF EXISTS v_customer_order_summary;
DROP VIEW IF EXISTS v_high_value_products;
DROP TRIGGER IF EXISTS trg_employee_salary_audit;
DROP PROCEDURE IF EXISTS sp_products_by_category;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS salary_audit;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS staging_import;
DROP TABLE IF EXISTS customer_normalized;
DROP TABLE IF EXISTS customer_orders_normalized;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(80) NOT NULL UNIQUE
);

INSERT INTO departments VALUES
(10, 'IT'), (20, 'Sales'), (30, 'HR'), (40, 'Finance');

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NULL,
    manager_id INT NULL,
    salary DECIMAL(12,2) NOT NULL,
    hire_date DATE NOT NULL,
    email VARCHAR(150) UNIQUE,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_employee_salary CHECK (salary >= 0)
);

INSERT INTO employees VALUES
(101, 'Anil Sharma', 10, NULL, 85000, '2021-03-10', 'anil@company.com'),
(102, 'Priya Nair', 10, 101, 72000, '2022-07-15', 'priya@company.com'),
(103, 'John Dsouza', 20, 101, 65000, '2023-01-20', 'john@company.com'),
(104, 'Meera Iyer', 20, 103, 68000, '2020-11-05', 'meera@company.com'),
(105, 'Farhan Khan', 30, 101, 55000, '2024-02-12', 'farhan@company.com'),
(106, 'Kavya Rao', NULL, 101, 50000, '2024-08-01', 'kavya@company.com');

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    city VARCHAR(80)
);

INSERT INTO customers VALUES
(1, 'Aarav Stores', 'aarav@example.com', 'Bengaluru'),
(2, 'BlueSky Retail', 'bluesky@example.com', 'Mumbai'),
(3, 'Cedar Mart', 'cedar@example.com', 'Delhi'),
(4, 'Delta Shop', 'delta@example.com', 'Chennai'),
(5, 'Evergreen Retail', 'evergreen@example.com', NULL);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock >= 0)
);

INSERT INTO products VALUES
(201, 'Keyboard', 'Accessories', 1200, 50),
(202, 'Mouse', 'Accessories', 600, 100),
(203, 'Monitor', 'Hardware', 9500, 20),
(204, 'Laptop', 'Hardware', 65000, 10),
(205, 'Webcam', 'Accessories', 2200, 35),
(206, 'USB Hub', 'Accessories', 1500, 25);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(1001, 1, '2025-01-05', 'Shipped'),
(1002, 2, '2025-01-12', 'Pending'),
(1003, 1, '2025-02-03', 'Shipped'),
(1004, 3, '2025-02-18', 'Cancelled'),
(1005, 4, '2025-03-01', 'Shipped');

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_product
        FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0)
);

INSERT INTO order_items VALUES
(1, 1001, 201, 2, 1200),
(2, 1001, 202, 3, 600),
(3, 1002, 204, 1, 65000),
(4, 1003, 203, 2, 9500),
(5, 1004, 205, 1, 2200),
(6, 1005, 206, 4, 1500);

CREATE TABLE staging_import (
    import_id INT AUTO_INCREMENT PRIMARY KEY,
    raw_value VARCHAR(200)
);

INSERT INTO staging_import (raw_value)
VALUES ('row A'), ('row B'), ('row C');

/*
===============================================================================
SECTION 1 — WHAT ARE SQL CLAUSES?
===============================================================================

THEORY
------
A clause is a component of a SQL statement that performs a defined job.
A SELECT query commonly contains:
- SELECT: chooses the output columns or expressions.
- FROM: specifies the source table(s) or other data source.
- JOIN ... ON: combines rows using a relationship or matching condition.
- WHERE: filters individual source rows before grouping.
- GROUP BY: combines rows into groups that share values.
- HAVING: filters groups, often using aggregate calculations.
- ORDER BY: sorts the final result.
- LIMIT: restricts the number of rows returned.
- OFFSET: skips a specified number of rows before returning results.

A typical written query:
SELECT columns
FROM tables
WHERE row_condition
GROUP BY grouping_columns
HAVING group_condition
ORDER BY sort_columns
LIMIT row_count OFFSET rows_to_skip;

A simplified logical processing order is:
FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT.
This is a conceptual order, not a guarantee of the physical execution plan.
The MySQL optimizer may choose a different physical plan to improve performance.

BUSINESS USE
------------
Clauses let analysts build reports such as sales by category, customers with
high spending, employees by department, or products with low stock.
*/

SELECT product_name, price
FROM products
WHERE price >= 1000
ORDER BY price DESC
LIMIT 5;

/*
PRACTICE TASKS
1. List products costing more than 2000.
2. Sort products from cheapest to most expensive.
3. Return the three most expensive products.
4. List orders that are Shipped.
5. Display products in the Hardware category costing more than 5000.
*/
SELECT * FROM products WHERE price > 2000;
SELECT * FROM products ORDER BY price ASC;
SELECT * FROM products ORDER BY price DESC LIMIT 3;
SELECT * FROM orders WHERE status = 'Shipped';
SELECT * FROM products WHERE category = 'Hardware' AND price > 5000;

/*
INTERVIEW Q&A
Q1. What is a SQL clause?
A. A component of a statement that specifies an operation such as selecting,
   filtering, grouping, sorting, or limiting data.
Q2. Can WHERE and HAVING be used together?
A. Yes. WHERE filters rows before grouping; HAVING filters groups afterward.
Q3. Why is ORDER BY important?
A. It gives a requested sort order. Without ORDER BY, row order is not guaranteed.
Q4. What does LIMIT do in MySQL?
A. It limits how many rows are returned.
Q5. Is written clause order the same as logical processing order?
A. No. For example, WHERE is logically evaluated before GROUP BY and SELECT.
*/

/*
===============================================================================
SECTION 2 — GROUP BY VS HAVING; PURPOSE OF GROUP BY
===============================================================================

THEORY
------
GROUP BY groups rows with matching values in one or more columns. It is often
paired with COUNT, SUM, AVG, MIN, and MAX to summarize each group.
HAVING filters the groups after grouping and aggregation.

WHERE vs GROUP BY vs HAVING:
- WHERE: selects which individual rows participate.
- GROUP BY: determines how those rows are grouped.
- HAVING: determines which completed groups remain in the output.

Example: total sales by customer, considering shipped orders only:
1. WHERE keeps only shipped orders.
2. GROUP BY creates a group for each customer.
3. SUM calculates each customer's revenue.
4. HAVING can remove groups whose revenue is below a threshold.

In MySQL, avoid selecting arbitrary nonaggregated columns that are not
included in GROUP BY. With ONLY_FULL_GROUP_BY enabled, MySQL rejects many
ambiguous queries. Use explicit grouping columns for predictable reports.

BUSINESS USE
------------
Department headcount, monthly revenue, average salary, order counts by status,
and products whose total sales exceed a target.
*/

-- Number of employees per department (including NULL department as a group).
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;

-- Total order-line revenue by product.
SELECT product_id,
       SUM(quantity * unit_price) AS product_revenue
FROM order_items
GROUP BY product_id;

-- Groups with at least two employees.
SELECT department_id, COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 2;

-- Row filter first, then group and filter the groups.
SELECT customer_id,
       COUNT(*) AS shipped_orders
FROM orders
WHERE status = 'Shipped'
GROUP BY customer_id
HAVING COUNT(*) >= 1;

/*
PRACTICE TASKS
1. Count employees in each department.
2. Calculate average salary for each department.
3. Show departments with an average salary above 60000.
4. Calculate revenue for each product.
5. Show customers with more than one order.
*/
SELECT department_id, COUNT(*) AS employee_count
FROM employees GROUP BY department_id;

SELECT department_id, AVG(salary) AS average_salary
FROM employees GROUP BY department_id;

SELECT department_id, AVG(salary) AS average_salary
FROM employees GROUP BY department_id
HAVING AVG(salary) > 60000;

SELECT product_id, SUM(quantity * unit_price) AS revenue
FROM order_items GROUP BY product_id;

SELECT customer_id, COUNT(*) AS order_count
FROM orders GROUP BY customer_id
HAVING COUNT(*) > 1;

/*
INTERVIEW Q&A
Q1. What is GROUP BY used for?
A. It groups rows so aggregates can calculate a summary for each group.
Q2. What is the difference between GROUP BY and HAVING?
A. GROUP BY creates groups; HAVING filters the groups.
Q3. Can HAVING be used without GROUP BY?
A. Yes. In MySQL, HAVING can filter an aggregate result for a single implicit
   group, although WHERE is usually the correct choice for row-level filtering.
Q4. Can we use aggregate functions in HAVING?
A. Yes. Example: HAVING SUM(amount) > 10000.
Q5. Can WHERE contain SUM() directly?
A. Generally not as a direct row condition. Filter aggregate results in HAVING
   or use a subquery/CTE that calculates the aggregate first.
*/

/*
===============================================================================
SECTION 3 — AGGREGATE FUNCTIONS
===============================================================================

THEORY
------
Aggregate functions summarize values from many rows:
- COUNT(*): counts rows.
- COUNT(column): counts rows where that expression is not NULL.
- COUNT(DISTINCT column): counts distinct non-NULL values.
- SUM(expression): totals non-NULL numeric values.
- AVG(expression): averages non-NULL numeric values.
- MIN(expression): lowest value.
- MAX(expression): highest value.

Except for COUNT, aggregate functions generally return NULL when there are
no non-NULL input values. SUM and AVG ignore NULL values. When grouping is
used, each aggregate is calculated separately for each group.

For financial values, DECIMAL is usually preferable to FLOAT/DOUBLE because
DECIMAL supports exact decimal arithmetic within its defined precision.

BUSINESS USE
------------
Revenue, average basket value, inventory value, minimum/maximum prices,
employee headcount, and unique customer counts.
*/

SELECT
    COUNT(*) AS product_count,
    COUNT(category) AS non_null_categories,
    SUM(stock) AS units_in_stock,
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM products;

SELECT
    SUM(quantity * unit_price) AS gross_order_line_value
FROM order_items;

SELECT
    COUNT(DISTINCT customer_id) AS unique_ordering_customers
FROM orders;

/*
PRACTICE TASKS
1. Count all customers.
2. Find the highest and lowest product prices.
3. Calculate total stock across products.
4. Calculate average employee salary.
5. Calculate total order-line value for each order.
*/
SELECT COUNT(*) AS customer_count FROM customers;
SELECT MAX(price) AS highest_price, MIN(price) AS lowest_price FROM products;
SELECT SUM(stock) AS total_stock FROM products;
SELECT AVG(salary) AS average_salary FROM employees;
SELECT order_id, SUM(quantity * unit_price) AS order_value
FROM order_items GROUP BY order_id;

/*
INTERVIEW Q&A
Q1. What is an aggregate function?
A. A function that summarizes a set of values into a result.
Q2. COUNT(*) vs COUNT(column)?
A. COUNT(*) counts rows; COUNT(column) ignores NULL values in that column.
Q3. Does AVG include NULL values?
A. No. AVG ignores NULL inputs.
Q4. Can aggregate functions be combined with GROUP BY?
A. Yes. This is one of their most common uses.
Q5. How do you count unique customers?
A. COUNT(DISTINCT customer_id).
*/

/*
===============================================================================
SECTION 4 — TRIGGERS
===============================================================================

THEORY
------
A trigger is a database object that runs automatically when a defined event
occurs on a table. MySQL supports BEFORE and AFTER triggers for INSERT,
UPDATE, and DELETE.

Trigger concepts:
- BEFORE triggers run before the row operation.
- AFTER triggers run after the row operation.
- FOR EACH ROW means the trigger runs for each affected row.
- OLD refers to the prior row values for UPDATE/DELETE contexts.
- NEW refers to the incoming or updated row values for INSERT/UPDATE contexts.
- OLD and NEW availability depends on event and timing.

A trigger can help audit changes or enforce rules close to the data. However,
triggers can make behavior less visible to application developers, add work to
writes, and introduce debugging complexity. Avoid using triggers as a hidden
replacement for a clearly designed application workflow.

MySQL triggers execute as part of the statement/transaction for transactional
tables such as InnoDB. A failed trigger can cause the statement to fail.

BUSINESS USE
------------
Auditing salary changes, recording sensitive account updates, maintaining
change history, and validating data before it is stored.
*/

CREATE TABLE salary_audit (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    old_salary DECIMAL(12,2),
    new_salary DECIMAL(12,2),
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT (CURRENT_USER())
);

DELIMITER //
CREATE TRIGGER trg_employee_salary_audit
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary)
        VALUES (OLD.employee_id, OLD.salary, NEW.salary);
    END IF;
END //
DELIMITER ;

-- Demonstration: change a salary, then inspect the audit record.
-- Run in a training database only.
UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 102;

SELECT * FROM salary_audit;

/*
PRACTICE TASKS
1. Create a BEFORE INSERT trigger that rejects a negative price (CHECK is
   usually simpler and preferred for this simple rule).
2. Create an AFTER INSERT trigger that logs new orders.
3. Create an AFTER DELETE trigger that records deleted product identifiers.
4. Explain OLD and NEW for UPDATE.
5. Explain one disadvantage of triggers.
Suggested approach for task 1: use a CHECK constraint where supported, because
it declares the rule directly and is easier to maintain than a trigger.
*/

/*
INTERVIEW Q&A
Q1. What is a trigger?
A. A stored database program automatically executed for a table event.
Q2. Which trigger events does MySQL support?
A. INSERT, UPDATE, and DELETE, with BEFORE or AFTER timing.
Q3. What are OLD and NEW?
A. Pseudorecords for previous and incoming/current row values, where applicable.
Q4. Can a trigger be called directly like a stored procedure?
A. No. It fires in response to its configured table event.
Q5. What is a disadvantage of triggers?
A. They can hide logic, complicate debugging, and add overhead to data changes.
*/

/*
===============================================================================
SECTION 5 — VIEWS; CAN WE DELETE A VIEW?
===============================================================================

THEORY
------
A view is a named SELECT query exposed as a virtual table. A normal MySQL view
stores its definition, not an independent copy of the underlying result rows.
When queried, the view generally reads from its underlying tables.

Benefits:
- Simplifies complex joins and reusable reports.
- Limits exposed columns/rows for different teams.
- Provides a stable interface for reporting queries.
- Can improve maintainability when many reports reuse the same definition.

Limitations:
- A view is not automatically a performance cache.
- Some views are not updatable, especially those using grouping, aggregates,
  DISTINCT, UNION, or other constructs that prevent direct row mapping.
- A view is not by itself a complete security strategy; permissions matter.

DROP VIEW removes the view definition. It does NOT drop the base table or
delete the underlying table's records.
Important distinction: DML issued through an updatable view can modify the
underlying table. DROP VIEW itself does not delete base-table data.

BUSINESS USE
------------
A customer support team may use a customer summary view while a finance team
uses a revenue summary view. Grant access to appropriate views and restrict
underlying-table permissions as needed.
*/

CREATE OR REPLACE VIEW v_high_value_products AS
SELECT product_id, product_name, category, price
FROM products
WHERE price >= 5000;

SELECT * FROM v_high_value_products;

CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT c.customer_id,
       c.customer_name,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

SELECT * FROM v_customer_order_summary;

-- Safe demonstration: drop the view, then verify the base table still exists.
DROP VIEW IF EXISTS v_high_value_products;
SHOW TABLES;
SELECT COUNT(*) AS products_still_present FROM products;

/*
PRACTICE TASKS
1. Create a view showing products with stock below 30.
2. Create a view showing shipped orders.
3. Query a view using WHERE.
4. Drop a view and verify its base table remains.
5. Explain why a view containing GROUP BY may not be updatable.
*/
CREATE OR REPLACE VIEW v_low_stock AS
SELECT product_id, product_name, stock
FROM products
WHERE stock < 30;

CREATE OR REPLACE VIEW v_shipped_orders AS
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'Shipped';

SELECT * FROM v_shipped_orders WHERE order_date >= '2025-02-01';

/*
INTERVIEW Q&A
Q1. What is a view?
A. A named query that behaves like a virtual table.
Q2. Can a view be deleted?
A. Yes, using DROP VIEW view_name.
Q3. Does DROP VIEW delete the original table?
A. No. It removes the view definition, not the base table.
Q4. Does a view store data?
A. A conventional view stores its query definition, not a separate result copy.
Q5. Can we update a view?
A. Some views are updatable; views with aggregates, grouping, DISTINCT, UNION,
   and other complex constructs commonly are not.
*/

/*
===============================================================================
SECTION 6 — PRIMARY KEY VS UNIQUE
===============================================================================

THEORY
------
PRIMARY KEY:
- Uniquely identifies each row.
- Cannot contain NULL.
- A table has only one primary-key constraint, though it can contain multiple
  columns as a composite key.
- Commonly referenced by foreign keys.

UNIQUE:
- Prevents duplicate key values.
- A table may have multiple UNIQUE constraints.
- In MySQL, a UNIQUE index generally permits multiple NULL values because NULL
  is treated as distinct for uniqueness enforcement; a NOT NULL declaration
  can be added when a value is mandatory.

A primary key is conceptually a row identifier. A unique constraint is used
for alternate business keys such as email, username, or account number.

BUSINESS USE
------------
customer_id is usually a primary key. Email or an externally assigned account
number may be unique, but whether it should be a primary key depends on the
business model and whether the value can change.
*/

CREATE TABLE constraint_demo (
    record_id INT PRIMARY KEY,
    email VARCHAR(150) UNIQUE,
    external_code VARCHAR(40) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL
);

INSERT INTO constraint_demo
VALUES (1, 'one@example.com', 'EXT-001', 'First Record');

SELECT * FROM constraint_demo;

/*
PRACTICE TASKS
1. Create a table with a primary key.
2. Add a UNIQUE email field.
3. Explain why a primary key cannot be NULL.
4. Explain how a composite primary key differs from a single-column key.
5. Decide which fields should be unique in a customer system.
*/

/*
INTERVIEW Q&A
Q1. Can a table have two primary keys?
A. It has one PRIMARY KEY constraint, which can be composite across columns.
Q2. Can a table have several UNIQUE constraints?
A. Yes.
Q3. Can a primary key contain NULL?
A. No.
Q4. Can a UNIQUE column contain NULL in MySQL?
A. Yes, unless NOT NULL is also declared; multiple NULLs are generally allowed.
Q5. Can a foreign key reference a UNIQUE key?
A. Yes, when the referenced key satisfies MySQL's foreign-key requirements.
*/

/*
===============================================================================
SECTION 7 — SQL VS MYSQL
===============================================================================

THEORY
------
SQL stands for Structured Query Language. It is a language used to define,
retrieve, insert, update, and delete relational data.
MySQL is a relational database management system (RDBMS) that stores and
manages data and supports SQL, along with MySQL-specific features and syntax.

Examples of SQL statements:
SELECT, INSERT, UPDATE, DELETE, CREATE TABLE.

MySQL-specific or dialect-sensitive features include certain functions,
AUTO_INCREMENT, LIMIT/OFFSET syntax, stored program syntax, and administrative
commands. Other RDBMS platforms also support SQL but can differ in syntax,
functions, data types, transaction behavior, and tooling.

MySQL Workbench is a graphical client used to connect to and manage MySQL;
it is not the database language itself.

BUSINESS USE
------------
A data analyst uses SQL to query a database. The organization might store
the data in MySQL, PostgreSQL, SQL Server, Oracle, or another RDBMS.
*/

SELECT product_name, price
FROM products
WHERE price > 5000;

/*
INTERVIEW Q&A
Q1. What is SQL?
A. A language for working with relational data and database structures.
Q2. What is MySQL?
A. An RDBMS that implements SQL and provides database-management features.
Q3. Is SQL software?
A. SQL is a language, not a database server.
Q4. Is MySQL Workbench the same as MySQL Server?
A. No. Workbench is a client/administration tool; MySQL Server manages the data.
Q5. Is SQL syntax identical across all database systems?
A. No. Core concepts are shared, but dialects and supported features vary.
*/

/*
===============================================================================
SECTION 8 — WHERE VS HAVING; AGGREGATES IN HAVING
===============================================================================

THEORY
------
WHERE filters rows before grouping and aggregate calculations.
HAVING filters the groups after GROUP BY and aggregation.
Aggregate expressions such as SUM(), AVG(), and COUNT() normally belong in
HAVING when the condition is about a group result.

WHERE and HAVING can be used together:
- WHERE status = 'Shipped' chooses rows.
- GROUP BY customer_id groups those rows.
- HAVING SUM(...) > 10000 chooses groups with enough revenue.

For a query with no explicit GROUP BY, MySQL can evaluate HAVING against the
single implicit aggregate group, but this is not a reason to replace WHERE
for normal row filtering.

BUSINESS USE
------------
Filter transactions to the current financial year with WHERE, then use HAVING
to find accounts whose total transaction value exceeds a threshold.
*/

SELECT o.customer_id,
       SUM(oi.quantity * oi.unit_price) AS shipped_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Shipped'
GROUP BY o.customer_id
HAVING SUM(oi.quantity * oi.unit_price) > 1000;

/*
INTERVIEW Q&A
Q1. Which clause filters before grouping?
A. WHERE.
Q2. Which clause filters aggregate results?
A. HAVING.
Q3. Can HAVING use SUM()?
A. Yes.
Q4. Can WHERE use SUM() directly in its row condition?
A. No, not as an ordinary row-level condition; calculate it in HAVING or a
   subquery/CTE.
Q5. Can a query use both clauses?
A. Yes, and this is common in reporting.
*/

/*
===============================================================================
SECTION 9 — SQL COMMANDS: DDL AND DML
===============================================================================

THEORY
------
DDL (Data Definition Language) defines or changes database objects:
- CREATE: creates databases, tables, views, indexes, and other objects.
- ALTER: changes an object's definition.
- DROP: removes an object.
- TRUNCATE: removes all rows from a table using MySQL's truncate behavior.

DML (Data Manipulation Language) changes table data:
- INSERT: adds rows.
- UPDATE: modifies existing rows.
- DELETE: removes selected or all rows.

SELECT is often called DQL (Data Query Language), though classifications vary.
COMMIT, ROLLBACK, and SAVEPOINT are commonly classified as TCL (Transaction
Control Language). GRANT and REVOKE are commonly classified as DCL.

DDL transaction behavior is database-specific. In MySQL, many DDL statements
cause implicit commits. Do not assume a DDL change can be undone with ROLLBACK.

BUSINESS USE
------------
DDL is used in schema deployments and migrations; DML is used by applications
and data pipelines to maintain business records.
*/

CREATE TABLE ddl_dml_demo (
    demo_id INT PRIMARY KEY,
    demo_name VARCHAR(80) NOT NULL
);

INSERT INTO ddl_dml_demo VALUES (1, 'Example');
UPDATE ddl_dml_demo SET demo_name = 'Updated Example' WHERE demo_id = 1;
SELECT * FROM ddl_dml_demo;
DELETE FROM ddl_dml_demo WHERE demo_id = 1;
ALTER TABLE ddl_dml_demo ADD COLUMN created_on DATE NULL;
DROP TABLE ddl_dml_demo;

/*
INTERVIEW Q&A
Q1. What is DDL?
A. Commands that define or modify database objects.
Q2. What is DML?
A. Commands that insert, update, or delete table data.
Q3. Give examples of DDL.
A. CREATE, ALTER, DROP, and TRUNCATE.
Q4. Give examples of DML.
A. INSERT, UPDATE, and DELETE.
Q5. Is SELECT DML?
A. It is commonly classified separately as DQL, though terminology varies.
*/

/*
===============================================================================
SECTION 10 — DELETE VS TRUNCATE
===============================================================================

THEORY
------
DELETE:
- Removes rows, optionally selected by WHERE.
- With InnoDB, DELETE can be rolled back if used in an active transaction and
  not committed.
- DELETE activates applicable DELETE triggers for deleted rows.
- It normally does not reset AUTO_INCREMENT.

TRUNCATE TABLE:
- Removes all rows; WHERE is not allowed.
- In MySQL it is DDL-like and causes an implicit commit.
- It generally cannot be rolled back like a transactional DELETE.
- It resets AUTO_INCREMENT.
- It does not fire DELETE triggers.
- It can be blocked by foreign-key references from other tables.

Do not choose between them only based on speed. Consider data-retention,
foreign-key, auditing, trigger, transaction, and recovery requirements.

BUSINESS USE
------------
Use DELETE for carefully filtered cleanup. TRUNCATE may be suitable for a
reloadable staging table when all rows should be removed and its operational
effects are understood.
*/

-- DELETE demonstration: transaction is rolled back, leaving data unchanged.
START TRANSACTION;
DELETE FROM staging_import WHERE import_id = 1;
SELECT ROW_COUNT() AS rows_affected;
ROLLBACK;

-- TRUNCATE demonstration is intentionally not executed because it implicitly
-- commits and removes every staging row. To run manually, uncomment:
-- TRUNCATE TABLE staging_import;

/*
PRACTICE TASKS
1. Delete one staging row using WHERE.
2. Explain why TRUNCATE cannot selectively delete rows.
3. Explain why TRUNCATE may be blocked by foreign keys.
4. Explain the difference in trigger behavior.
5. Identify which operation is safer for a small selective correction.
*/

/*
INTERVIEW Q&A
Q1. Can DELETE use WHERE?
A. Yes.
Q2. Can TRUNCATE use WHERE?
A. No.
Q3. Can a DELETE be rolled back in InnoDB?
A. Yes, if performed in an active transaction and rolled back before commit.
Q4. Does TRUNCATE reset AUTO_INCREMENT in MySQL?
A. Generally yes.
Q5. Does TRUNCATE fire DELETE triggers?
A. No.
*/

/*
===============================================================================
SECTION 11 — PATTERN MATCHING WITH LIKE
===============================================================================

THEORY
------
LIKE compares a string to a pattern:
- % matches zero or more characters.
- _ matches exactly one character.
The case sensitivity of LIKE depends on the collation and expression.
A leading wildcard such as '%term' can prevent efficient use of a conventional
B-tree index for a prefix lookup. For large production datasets, consider
search requirements, full-text indexes, or specialized search infrastructure.

BUSINESS USE
------------
Search products by partial name, customers by known name fragments, or email
addresses by domain. Avoid using broad wildcard searches on very large tables
without considering performance.
*/

SELECT * FROM products WHERE product_name LIKE 'Lap%';
SELECT * FROM products WHERE product_name LIKE '%ouse%';
SELECT * FROM products WHERE product_name LIKE '_____';

/*
PRACTICE TASKS
1. Find customers whose names start with B.
2. Find products whose names end with r.
3. Find product names containing 'top'.
4. Find product names with exactly six characters.
5. Explain the meaning of % and _.
*/
SELECT * FROM customers WHERE customer_name LIKE 'B%';
SELECT * FROM products WHERE product_name LIKE '%r';
SELECT * FROM products WHERE product_name LIKE '%top%';
SELECT * FROM products WHERE product_name LIKE '______';

/*
INTERVIEW Q&A
Q1. Which operator performs basic SQL pattern matching?
A. LIKE.
Q2. What does % mean?
A. Zero or more characters.
Q3. What does _ mean?
A. Exactly one character.
Q4. Is LIKE always case-sensitive?
A. No; behavior depends on collation and expression.
Q5. Why can LIKE '%abc' be slow?
A. A leading wildcard often prevents a standard B-tree index from serving as
   an efficient prefix lookup.
*/

/*
===============================================================================
SECTION 12 — JOINS AND THEIR TYPES
===============================================================================

THEORY
------
A join combines rows from tables based on a join condition.

INNER JOIN:
Returns only matching rows.

LEFT JOIN:
Returns all rows from the left table and matching rows from the right table.
Missing right-side values appear as NULL.

RIGHT JOIN:
Returns all rows from the right table and matching rows from the left table.

CROSS JOIN:
Returns the Cartesian product (each row on one side paired with each row on
the other). The result can grow rapidly.

SELF JOIN:
Joins a table to itself, often using aliases, for example employee-manager.

FULL OUTER JOIN:
Returns matching and unmatched rows from both sides. MySQL does not support
FULL OUTER JOIN syntax directly. A common workaround is a LEFT JOIN combined
with a RIGHT JOIN using UNION. Take care with duplicates and the join key.

Join quality depends on correct join keys. Missing or incorrect join
conditions can multiply rows and produce incorrect totals. Indexing join keys
often helps performance, but the optimizer and data distribution matter.

BUSINESS USE
------------
Order reporting joins orders to customers; order lines join to products;
employees join to departments and managers.
*/

-- INNER JOIN
SELECT o.order_id, c.customer_name, o.status
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id;

-- LEFT JOIN: include customers without orders.
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id;

-- RIGHT JOIN
SELECT c.customer_name, o.order_id
FROM customers c
RIGHT JOIN orders o ON o.customer_id = c.customer_id;

-- CROSS JOIN: each department paired with each product.
SELECT d.department_name, p.product_name
FROM departments d
CROSS JOIN products p;

-- SELF JOIN: employee and manager.
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;

-- FULL OUTER JOIN workaround in MySQL:
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
UNION
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
RIGHT JOIN orders o ON o.customer_id = c.customer_id;

/*
PRACTICE TASKS
1. List order IDs and customer names.
2. List all customers, including customers with no orders.
3. Find customers who have never ordered.
4. List each employee and their manager.
5. Join orders, order_items, and products to calculate line revenue.
*/
SELECT o.order_id, c.customer_name
FROM orders o JOIN customers c ON c.customer_id = o.customer_id;

SELECT c.customer_name, o.order_id
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id;

SELECT c.customer_name
FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

SELECT e.employee_name, m.employee_name AS manager
FROM employees e LEFT JOIN employees m ON e.manager_id = m.employee_id;

SELECT o.order_id, p.product_name, oi.quantity,
       oi.quantity * oi.unit_price AS line_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id;

/*
INTERVIEW Q&A
Q1. What is an INNER JOIN?
A. It returns rows that match the join condition on both sides.
Q2. What is a LEFT JOIN?
A. It preserves every left-side row and returns matching right-side data.
Q3. Does MySQL support FULL OUTER JOIN directly?
A. No. A LEFT JOIN/RIGHT JOIN UNION workaround is commonly used.
Q4. What is a SELF JOIN?
A. A table joined to itself using aliases.
Q5. What is a risk of joining on the wrong key?
A. It can multiply rows and cause inaccurate totals or duplicate-looking output.
*/

/*
===============================================================================
SECTION 13 — DISTINCT
===============================================================================

THEORY
------
DISTINCT removes duplicate rows from the selected output. If several columns
are selected, uniqueness applies to the combination of all selected values.
COUNT(DISTINCT expression) counts distinct non-NULL values.

DISTINCT is useful for unique-value lists and deduplication in query results,
but it should not be used to hide an incorrect join. If a join unexpectedly
duplicates rows, verify the relationship and intended grain first.

BUSINESS USE
------------
Unique cities, product categories, transaction types, and unique customer
counts for reporting.
*/

SELECT DISTINCT city FROM customers;
SELECT DISTINCT category FROM products;
SELECT COUNT(DISTINCT customer_id) AS customers_with_orders FROM orders;

/*
PRACTICE TASKS
1. List unique product categories.
2. List unique order statuses.
3. Count unique customers who ordered.
4. List distinct combinations of customer_id and status.
5. Explain why DISTINCT on two columns differs from DISTINCT on one column.
*/
SELECT DISTINCT category FROM products;
SELECT DISTINCT status FROM orders;
SELECT COUNT(DISTINCT customer_id) FROM orders;
SELECT DISTINCT customer_id, status FROM orders;

/*
INTERVIEW Q&A
Q1. What does DISTINCT do?
A. Removes duplicate selected row combinations.
Q2. Does DISTINCT apply to each column separately?
A. No, it applies to the entire selected combination.
Q3. How do you count unique customer IDs?
A. COUNT(DISTINCT customer_id).
Q4. Can DISTINCT slow a query?
A. It can require extra sorting or temporary processing depending on the plan.
Q5. Should DISTINCT be used to fix every duplicate result?
A. No. First verify join keys and the intended row-level grain.
*/

/*
===============================================================================
SECTION 14 — SQL CONSTRAINTS
===============================================================================

THEORY
------
Constraints are database-enforced rules that protect data quality.

PRIMARY KEY: uniquely identifies each row; cannot be NULL.
FOREIGN KEY: enforces a valid reference to a key in another (or the same) table.
UNIQUE: prevents duplicate key values.
NOT NULL: requires a value.
CHECK: validates a Boolean condition.
DEFAULT: supplies a value when an insert omits the column or uses DEFAULT.

Use constraints for rules that should always hold regardless of which
application writes the data. Foreign-key behavior on UPDATE/DELETE depends on
the defined referential action (for example RESTRICT, CASCADE, SET NULL),
storage engine, and schema.

BUSINESS USE
------------
Constraints prevent orphan orders, duplicate account identifiers, missing
mandatory names, negative quantities, and invalid statuses.
*/

CREATE TABLE constraint_lab (
    id INT PRIMARY KEY,
    external_id VARCHAR(30) NOT NULL UNIQUE,
    required_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_constraint_lab_quantity CHECK (quantity >= 0)
);

INSERT INTO constraint_lab (id, external_id, required_name)
VALUES (1, 'REF-001', 'Example');

SELECT * FROM constraint_lab;

/*
PRACTICE TASKS
1. Create a table with a primary key and a NOT NULL column.
2. Add a UNIQUE email constraint.
3. Create a foreign key from orders to customers.
4. Add a CHECK constraint requiring quantity >= 0.
5. Explain what happens when a foreign key references a missing parent row.
*/

/*
INTERVIEW Q&A
Q1. What are SQL constraints?
A. Rules that enforce valid and consistent data.
Q2. What is a foreign key?
A. A rule that keeps references between related tables valid.
Q3. What does NOT NULL enforce?
A. A value must be supplied; NULL is not allowed.
Q4. What does DEFAULT do?
A. Provides a default value when a value is not explicitly supplied.
Q5. Why use a CHECK constraint?
A. To enforce a row-level condition such as quantity >= 0.
*/

/*
===============================================================================
SECTION 15 — CTE (COMMON TABLE EXPRESSION)
===============================================================================

THEORY
------
A CTE is a named result set defined with WITH and available to the single
statement immediately following it. It improves readability by splitting a
large query into named logical steps.

A CTE:
- Can be referenced by the main query and, in some cases, multiple times
  within the statement.
- Can be nonrecursive or recursive.
- Is not a permanent table.
- Does not guarantee materialization; MySQL may merge or materialize it
  depending on the query and optimizer decisions.

Recursive CTEs can represent hierarchies or generate sequences, subject to
MySQL recursion limits and syntax.

BUSINESS USE
------------
Multi-step sales analysis, employee hierarchy traversal, date sequences,
customer cohorts, and readable analytical queries.
*/

WITH product_revenue AS (
    SELECT product_id,
           SUM(quantity * unit_price) AS revenue
    FROM order_items
    GROUP BY product_id
)
SELECT p.product_name, pr.revenue
FROM product_revenue pr
JOIN products p ON p.product_id = pr.product_id
ORDER BY pr.revenue DESC;

/*
PRACTICE TASKS
1. Use a CTE to calculate average employee salary.
2. Return employees earning above average.
3. Use a CTE to calculate order revenue.
4. Use a CTE to list products with revenue above 5000.
5. Explain one difference between a CTE and a view.
*/
WITH average_pay AS (
    SELECT AVG(salary) AS avg_salary FROM employees
)
SELECT e.employee_name, e.salary
FROM employees e CROSS JOIN average_pay a
WHERE e.salary > a.avg_salary;

WITH order_revenue AS (
    SELECT order_id, SUM(quantity * unit_price) AS revenue
    FROM order_items GROUP BY order_id
)
SELECT * FROM order_revenue ORDER BY revenue DESC;

WITH product_revenue AS (
    SELECT product_id, SUM(quantity * unit_price) AS revenue
    FROM order_items GROUP BY product_id
)
SELECT p.product_name, pr.revenue
FROM product_revenue pr JOIN products p ON p.product_id = pr.product_id
WHERE pr.revenue > 5000;

/*
INTERVIEW Q&A
Q1. What is a CTE?
A. A named query result defined with WITH for one statement.
Q2. Is a CTE a permanent table?
A. No.
Q3. What is a recursive CTE used for?
A. Hierarchies, sequences, and other recursive relationships.
Q4. Does a CTE always store data physically?
A. No. The optimizer may merge or materialize it.
Q5. How does a CTE differ from a view?
A. A CTE is statement-scoped; a view is a named database object reusable across
   statements, subject to permissions and dependencies.
*/

/*
===============================================================================
SECTION 16 — OFFSET AND PAGINATION
===============================================================================

THEORY
------
In MySQL, LIMIT sets the maximum number of rows returned and OFFSET specifies
how many rows to skip before returning them. LIMIT row_count OFFSET offset is
a common pagination form.

Pagination requires stable ordering. Without ORDER BY, the database does not
guarantee which rows are first. For large offsets, the server may need to scan
and discard many rows. Keyset pagination can be more efficient when navigating
forward through large ordered datasets.

BUSINESS USE
------------
Web applications display customers, products, transactions, and tickets in
pages rather than returning every row at once.
*/

-- Page 1: first 10 products.
SELECT product_id, product_name, price
FROM products
ORDER BY product_id
LIMIT 10 OFFSET 0;

-- Page 2: skip 10 and return the next 10.
SELECT product_id, product_name, price
FROM products
ORDER BY product_id
LIMIT 10 OFFSET 10;

/*
PRACTICE TASKS
1. Return the first five products.
2. Return five products after skipping the first five.
3. Explain why ORDER BY is important for pagination.
4. Explain why a very large OFFSET can be expensive.
5. Describe keyset pagination.
*/
SELECT * FROM products ORDER BY product_id LIMIT 5 OFFSET 0;
SELECT * FROM products ORDER BY product_id LIMIT 5 OFFSET 5;

/*
INTERVIEW Q&A
Q1. What is OFFSET?
A. The number of rows skipped before results are returned.
Q2. What is LIMIT?
A. It caps the number of rows returned.
Q3. Why should pagination use ORDER BY?
A. To provide a predictable order.
Q4. Why can large OFFSET values be slow?
A. The database may need to read and discard many preceding rows.
Q5. What is keyset pagination?
A. Pagination based on a last-seen key value instead of skipping a large offset.
*/

/*
===============================================================================
SECTION 17 — NORMALIZATION (1NF, 2NF, 3NF)
===============================================================================

THEORY
------
Normalization is the process of structuring relational tables to reduce
unnecessary duplication and avoid insertion, update, and deletion anomalies.

Common anomalies:
- Update anomaly: the same fact must be changed in multiple rows.
- Insertion anomaly: a fact cannot be added without unrelated data.
- Deletion anomaly: deleting one record accidentally removes another fact.

1NF:
Each field holds a single value at the row/column intersection; avoid repeating
groups or lists inside one field.

2NF:
The table is in 1NF and each non-prime attribute depends on the whole of every
candidate key, not only part of a composite candidate key. This issue is
particularly relevant to composite keys.

3NF:
The table is in 2NF and avoids inappropriate transitive dependencies of
non-key attributes on candidate keys. Informally, non-key facts should depend
on the key, the whole key, and nothing but the key, with formal definitions
based on functional dependencies.

Example:
Instead of repeating customer name and phone on every order line, store
customer details in Customers, order facts in Orders, product facts in Products,
and each ordered product in Order_Items.

Normalization does not mean every system must be maximally normalized.
Analytics warehouses may intentionally denormalize to improve reporting
simplicity or performance, while operational systems commonly favor normalized
designs for integrity.

BUSINESS USE
------------
E-commerce, banking, hospital, and HR systems use normalized designs to reduce
duplication and preserve consistent master data.
*/

CREATE TABLE customer_normalized (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(25)
);

CREATE TABLE customer_orders_normalized (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customer_normalized(customer_id)
);

INSERT INTO customer_normalized VALUES
(1, 'Aisha Khan', '9876500001'),
(2, 'Rahul Mehta', '9876511111');

INSERT INTO customer_orders_normalized VALUES
(501, 1, '2025-01-10'),
(502, 1, '2025-02-15'),
(503, 2, '2025-03-01');

SELECT c.customer_name, c.phone, o.order_id, o.order_date
FROM customer_normalized c
JOIN customer_orders_normalized o
  ON o.customer_id = c.customer_id;

/*
PRACTICE TASKS
1. Identify repeated customer data in a denormalized order table.
2. Explain 1NF using a comma-separated product list example.
3. Explain partial dependency and why it matters for 2NF.
4. Explain transitive dependency and its relationship to 3NF.
5. Give one reason an analytics warehouse may use denormalization.
*/

/*
INTERVIEW Q&A
Q1. What is normalization?
A. Structuring tables to reduce redundancy and data anomalies.
Q2. What is 1NF?
A. Fields contain single values and repeating groups are removed.
Q3. What does 2NF address?
A. Partial dependency of non-key attributes on part of a candidate key.
Q4. What does 3NF address?
A. Transitive dependencies that violate third normal form.
Q5. Is denormalization always bad?
A. No. It may be a deliberate trade-off for analytical performance and simpler
   reporting, provided consistency is managed.
*/

/*
===============================================================================
SECTION 18 — BONUS CORPORATE PRACTICE QUERIES
===============================================================================
*/

-- 1. Second-highest distinct salary.
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- 2. Customers who have never placed an order.
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 3. Total revenue per customer.
SELECT c.customer_id, c.customer_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;

-- 4. Rank employees by salary within each department (MySQL 8.0+).
SELECT employee_name, department_id, salary,
       DENSE_RANK() OVER (
           PARTITION BY department_id
           ORDER BY salary DESC
       ) AS salary_rank
FROM employees;

-- 5. Label products by price range using CASE.
SELECT product_name, price,
       CASE
           WHEN price >= 50000 THEN 'Premium'
           WHEN price >= 5000 THEN 'Mid-range'
           ELSE 'Budget'
       END AS price_band
FROM products;

-- 6. Show monthly order counts.
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
       COUNT(*) AS order_count
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

-- 7. Find duplicate customer emails if the schema permits them.
-- The demo schema has UNIQUE email, so this returns no duplicates.
SELECT email, COUNT(*) AS occurrences
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

/*
===============================================================================
FINAL INTERVIEW CHECKLIST
===============================================================================
Before an interview, be ready to:
1. Define each concept without reading the notes.
2. Write a small query from memory.
3. Explain the expected output.
4. Explain NULL handling and edge cases.
5. Describe the business use case.
6. Explain performance or integrity risks where relevant.
7. Know that MySQL-specific syntax may differ from other RDBMS products.

END OF CORPORATE SQL NOTES
===============================================================================
*/
