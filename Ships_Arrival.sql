CREATE TABLE Ships_Arrivals
(
    DateTime DATETIME,
    Container INT,
    `Dry Bulk` INT,
    `General Cargo` INT,
    `Roll-on/roll-off` INT,
    Tanker INT,
    `7-day Moving Average` DECIMAL(10,2),
    `Prior Year: 7-day Moving Average` DECIMAL(10,2) 
)
;

select *
From Ships_Arrivals
;

Insert into Ships_Arrivals (
    DateTime, Container, `Dry Bulk`, `General Cargo`, 
    `Roll-on/roll-off`, Tanker, `7-day Moving Average`, 
    `Prior Year: 7-day Moving Average`
)
SELECT 
    DateTime, Container, `Dry Bulk`, `General Cargo`, 
    `Roll-on/roll-off`, Tanker,
    NULLIF(`7-day Moving Average`, ''),
    NULLIF(`Prior Year: 7-day Moving Average`, '')
From arrivals_of_ships
;


Select *
From arrivals_of_ships
;

Alter table arrivals_of_ships rename Column `ï»¿"DateTime"` to `DateTime`;


Select *
From Ships_Arrivals
;

SELECT COUNT(*) AS Total_Rows
FROM Arrivals_of_Ships
;

SELECT
    MIN(DateTime) AS Start_Date,
    MAX(DateTime) AS End_Date
FROM Ships_Arrivals
;

SELECT
    DateTime,
    COUNT(*) AS Record_Count
FROM Ships_Arrivals
GROUP BY DateTime
HAVING COUNT(*) > 1
;

SELECT
    SUM(CASE WHEN DateTime IS NULL THEN 1 ELSE 0 END) AS Missing_Date,
    SUM(CASE WHEN Container IS NULL THEN 1 ELSE 0 END) AS Missing_Container,
    SUM(CASE WHEN `Dry Bulk` IS NULL THEN 1 ELSE 0 END) AS Missing_Dry_Bulk,
    SUM(CASE WHEN `General Cargo` IS NULL THEN 1 ELSE 0 END) AS Missing_General_Cargo,
    SUM(CASE WHEN `Roll-on/roll-off` IS NULL THEN 1 ELSE 0 END) AS Missing_RORO,
    SUM(CASE WHEN Tanker IS NULL THEN 1 ELSE 0 END) AS Missing_Tanker,
    SUM(CASE WHEN `7-day Moving Average` IS NULL THEN 1 ELSE 0 END) AS Missing_7D_MA,
    SUM(CASE WHEN `Prior Year: 7-day Moving Average` IS NULL THEN 1 ELSE 0 END) AS Missing_Prior_Year_MA
FROM Ships_Arrivals
;


CREATE VIEW vw_Ship_Arrivals AS

SELECT
    DateTime,

    Container,
    `Dry Bulk`,
    `General Cargo`,
    `Roll-on/roll-off`,
    Tanker,

    Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker AS Total_Arrivals,

    `7-day Moving Average` AS Moving_Average_7D,

    `Prior Year: 7-day Moving Average`
        AS Prior_Year_Moving_Average_7D

FROM Ships_Arrivals
;

SELECT *
FROM vw_Ship_Arrivals
;

SELECT
    SUM(Container) AS Container_Arrivals,
    SUM(`Dry Bulk`) AS Dry_Bulk_Arrivals,
    SUM(`General Cargo`) AS General_Cargo_Arrivals,
    SUM(`Roll-on/roll-off`) AS RORO_Arrivals,
    SUM(Tanker) AS Tanker_Arrivals,

    SUM(
        Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker
    ) AS Total_Arrivals

FROM Ships_Arrivals
;

SELECT
    YEAR(DateTime) AS Year,

    SUM(Container) AS Container,
    SUM(`Dry Bulk`) AS Dry_Bulk,
    SUM(`General Cargo`) AS General_Cargo,
    SUM(`Roll-on/roll-off`) AS RORO,
    SUM(Tanker) AS Tanker,

    SUM(
        Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker
    ) AS Total_Arrivals

FROM Ships_Arrivals

GROUP BY YEAR(DateTime)

ORDER BY Year
;


WITH Yearly AS
(
    SELECT
        YEAR(DateTime) AS Year,

        SUM(
            Container
            + `Dry Bulk`
            + `General Cargo`
            + `Roll-on/roll-off`
            + Tanker
        ) AS Total_Arrivals

    FROM Ships_Arrivals

    GROUP BY YEAR(DateTime)
),

YoY AS
(
    SELECT
        Year,
        Total_Arrivals,

        LAG(Total_Arrivals)
            OVER (ORDER BY Year) AS Previous_Year

    FROM Yearly
)

SELECT
    Year,
    Total_Arrivals,
    Previous_Year,

    ROUND(
        (Total_Arrivals - Previous_Year)
        * 100.0
        / NULLIF(Previous_Year, 0),
        2
    ) AS YoY_Growth_Percentage

FROM YoY

ORDER BY Year
;


SELECT
    YEAR(DateTime) AS Year,
    MONTH(DateTime) AS Month,

    SUM(
        Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker
    ) AS Total_Arrivals

FROM Ships_Arrivals

GROUP BY
    YEAR(DateTime),
    MONTH(DateTime)

ORDER BY
    Year,
    Month
;

SELECT 
    DateTime,
    Container,
    `Dry Bulk`,
    `General Cargo`,
    `Roll-on/roll-off`,
    Tanker,

    Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker AS Total_Arrivals

FROM Ships_Arrivals

ORDER BY Total_Arrivals DESC
Limit 10
;



SELECT
    DateTime,

    Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker AS Total_Arrivals

FROM Ships_Arrivals

WHERE
    Container
    + `Dry Bulk`
    + `General Cargo`
    + `Roll-on/roll-off`
    + Tanker = 0

ORDER BY DateTime
;

SELECT
    DateTime,

    Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker AS Total_Arrivals,

    AVG(
        Container
        + `Dry Bulk`
        + `General Cargo`
        + `Roll-on/roll-off`
        + Tanker
    ) OVER
    (
        ORDER BY DateTime
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Moving_Average_7D

FROM Ships_Arrivals

ORDER BY DateTime
;




