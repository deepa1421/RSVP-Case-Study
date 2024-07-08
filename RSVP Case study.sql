
-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select production_company, sum(total_votes) as vote_count, 
dense_rank() over (order by sum(total_votes) desc) as prod_comp_rank
from
movie as m
inner join ratings as r
on m.id=r.movie_id
group by production_company
limit 3;

--- Marvel Company is ruling the industry. RSVP should try to colaborate with them and try to cast some indian actors.


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

With Actors 
as
(
	select  name as actor_name, 
			sum(total_votes) as total_votes, 
			count(name) as movie_count,
			round(sum(avg_rating * total_votes)/ sum(total_votes),2) as actor_avg_rating
    from names as n
	inner join role_mapping as ro
	on n.id = ro.name_id
	inner join movie as m
	on ro.movie_id = m.id
	inner join ratings as ra
	on m.id= ra.movie_id
	where country regexp 'india' and category = 'actor'
	group by name_id
	having movie_count >=5) 
select *,
dense_rank() over (order by actor_avg_rating desc, total_votes desc) as actor_rank
from Actors;

-- Top actor is Vijay Sethupathi--RSVP should think of casting Vijay Setupathi if they colaborate with Marvels.

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

with Top_Actress
as 
( select name as actress_name,
		 sum(total_votes) as total_votes,
         count(name) as movie_count,
		 round(sum(avg_rating * total_votes)/ sum(total_votes),2) as actress_avg_rating
	from names as n
    inner join role_mapping as ro
    on n.id = ro.name_id
    inner join movie as m
    on ro.movie_id = m.id
    inner join ratings as ra
    using (movie_id)
    where languages regexp 'Hindi' and country regexp 'India' and category = 'actress'
    group by actress_name 
    having count(actress_name) >=3)
    select *,
		dense_rank() over (order by actress_avg_rating desc, total_votes desc) as actress_rank
    from Top_Actress
    limit 5;
    

/* Taapsee Pannu tops with average rating 7.74. RSVP should consider casting Taapsee Pannu opposite to vijay sethupathi.
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
select title as movie, avg_rating,
	case
		when avg_rating > 8 then 'Superhit movies'
		when avg_rating between 7 and 8 then 'Hit movies'
		when avg_rating between 5 and 7 then 'One-time-watch movies'
		when avg_rating < 5 then 'Flop movies'
	end avg_rating_category
from genre as g
inner join ratings as ra
using (movie_id)
inner join movie as m
on ra.movie_id = m.id
where genre = 'thriller';

--- Safe	9.5	Superhit movies is the movie that tops the chart. followed by Digbhayam	9.2	Superhit movies with 9 and above VG_RATING


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select genre,
		round(avg(duration),2) as avg_duration,
        sum(round(avg(duration),2)) over (order by genre rows unbounded preceding) as running_total_duration,
        avg(round(avg(duration),2)) over (order by genre rows 10 preceding) as moving_avg_duration
	from genre as g
    inner join movie as m
    on g.movie_id = m.id
    group by genre
    order by genre;
   
-- Round is good to have and not a must have; Same thing applies to sorting. we can observe that avg_duration for action movies is highest with a running total of 112.88 and moving_avg_duration as 112.88. SInce marvel makes most of the action movies RSVP should think of making an action movie along with the production house(marvels).


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

with top_3_genres AS
(select genre,
		count(movie_id) as number_of_movies
from genre as g
inner join movie as m
on g.movie_id = m.id
group by genre
order by number_of_movies desc
limit 3),

top_5 AS
(select genre, year,
		title as movie_name,
        worlwide_gross_income,
        dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank
        
	from movie as m
    inner join genre as g
    on m.id = g.movie_id
		where genre in (select genre from top_3_genres)
	)
    
    select*
    from top_5
	where movie_rank <=5;
-- We can see that the all the top three genres rank goes to Drama. The five highest-grossing movies of each year are as follows: 1. Shatamanam Bhavati, genre: Drama,	year:2017, 2. Winner, genre: Drama,	year:2017, 3. Thank You for Your Service, genre: Drama,	year:2017, 4. The Healer, genre: Comedy, year:2017, 5. The Healer, genre: Drama, year:2017. We might consider Gi-eok-ui bam on 5th rank as the Healer movie has two genres with same title.


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
select production_company,
		count(id) as movie_count,
        row_number() over (order by count(id) desc) as prod_comp_rank
	from movie as m
    inner join ratings as ra
    on m.id = ra.movie_id
    where median_rating >=8 and production_company is not null and position(',' in languages) > 0
    group by production_company
    limit 2;
	

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language
-- The top 2 production companies are  Star Cinema	with a movie_count = 7 and prod_com_rank = 1 followed by Twentieth Century Fox	with movie_count of 4	ranking 2. 


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


select name as actress_name,
		sum(total_votes) as total_votes,
        count(name) as movie_count,
        round(sum(avg_rating*total_votes) / sum(total_votes), 2) as actress_avg_rating,
        row_number() over(order by count(name) desc) as actress_rank
 from genre as g
inner join movie as m
on g.movie_id = m.id
inner join ratings as ra
using (movie_id)
inner join role_mapping as rm
using (movie_id)
inner join names as n
on rm.name_id = n.id
where avg_rating > 8 and genre = 'drama' and category = 'actress'
group by name
limit 3;

/* Top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre are as follows:
Parvathy Thiruvothu		4974	2	8.25	1
Susan Brown				656		2	8.94	2
Amanda Lawrence			656		2	8.94	3
*/






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
with top_9_directors as
( select name_id as Director_id,
		name as director_name,
        avg_rating,
        total_votes,
        duration,
        date_published,
        lead(date_published,1) over(partition by name_id order by date_published) as next_date_published
	from director_mapping as dm
    inner join names as n
    on dm.name_id = n.id
    inner join movie as m
    on dm.movie_id = m.id
    inner join ratings as ra
    using (movie_id))
select director_id,
	director_name,
    count(director_name) as number_of_movies,
    round(avg(datediff(next_date_published, date_published)),0) as avg_inter_movie_days,
    round(avg(avg_rating),2) as avg_rating,
    sum(total_votes) as total_votes,
    min(avg_rating) as min_rating,
    max(avg_rating) as max_rating,
    sum(duration) as total_duration
from top_9_directors
group by director_id
order by number_of_movies desc
limit 9;

-- The top 9 directors are as follows: nm2096009	Andrew Jones	5	191	3.02	1989	2.7	3.2	432
/*nm1777967	A.L. Vijay			5	177	5.42	1754	3.7	6.9	613
nm0814469	Sion Sono			4	331	6.03	2972	5.4	6.4	502
nm0831321	Chris Stokes		4	198	4.33	3664	4.0	4.6	352
nm0515005	Sam Liu				4	260	6.23	28557	5.8	6.7	312
nm0001752	Steven Soderbergh	4	254	6.48	171684	6.2	7.0	401
nm0425364	Jesse V. Johnson	4	299	5.45	14778	4.2	6.5	383
nm2691863	Justin Price		4	315	4.50	5343	3.0	5.8	346
nm6356309	Özgür Bakar			4	112	3.75	1092	3.1	4.9	374
*/
    
    
    






