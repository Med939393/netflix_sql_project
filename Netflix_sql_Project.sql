-- Netflix project 
DROP table IF EXISTS netflix ;
CREATE table netflix ( show_id VARCHAR(6),

      type VARCHAR (10),
	   
      title VARCHAR (115),
	  
     director VARCHAR (280),

     casts    VARCHAR (1000),

    country VARCHAR(150),
   
    date_added VARCHAR(50),

    release_year INT,

   rating VARCHAR(10),
   
   duration VARCHAR(15),

   listed_in VARCHAR(150),

   description VARCHAR(300)
 );

select * from netflix

--Q1 Count the Number of Movies vs TV Shows:

select type, count(*) as total_content from netflix group by 1

--Q2 Find the Most Common Rating for Movies and TV Shows : 

with cte as (select type ,rating,count(*) as total_content ,rank() over (partition by type order by count(*) DESC ) as rk 
from netflix group by 1,2 )

SELECT 
    type,
    rating AS most_frequent_rating from cte where rk=1

--Data cleaning.

select director,casts,country from netflix where director is null or casts is null or country is null or duration is null

 DELETE from netflix 
  where director is null or casts is null or country is null
  
Q3--List All Movies Released in a Specific Year (e.g., 2020):

select * from netflix  where release_year = 2020

Q4--Find the Top 5 Countries with the Most Content on Netflix:

with cte as (select country ,count(*) as total_content , 
row_number() over ( order by  count(*) DESC  ) as rn from netflix group by 1 )
select country,total_content from cte where rn <=5 

Q5--Identify the Longest Movie:

SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC limit 5 

Q6--Find Content Added in the Last 5 Years:

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

Q7--Find All Movies/TV Shows by Director 'Rajiv Chilaka' :

SELECT * from netflix

WHERE Director = 'Rajiv Chilaka%';

Q8--List All TV Shows with More Than 5 Seasons:

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5; 

Q9--Count the Number of Content Items in Each Genre :   

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

Q10--Find each year and the average numbers of content release in India on netflix:
--return top 5 year with highest avg content release!

 with cte as (SELECT release_year, 
       COUNT(*) AS numbers_of_content
FROM netflix
WHERE country = 'India'
GROUP BY release_year)
select release_year,round(avg(numbers_of_content),0) as average_numbers_of_content from cte group by 1 order by 2 DESC limit 5

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

Q11--List All Movies that are Documentaries :

SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';
  
Q12--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years : 

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

Q13--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India : 

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

Q14--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords : 

with cte as (
   SELECT *,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix

)

SELECT 
    category,
    COUNT(*) AS content_count from cte group by category
 