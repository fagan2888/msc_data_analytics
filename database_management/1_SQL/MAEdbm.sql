-- Assignment 1 for MSc Business Analytics, DataBase Management

-- Maria Athena B. Engesaeth 
-- CID 01159179


-- Tables
-- event(id:integer, type:text, date:date, local_time:text, 
--	 latitude:numeric, longitude:numeric, pilot_hours:integer, 
--   aircraft_manufacturer:text, aircraft_model:text, operator_code:text, 
--   airport_id:text)
-- aircraft(manufacturer:text, model:text, no_engines: integer)
-- operator(code:text, name:text, issue_date:text, no_employees:integer) 
-- person(id:integer, firstname:text, lastname:text, city:text, 
--   operator_code:text) airport(id:integer, name:text, city:text, 
--   county:text) position(id:integer, description:text) 
--   person_position(person_id:integer, position_id:integer)

-- Primary Keys
-- event(id)
-- aircraft(manufacturer, model) operator(code)
-- person(id)
-- airport(id)
-- position(id) person_position(person_id, position_id)

-- Foreign Keys
-- event(aircraft_manufacturer, aircraft_model) --> aircraft(manufacturer, model) 
-- event(airport_id) --> airport(id)
-- event(operator_code) --> operator(code)
-- person(operator_code) --> operator(code)
-- person_positon(person_id) --> person(id) 
-- person_positon(position_id) --> position(id)



-- A. Count all events that happened between 1.1.2005 and 1.1.2006.

SELECT COUNT(*) 
FROM event 
WHERE date BETWEEN '2005-01-01' AND '2006-01-01';
-- SOLUTION: 662 events



-- B. Count all events for operators whose name contains an “S”.

SELECT  COUNT(*) 
FROM event 
LEFT JOIN operator 
ON event.operator_code=operator.code 
WHERE name 
LIKE '%S%';
-- SOLUTION: 1,850 events



-- C. Count all events for operators whose owner’s name contains a “T”.

--> event(operator_code)
--> person(firstname LIKE '%T%' OR lastname LIKE '%T%') 
--> person(operator_code) = person(id)
--> person_positon(person_id) --> (position_id==4) 

SELECT COUNT(*)
FROM event
LEFT JOIN person
ON event.operator_code = person.operator_code
LEFT JOIN person_position
ON person.id = person_position.person_id
LEFT JOIN position
ON person_position.position_id = position.id
WHERE description = 'OWNER' AND (first_name LIKE '%T%' OR last_name LIKE '%T%');
-- SOLUTION: 47 events



CREATE VIEW perpos2 AS 
SELECT person_id,position_id,description 
FROM person_position JOIN position 
ON person_position.position_id = position.id;

CREATE VIEW owner2 AS

SELECT * FROM perpos2 WHERE position_id = 4;

CREATE VIEW person_owner AS
SELECT * 
FROM person join owner2 
ON person.id=owner2.person_id;  

SELECT COUNT(*) 
FROM event WHERE operator_code 
IN (SELECT operator_code 
	FROM person_owner WHERE first_name LIKE 'T%' 
	OR first_name LIKE '%T' OR first_name LIKE '%T%'
	OR last_name LIKE 'T%' OR last_name LIKE '%T' 
	OR last_name LIKE '%T%');


-- D. Count all events where the pilot's flight hours are between 1000 and 2000
--    of hours.

SELECT  COUNT(*) 
FROM event 
WHERE pilot_hours
BETWEEN 1000 AND 2000;
-- SOLUTION: 4,041 events



-- E. Count all events that happened to an aircraft coming from an airport
--    located in Greece.

-- event(airport_id) --> airport(id)
--> airport(id) --> airport(country)

SELECT * 
FROM event
LEFT JOIN airport
ON event.airport_id = airport.id
WHERE country = 'GR' 
-- SOLUTION: 1 events

