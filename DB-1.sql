#  1. Create DataBase BANK and Write SQL query to create above schema with constraints
CREATE SCHEMA IF NOT EXISTS Bank;
use bank;

CREATE TABLE IF NOT EXISTS Branch (
    Branch_no INT AUTO_INCREMENT,
    Name CHAR(50) NOT NULL,
    PRIMARY KEY (Branch_no)
);

CREATE TABLE IF NOT EXISTS Employees (
    Emp_no INT AUTO_INCREMENT,
    Branch_no INT,
    Fname CHAR(20),
    Mname CHAR(20),
    Lname CHAR(20),
    Dept CHAR(20),
    Desig CHAR(10),
    Mngr_no INT NOT NULL,
    PRIMARY KEY (Emp_no),
    FOREIGN KEY (Branch_no)
        REFERENCES Branch (Branch_no)
);
 
CREATE TABLE IF NOT EXISTS Customer (
    Cust_no INT AUTO_INCREMENT,
    Fname CHAR(30),
    Mname CHAR(30),
    Lname CHAR(30),
    City CHAR(30),
    DOB DATE,
    Occupation CHAR(10),
    PRIMARY KEY (Cust_no)
);

CREATE TABLE IF NOT EXISTS Accounts (
    Account_no INT AUTO_INCREMENT,
    Branch_no INT NOT NULL,
    Cust_no INT NOT NULL,
    atype CHAR (10),
    opndt DATE,
    astatus CHAR(10),
    PRIMARY KEY (Account_no),
    FOREIGN KEY (Branch_no)
		REFERENCES branch (Branch_no),
    FOREIGN KEY (Cust_no)
		REFERENCES customer (Cust_no)
);

# 2. Inserting Records into created tables Branch
INSERT INTO 
branch (Name) 
VALUES ('Delhi'),
       ('Mumbai');

INSERT INTO
customer (Fname, Mname, Lname, DOB, Occupation)
VALUES ('Ramesh','Chandra','Sharma','1976-12-06','Service'),
	   ('Avinash','Sunder','Minha','1974-10-16','Business');

ALTER TABLE accounts 
ADD COLUMN curbal INT AFTER Cust_no;

INSERT INTO
accounts (Branch_no, Cust_no, curbal, atype, opndt, astatus)
VALUES (1,1,10000,'Saving','2012-12-15','Active'),
       (2,2,5000,'Saving','2012-06-12','Active');

INSERT INTO 
employees (Branch_no, Fname, Mname, Lname, Dept, Desig, Mngr_no)
VALUES (1, 'Mark', 'steve', 'Lara', 'Account', 'Accountant', '2'),
       (2, 'Bella', 'James', 'Ronald', 'Loan', 'Manager', '1');

# 3. Select unique occupation from customer table
SELECT DISTINCT Occupation 
FROM customer;

# 4. Sort accounts according to current balance 
SELECT Account_no, curbal 
FROM accounts
ORDER BY curbal ASC;

# 5. Find the Date of Birth of customer name ‘Ramesh’
SELECT Fname, Mname, Lname, DOB
FROM customer
WHERE Fname = 'Ramesh';

# 6. Add column city to branch table 
ALTER TABLE branch
ADD COLUMN City CHAR (20);

# 7. Update the mname and lname of employee ‘Bella’ and set to ‘Karan’, ‘Singh’ 
UPDATE employees
SET Mname = 'Karan', Lname = 'Singh'
WHERE Emp_no = 2;

# 8. Select accounts opened between '2012-07-01' AND '2013-01-01'
SELECT *
FROM accounts
WHERE opndt BETWEEN '2012-07-01' AND '2013-01-01';

# 9. List the names of customers having ‘a’ as the second letter in their names 
SELECT Fname, Lname
FROM customer
WHERE Fname LIKE '_a%' OR Lname LIKE '_a%';

# 10. Find the lowest balance from customer and account table
SELECT c.Cust_no, c.Fname, c.Mname, c.Lname, min(curbal) AS LOWEST_BALANCE
FROM accounts a
JOIN customer c
ON c.Cust_no = a.Cust_no
GROUP BY c.Cust_no
ORDER BY a.Cust_no DESC
LIMIT 1;

# 11.	Give the count of customer for each occupation
SELECT count(Cust_no) AS TOTAL_COUNTS, Occupation
FROM customer
GROUP BY Occupation; 

# 12.	Write a query to find the name (first_name, last_name) of the employees who are managers.
SELECT Fname, Lname, Desig
FROM employees
WHERE Desig LIKE 'manager';

# 13.	List name of all employees whose name ends with a
SELECT Fname, Mname, Lname 
FROM employees
WHERE Fname LIKE '%a';

#14. Select the details of the employee who work either for department ‘loan’ or ‘credit’
SELECT Fname, Mname, Lname, Dept
FROM employees
WHERE Dept LIKE 'loan' OR 'credit';

# 15.	Write a query to display the customer number, customer firstname, account number for the customer’s who are born after 15th of any month.
SELECT a.Cust_no, c.Fname, a.Account_no
FROM accounts a, customer c
WHERE a.Cust_no = c.Cust_no
AND day(DOB) > 15;

#16.	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.
SELECT c.Cust_no, c.Fname, a.Branch_no, a.curbal
FROM customer c
JOIN accounts a
ON c.Cust_no = a.Cust_no;

#17.	Create a virtual table to store the customers who are having the accounts in the same city as they live

CREATE VIEW cutomers_of_same_city AS 
SELECT c.Fname, c.Mname, c.Lname, c.DOB, c.Occupation, c.City
FROM customer c
JOIN accounts a
ON c.Cust_no = a.Cust_no
JOIN branch b
ON b.Branch_no = a.Branch_no
WHERE b.city = c.City;
SELECT * FROM cutomers_of_same_city;

# 18.	A. Create a transaction table with following details 
# TID – transaction ID – Primary key with autoincrement 
# Custid – customer id (reference from customer table
# account no – acoount number (references account table)
# bid – Branch id – references branch table
# amount – amount in numbers
# type – type of transaction (Withdraw or deposit)
# DOT -  date of transaction

CREATE TABLE IF NOT EXISTS transaction_ 
(
Tid INT PRIMARY KEY AUTO_INCREMENT,
Cust_id INT,
account_no INT, 
Bid INT,
amount INT, 
trans_type VARCHAR(10) CONSTRAINT trans_type CHECK (trans_type = 'Withdraw' OR trans_type = 'Deposit'),
DOT DATE,
FOREIGN KEY (Cust_id)
        REFERENCES customer (Cust_no),
FOREIGN KEY (account_no)
        REFERENCES accounts (Account_no),
FOREIGN KEY (Bid)
        REFERENCES branch (Branch_no)
);

DROP TABLE transaction_;
# 18. a. Write trigger to update balance in account table on Deposit or Withdraw in transaction table
DROP TRIGGER balance_after_transaction;

 COMMIT;
DELIMITER $$
CREATE TRIGGER balance_after_transaction
AFTER INSERT ON transaction_
FOR EACH ROW
BEGIN 
	DECLARE curr_bal INT;
    
    SELECT curbal INTO curr_bal FROM accounts
    WHERE Account_no = new.Account_no;
    
    IF NEW.trans_type = 'withdraw' THEN SET curr_bal=curr_bal - new.amount;
    ELSE SET curr_bal=curr_bal + new.amount;
    END IF;
	UPDATE accounts 
    SET curbal = curr_bal WHERE Account_no = new.Account_no;
    END;
END $$
DELIMITER ; 


# 18.b. Insert values in transaction table to show trigger success

INSERT INTO 
transaction_ (Tid, Cust_id, account_no, Bid, amount, trans_type, DOT)
VALUES (1, 1, 1, 1, 2000, 'Deposit','2023-12-26');
 
INSERT INTO 
transaction_ (Tid, Cust_id, account_no, Bid, amount, trans_type, DOT)
VALUES (2, 2, 2, 2, 3000, 'Deposit','2023-12-27');


# 19.	Write a query to display the details of customer with second highest balance 
SELECT c.Cust_no, c.Fname, c.Mname, c.Lname, max(curbal) AS SECOND_HIGHEST_BALANCE
FROM accounts a
JOIN customer c
ON c.Cust_no = a.Cust_no
GROUP BY c.Cust_no
ORDER BY a.Cust_no ASC
LIMIT 1,1;

# 20.	Take backup of the databse created in this case study
# Server - Data Export - Export to dump project folder - checklist dump trigger - C:\Users\HP\Documents\dumps\bank_retail_case_study 