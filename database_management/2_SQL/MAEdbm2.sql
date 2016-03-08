-- Assignment 2 for MSc Business Analytics, DataBase Management

-- Maria Athena B. Engesaeth 
-- CID 01159179



-- A. Find all films that are not in the inventory and count them.

SELECT film.*, inventory.*
FROM film
    FULL JOIN inventory ON (film.film_id = inventory.film_id)
WHERE film.film_id IS NULL OR inventory.film_id IS NULL
-- SOLUTION: 42 films



-- B. Count the number of transactions each staff has been processing and find 
--    the staff member (id) with the biggest number of transactions and also
--    the staff member with the biggest sum of the transaction value.

SELECT staff_id, COUNT(amount), SUM(amount)
FROM payment 
GROUP BY staff_id;
-- SOLUTION:
-- Staff ID 1: Nb. of transactions=7292 ; Transaction Value=30,252.12
-- Staff ID 2: Nb. of transactions=7304 ; Transaction Value=31,059.92
-- i.e. staff ID 2 is more likely to be crowned employee of the month.



-- C. Find all stores with more than 300 customers. Report the ID of the store.

SELECT store_id,
      CASE 
         WHEN COUNT(customer_id) > 300 THEN COUNT(customer_id)
		 ELSE NULL
      END
FROM customer
GROUP BY store_id;
-- SOLUTION:
-- Only Store ID 1 has over 300 (326) customers registered.


-- D. Find all customers who spent more than 200. Report the ID of the
--    customer as well as the sum spent.

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 200;
-- SOLUTION:
-- Customer ID 148: Transaction Value=211.55
-- Customer ID 526: Transaction Value=208.58


-- E. Find the films whose rental rate is higher than the average rental rate. 
--    Use a subquery and count the number of films.

SELECT film.film_id, rental_rate, title, COUNT(*)
FROM film
LEFT JOIN inventory 
ON film.film_id=inventory.film_id
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
GROUP BY title, film.film_id;
-- SOLUTION: This gives us the list of films by their id.
-- There are 659 films returned in this query.


-- F. Find films that have return date between 2005-05-29 and 2005-05-30 and 
--    report the movie titles. Use a subquery.

SELECT DISTINCT film.film_id, title
FROM film
LEFT JOIN inventory 
ON film.film_id=inventory.film_id
LEFT JOIN rental 
ON inventory.inventory_id=rental.inventory_id
WHERE return_date
IN (SELECT return_date FROM rental WHERE return_date 
	BETWEEN '2005-05-29 00:00:00' AND '2005-05-30 23:59:59')
GROUP BY title, film.film_id, rental.inventory_id, return_date;
-- SOLUTION: This gives us the list of films by their id.
-- There are 164 films returned in this query.

