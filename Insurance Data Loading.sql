create database if not exists zopper_motor_insurance;
use zopper_motor_insurance;

CREATE TABLE policy_sales (
    cust_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    vehicle_value Decimal(10, 2),
    policy_tenure INT NOT NULL,
    premium DECIMAL(10 , 2 ),
    policy_purchase_date DATE NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    PRIMARY KEY (cust_id),
    UNIQUE KEY (vehicle_id)
);

CREATE TABLE claims (
    cust_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    vehicle_value Decimal(10 , 2),
    policy_tenure INT NOT NULL,
    premium DECIMAL(10 , 2 ),
    policy_purchase_date DATE NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE NOT NULL,
    claim_amount DECIMAL(10 , 2),
    claim_date DATE NOT NULL ,
    claim_type INT,
    FOREIGN KEY (cust_id) REFERENCES policy_sales(cust_id),
    FOREIGN KEY (vehicle_id) REFERENCES policy_sales(vehicle_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/policy_sales.csv'
INTO TABLE policy_sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/claims.csv'
INTO TABLE claims
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;