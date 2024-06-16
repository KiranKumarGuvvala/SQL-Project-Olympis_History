-- 1- athletes : it has information about all the players participated in olympics
-- 2- athlete_events : it has information about all the events happened over the year.(athlete id refers to the id column in athlete table)

SELECT *
FROM athlete_events;

SELECT *
FROM athletes;
-- 1 which team has won the maximum gold medals over the years.
SELECT team, COUNT(DISTINCT event) as cnt 
FROM athlete_events as ae
INNER JOIN  athletes as a 
ON ae.athlete_id=a.id
WHERE medal='Gold'
GROUP BY team
ORDER BY cnt DESC 
LIMIT 1;

-- 2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
	-- team,total_silver_medals, year_of_max_silver
WITH cte as(
 SELECT a.team,ae.year, COUNT(DISTINCT event ) as Silver_Medals,
 RANK() OVER (PARTITION BY team ORDER BY COUNT(DISTINCT event ) DESC ) as Rn
 FROM athlete_events as ae 
 INNER JOIN   athletes as a 
 ON ae.athlete_id=a.id
 WHERE medal='Silver'
 GROUP BY a.team,ae.year)
 SELECT Team , SUM(Silver_Medals) as Total_Silver_Medals,
 MAX(CASE WHEN Rn=1 
 THEN YEAR END) as  Year_of_Max_Silver
 FROM cte 
 GROUP BY team;
 
-- 3 which player has won maximum gold medals  amongst the players 
	-- which have won only gold medal (never won silver or bronze) over the years
WITH cte as (
SELECT name, medal
FROM athlete_events as ae 
INNER JOIN athletes as a 
ON ae.athlete_id=a.id)
SELECT name,COUNT(medal) as No_Of_Gold_Medals
FROM cte 
WHERE name in ( SELECT DISTINCT name FROM cte WHERE medal IN ('Silver','Bronze'))
AND medal=('Gold')
GROUP BY name
ORDER BY No_Of_Gold_Medals DESC
LIMIT 1;

-- 5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
	-- print 3 columns medal,year,sport
  
    SELECT DISTINCT * FROM (
    SELECT medal,year,event,
    RANK() OVER (PARTITION BY medal ORDER BY year) as Rn
    FROM athlete_events as ae
    INNER JOIN athletes as a 
    ON ae.athlete_id=a.id
    WHERE team='India' AND medal !='NA'
) K 
WHERE Rn=1;

  WITH cte as (
    SELECT medal,year,event,
    RANK() OVER (PARTITION BY medal ORDER BY year) as Rn
    FROM athlete_events as ae
    INNER JOIN athletes as a 
    ON ae.athlete_id=a.id
    WHERE team='India' AND medal !='NA'
) 
SELECT DISTINCT *
FROM cte 
WHERE Rn=1;
-- 6 find players who won gold medal in summer and winter olympics both
SELECT a.name
FROM athlete_events as ae
INNER JOIN athletes as a
ON ae.athlete_id=a.id
WHERE medal='Gold'
GROUP BY a.name
HAVING COUNT(DISTINCT season)=2;

-- 7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
SELECT year,name
FROM athlete_events as ae
INNER JOIN athletes as a
ON ae.athlete_id=a.id
WHERE medal!='NA'
GROUP BY year,name
HAVING COUNT(DISTINCT medal)=3;

-- 8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
	-- Assume summer olympics happens every 4 year starting 2000. print player name and event name.
    WITH cte as(
    SELECT name,year,event
    FROM athlete_events as ae
    INNER JOIN athletes as a 
    ON ae.athlete_id=a.id
    WHERE year>=2000 AND season='summer' AND medal='gold'
    GROUP BY name,year,event)
    SELECT * FROM
    (SELECT *, LAG(year,1) OVER (PARTITION BY name,event ORDER BY year) as Prev_Year,
    LEAD(year,1) OVER (PARTITION BY name,event ORDER BY year) as Nxt_Year
    FROM cte) K
    WHERE year=Prev_Year+4 AND year =Nxt_Year-4
    
    
    






