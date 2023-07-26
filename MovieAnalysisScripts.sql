
--Found 10,00 dupliactes in the imported data so used a CTE to find the dupliates and delete them.

begin transaction;

with cte as
(
SELECT row_number() over (partition by id, title, original_language, rating order by id) as [sequence], *
FROM Movies_data

) 

delete from cte
where [sequence] != 1

select * from Movies_data
ORDER BY id

--rollback transaction;
--commit transaction;

--how many movies were released per year

SELECT YEAR(release_date) AS ReleaseYear, COUNT(release_date) AS MovieCount
FROM Movies_data
GROUP BY YEAR(release_date)
ORDER BY ReleaseYear DESC

--count of all the ratings

SELECT rating, COUNT(rating) AS TotalCount
FROM Movies_data
GROUP BY rating
ORDER BY rating DESC

--count of all the movies in their original language

SELECT original_language, COUNT(original_language) AS TotalCount
FROM Movies_data
GROUP BY original_language
ORDER BY TotalCount DESC

--most rated movies

SELECT TOP 10 title, rating
FROM Movies_data
ORDER BY rating DESC

--least rated movies

SELECT TOP 10 title, rating
FROM Movies_data
ORDER BY rating ASC

--Average rating of movies by language and limiting to 1 decimal

SELECT original_language, ROUND(AVG(rating),1) AS Average 
FROM Movies_data
GROUP BY original_language
ORDER BY Average DESC


-- Adding Movie Recomendations

SELECT title, rating,
CASE
	WHEN rating >= 6 THEN 'Worth a watch'
	WHEN rating < 6 THEN 'Avoid'
	END AS MovieRecomendation
FROM Movies_data
ORDER BY rating DESC


-- How many of each Movie Recomendation - using CTE


WITH MovieRecomendations AS
(
SELECT title, rating,
CASE
	WHEN rating >= 6 THEN 'Worth a watch'
	WHEN rating < 6 THEN 'Avoid'
	END AS MovieRecomendation
FROM Movies_data
)

SELECT MovieRecomendation, COUNT(MovieRecomendation) AS MovieRecomendationCount
FROM MovieRecomendations
GROUP BY MovieRecomendation

-- How many of each Movie Recomendation - using nested statement

SELECT MovieRecomendation, COUNT(MovieRecomendation) AS CountM
FROM
(
SELECT title, rating,
CASE
	WHEN rating >= 6 THEN 'Worth a watch'
	WHEN rating < 6 THEN 'Avoid'
	END AS MovieRecomendation
FROM Movies_data
) ab
GROUP BY MovieRecomendation

