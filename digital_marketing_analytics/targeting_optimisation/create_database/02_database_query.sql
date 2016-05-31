-- Identify the top 5 customer locations by average spend.

--DROP TABLE HW1;

CREATE TABLE HW1 AS
SELECT AVG(lines.LineDollars), location.SCF_Code
FROM lines
LEFT JOIN location
ON lines.Cust_ID=location.Cust_ID
GROUP BY SCF_Code
ORDER BY AVG(lines.LineDollars) DESC
LIMIT 5;

