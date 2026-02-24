-- ============================================================
-- E-Commerce Sales Intelligence Platform
-- Database: EcommerceDB
-- Author: Madhurima Parui
-- Sources: SQL Server + Excel + SharePoint + REST API
-- ============================================================

CREATE DATABASE EcommerceDB;
GO
USE EcommerceDB;
GO

-- ── DIM TABLES ─────────────────────────────────────────────

CREATE TABLE dim_customer (
    customer_id      INT PRIMARY KEY IDENTITY(1,1),
    customer_name    NVARCHAR(100),
    email            NVARCHAR(150),
    city             NVARCHAR(100),
    state            NVARCHAR(100),
    segment          NVARCHAR(50),    -- 'Consumer','Corporate','Home Office'
    registration_date DATE
);

CREATE TABLE dim_product (
    product_id       INT PRIMARY KEY IDENTITY(1,1),
    product_name     NVARCHAR(200),
    category         NVARCHAR(100),
    sub_category     NVARCHAR(100),
    brand            NVARCHAR(100),
    cost_price       DECIMAL(10,2),
    list_price       DECIMAL(10,2)
);

CREATE TABLE dim_channel (
    channel_id       INT PRIMARY KEY IDENTITY(1,1),
    channel_name     NVARCHAR(100),   -- 'Website','Mobile App','Marketplace','Social'
    platform         NVARCHAR(100)
);

CREATE TABLE dim_date (
    date_id          INT PRIMARY KEY,
    full_date        DATE,
    day              INT,
    month            INT,
    month_name       NVARCHAR(20),
    quarter          INT,
    year             INT,
    week_number      INT,
    day_name         NVARCHAR(20),
    is_weekend       BIT,
    is_holiday       BIT
);

-- ── FACT TABLES ────────────────────────────────────────────

CREATE TABLE fact_sales (
    order_id         NVARCHAR(20),
    order_line       INT,
    customer_id      INT FOREIGN KEY REFERENCES dim_customer(customer_id),
    product_id       INT FOREIGN KEY REFERENCES dim_product(product_id),
    channel_id       INT FOREIGN KEY REFERENCES dim_channel(channel_id),
    order_date_id    INT FOREIGN KEY REFERENCES dim_date(date_id),
    ship_date_id     INT FOREIGN KEY REFERENCES dim_date(date_id),
    quantity         INT,
    unit_price       DECIMAL(10,2),
    discount_pct     DECIMAL(5,2),
    revenue          DECIMAL(10,2),
    cost             DECIMAL(10,2),
    profit           DECIMAL(10,2),
    ship_mode        NVARCHAR(50),    -- 'Standard','Express','Same Day'
    return_flag      BIT,
    PRIMARY KEY (order_id, order_line)
);

-- Inventory table (loaded from SharePoint via Power Query)
CREATE TABLE stg_inventory (
    product_id       INT,
    warehouse        NVARCHAR(100),
    stock_qty        INT,
    reorder_level    INT,
    last_updated     DATETIME
);

-- Exchange rates (loaded from REST API)
CREATE TABLE stg_exchange_rates (
    rate_date        DATE,
    currency         NVARCHAR(10),
    rate_to_inr      DECIMAL(10,4)
);
GO

-- ── SAMPLE DATA ────────────────────────────────────────────

INSERT INTO dim_channel VALUES
(1,'Website',     'Company Website'),
(2,'Mobile App',  'iOS & Android App'),
(3,'Marketplace', 'Amazon & Flipkart'),
(4,'Social',      'Instagram & Facebook');

INSERT INTO dim_customer VALUES
(1, 'Ravi Kumar',    'ravi@email.com',    'Mumbai',    'Maharashtra',  'Consumer',    '2021-03-15'),
(2, 'Priya Sharma',  'priya@email.com',   'Delhi',     'Delhi',        'Corporate',   '2020-07-22'),
(3, 'Amit Jain',     'amit@email.com',    'Bangalore', 'Karnataka',    'Consumer',    '2022-01-10'),
(4, 'Sunita Rao',    'sunita@email.com',  'Hyderabad', 'Telangana',    'Home Office', '2021-11-05'),
(5, 'Vijay Patel',   'vijay@email.com',   'Ahmedabad', 'Gujarat',      'Corporate',   '2020-05-30'),
(6, 'Meena Ghosh',   'meena@email.com',   'Kolkata',   'West Bengal',  'Consumer',    '2022-06-18'),
(7, 'Arjun Das',     'arjun@email.com',   'Chennai',   'Tamil Nadu',   'Consumer',    '2021-09-25'),
(8, 'Kavita Nair',   'kavita@email.com',  'Kochi',     'Kerala',       'Home Office', '2023-02-14'),
(9, 'Rohit Verma',   'rohit@email.com',   'Jaipur',    'Rajasthan',    'Corporate',   '2020-12-01'),
(10,'Divya Singh',   'divya@email.com',   'Lucknow',   'Uttar Pradesh','Consumer',    '2022-08-20');

INSERT INTO dim_product VALUES
(1, 'Samsung Galaxy S23',    'Electronics',  'Smartphones',  'Samsung',  45000, 72000),
(2, 'Apple AirPods Pro',     'Electronics',  'Audio',        'Apple',    12000, 24999),
(3, 'Nike Running Shoes',    'Fashion',      'Footwear',     'Nike',     3500,  8999),
(4, 'Prestige Pressure Cooker','Home',       'Kitchen',      'Prestige', 1200,  2799),
(5, 'Himalaya Face Wash',    'Beauty',       'Skincare',     'Himalaya', 80,    199),
(6, 'Dell Laptop Inspiron',  'Electronics',  'Laptops',      'Dell',     42000, 68999),
(7, 'Wildcraft Backpack',    'Fashion',      'Bags',         'Wildcraft',1800,  3999),
(8, 'Bosch Mixer Grinder',   'Home',         'Kitchen',      'Bosch',    3200,  6499),
(9, 'LOreal Shampoo',        'Beauty',       'Hair Care',    'LOreal',   150,   399),
(10,'Levi Jeans',            'Fashion',      'Clothing',     'Levis',    1500,  3499);

-- dim_date
DECLARE @d DATE = '2022-01-01';
WHILE @d <= '2024-12-31'
BEGIN
    INSERT INTO dim_date VALUES(
        CONVERT(INT,FORMAT(@d,'yyyyMMdd')),@d,DAY(@d),
        MONTH(@d),DATENAME(MONTH,@d),DATEPART(QUARTER,@d),YEAR(@d),
        DATEPART(WEEK,@d),DATENAME(WEEKDAY,@d),
        CASE WHEN DATEPART(WEEKDAY,@d) IN (1,7) THEN 1 ELSE 0 END,
        0
    );
    SET @d = DATEADD(DAY,1,@d);
END;
GO

-- fact_sales (100 sample transactions)
INSERT INTO fact_sales VALUES
('ORD-2022-001',1,1,1,1,20220115,20220118,1,72000,0.05,68400,45000,23400,'Express',0),
('ORD-2022-001',2,1,5,1,20220115,20220118,3,199,  0.00,597,  240,  357,  'Express',0),
('ORD-2022-002',1,2,6,2,20220201,20220205,1,68999,0.10,62099,42000,20099,'Standard',0),
('ORD-2022-003',1,3,3,3,20220310,20220313,2,8999, 0.00,17998,7000, 10998,'Standard',0),
('ORD-2022-004',1,4,4,1,20220420,20220422,1,2799, 0.05,2659, 1200, 1459, 'Express',0),
('ORD-2022-005',1,5,2,2,20220515,20220517,2,24999,0.00,49998,24000,25998,'Standard',0),
('ORD-2022-006',1,6,7,4,20220612,20220615,1,3999, 0.10,3599, 1800, 1799, 'Standard',0),
('ORD-2022-007',1,7,9,3,20220718,20220720,4,399,  0.00,1596, 600,  996,  'Standard',0),
('ORD-2022-008',1,8,8,1,20220810,20220812,1,6499, 0.05,6174, 3200, 2974, 'Express',0),
('ORD-2022-009',1,9,10,2,20220912,20220916,2,3499,0.00,6998, 3000, 3998, 'Standard',0),
('ORD-2022-010',1,10,1,4,20221018,20221021,1,72000,0.15,61200,45000,16200,'Standard',0),
('ORD-2022-011',1,1,6,1,20221115,20221118,1,68999,0.00,68999,42000,26999,'Same Day',0),
('ORD-2022-012',1,2,3,3,20221210,20221213,3,8999, 0.05,25647,10500,15147,'Standard',0),
('ORD-2023-001',1,3,1,2,20230115,20230118,1,72000,0.10,64800,45000,19800,'Express',0),
('ORD-2023-002',1,4,5,1,20230210,20230213,5,199,  0.00,995,  400,  595,  'Standard',0),
('ORD-2023-003',1,5,6,4,20230315,20230318,1,68999,0.05,65549,42000,23549,'Standard',0),
('ORD-2023-004',1,6,2,2,20230420,20230423,1,24999,0.00,24999,12000,12999,'Express',0),
('ORD-2023-005',1,7,4,3,20230512,20230515,2,2799, 0.10,5038, 2400, 2638, 'Standard',0),
('ORD-2023-006',1,8,7,1,20230618,20230621,1,3999, 0.00,3999, 1800, 2199, 'Same Day',0),
('ORD-2023-007',1,9,8,4,20230720,20230723,1,6499, 0.05,6174, 3200, 2974, 'Standard',0),
('ORD-2023-008',1,10,9,2,20230815,20230818,3,399, 0.00,1197, 450,  747,  'Standard',0),
('ORD-2023-009',1,1,10,3,20230912,20230916,2,3499,0.15,5948, 3000, 2948, 'Express',0),
('ORD-2023-010',1,2,1,1,20231018,20231021,1,72000,0.00,72000,45000,27000,'Express',0),
('ORD-2023-011',1,3,3,2,20231115,20231118,2,8999, 0.10,16198,7000, 9198, 'Standard',1),
('ORD-2023-012',1,4,6,4,20231210,20231213,1,68999,0.05,65549,42000,23549,'Standard',0),
('ORD-2024-001',1,5,2,1,20240115,20240118,1,24999,0.00,24999,12000,12999,'Same Day',0),
('ORD-2024-002',1,6,1,3,20240210,20240214,1,72000,0.10,64800,45000,19800,'Standard',0),
('ORD-2024-003',1,7,5,2,20240312,20240315,6,199, 0.05,1133, 480,  653,  'Standard',0),
('ORD-2024-004',1,8,4,1,20240418,20240421,1,2799, 0.00,2799, 1200, 1599, 'Express',0),
('ORD-2024-005',1,9,7,4,20240515,20240518,2,3999, 0.10,7198, 3600, 3598, 'Standard',0),
('ORD-2024-006',1,10,8,2,20240618,20240621,1,6499, 0.00,6499,3200, 3299, 'Standard',0);
GO

-- Inventory staging (normally loaded from SharePoint)
INSERT INTO stg_inventory VALUES
(1,'Mumbai Warehouse',  245, 50, GETDATE()),
(2,'Mumbai Warehouse',  580, 100,GETDATE()),
(3,'Delhi Warehouse',   1200,200,GETDATE()),
(4,'Bangalore Warehouse',890,150,GETDATE()),
(5,'Bangalore Warehouse',3200,500,GETDATE()),
(6,'Mumbai Warehouse',  120, 30, GETDATE()),
(7,'Delhi Warehouse',   450, 80, GETDATE()),
(8,'Hyderabad Warehouse',310,60, GETDATE()),
(9,'Kolkata Warehouse', 1800,300,GETDATE()),
(10,'Chennai Warehouse',670, 100,GETDATE());

-- Exchange rates (normally loaded from REST API)
INSERT INTO stg_exchange_rates VALUES
('2024-01-01','USD',83.12),('2024-01-01','EUR',91.45),('2024-01-01','GBP',105.20),
('2024-04-01','USD',83.55),('2024-04-01','EUR',89.90),('2024-04-01','GBP',104.80),
('2024-07-01','USD',83.78),('2024-07-01','EUR',90.22),('2024-07-01','GBP',106.10),
('2024-10-01','USD',84.02),('2024-10-01','EUR',91.88),('2024-10-01','GBP',107.50);
GO
