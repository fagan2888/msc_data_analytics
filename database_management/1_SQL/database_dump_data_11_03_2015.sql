
SELECT * 
FROM event
LEFT JOIN airport
ON event.airport_id = airport.id
WHERE country = 'GR' 


SELECT 'GREECE'
FROM airport