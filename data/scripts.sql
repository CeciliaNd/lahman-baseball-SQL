

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT COUNT(DISTINCT year)
FROM homegames;

--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT min(p.height) AS height, p.namefirst AS first_name, p.namelast AS last_name, a.g_all AS total_games, a.teamid AS team_name
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
GROUP BY p.namefirst, p.height, p.namelast, a.teamid, a.g_all
ORDER BY height

--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT distinct p.namefirst AS first_name, p.namelast AS last_name, cp.schoolid AS school_name, sum(sl.salary) AS salary
FROM people AS p
JOIN collegeplaying AS cp
ON  p.playerid = cp.playerid
JOIN salaries AS sl
ON cp.playerid = sl.playerid
WHERE cp.schoolid LIKE 'vand%'
group by p.namefirst, p.namelast, cp.schoolid
ORDER BY salary DESC 

 
--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016. 
SELECT pos as Positions, 
    case when pos = 'OF' then 'Outfield'
        when pos = 'SS' then 'Infield'
        when pos = '1B' then 'Infield'
        when pos = '2B' then 'Infield'
        When pos = '3B' then 'Infield'
        when pos = 'P' then 'Battery'
        when pos = 'C' then 'Battery'
        END As position,
        sum(po)
FROM fielding 
group by fielding.pos

--5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT (yearid)/10*10 AS decade, SUM(so) as so_batter, SUM(so) as so_batter, SUM(soa) as so_pitcher, ROUND(CAST(SUM(so) as dec) / CAST(SUM(g/2) as dec), 2) as so_per_game, ROUND(CAST(SUM(hr) as dec) / CAST(SUM(g/2) as dec), 2) as hr_per_game
FROM teams
WHERE (yearid)/10*10 >= 1920
group by decade
order by decade

--6.Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

Select playerid,
nameFirst As first_name,
nameLast As last_name,
Round(CAST(SUM(SB) AS numeric)/ CAST((SUM(SB)+SUM(CS))AS numeric),2) AS perc_steal_success,
Sum(SB) AS steal_success,
Sum(CS) AS steal_failure
FROM people
LEFT JOIN batting
USING(playerid)
WHERE yearID = 2016
GROUP BY playerid, first_name, last_name
Having (sum(SB)+SUM(CS)) >=20
Order by perc_steal_success desc;

--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 

SELECT yearid, teamid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
        AND wswin = 'N'
ORDER BY w DESC;

--What is the smallest number of wins for a team that did win the world series?
SELECT yearid, teamid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
        AND wswin = 'Y'
ORDER BY w;

--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

WITH winnie AS (
            SELECT yearid, teamid, w, wswin, MAX(w) OVER(PARTITION BY yearid) AS most_wins, 
CASE WHEN wswin = 'Y' THEN CAST (1 AS numeric)
ELSE CAST (0 AS numeric) END AS ynbin
FROM teams
WHERE yearid BETWEEN 1970 and 2016
)
SELECT SUM (ynbin) AS most_wins_wsin, COUNT(DISTINCT yearid) AS all_years, ROUND(SUM(ynbin)/COUNT(DISTINCT yearid)* 100,2) AS perc_most_wins_wswin
FROM winnie
WHERE w = most_wins

--8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Looking at top:
SELECT park_name, teams.name AS team,
SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames as h
LEFT JOIN parks
USING (park)
LEFT JOIN teams
ON h.team = teams.teamid AND h.year = teams.yearid
WHERE year = 2016
GROUP BY park_name, teams.name
HAVING SUM(games) >= 10
ORDER BY avg_attendance DESC

--Looking at bottom
SELECT park_name, teams.name AS team, SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames AS h
LEFT JOIN parks
USING (park)
LEFT JOIN teams
ON h.team = teams.teamid AND h.year = teams.yearid
WHERE year = 2016
GROUP BY park_name, teams.name
HAVING SUM(games) >= 10
ORDER BY avg_attendance

--9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH tsn_n1 AS
(SELECT playerid, awardid, yearid, 1gid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND 1gid = 'NL'),

tsn_al AS
(SELECT playerid, awardid, yearid, 1gid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND id = 'AL'),




winners_only AS
    (SELECt tsn_n1.playerid, namefirst, namelast, tsn_n1.awardid, 
tsn_n1.yearid AS n1_year,
tsn_a1.yearid AS al_year
FROM tsn_n1
INNER JOIN tsn_al
USING (playerid)
LEFT JOIN people
USING(playerid))


SELECT subq.playerid, namefirst, namelast, team, awardid, year, league
FROM(SELECT n1_year AS year, playerid, namefirst, namelast, awardid
    FROM winners_only
    UNION
    SELECT a1_year, playerid, namefirst, namelast, awardid
    FROM winners_only) AS subq
LEFT JOIN
(SELECT n1_year AS year, 'n1' AS league
FROM winners_only
UNION
SELECT a1_year AS year, 'a1'
FROM winners_only) AS subq2
USING(year)
LEFT JOIN 
(SELECT playerid, yearid, teamid, name AS team
FROM managers
LEFT JOIN teams
USING(teamid, yearid)) AS subq3
ON subq.playerid = subq3.playerid AND subq.year = subq3.yearid
ORDER BY year;


--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH hr_sixteen AS
(SELECT playerid, yearid, SUM(hr) as player_hr_sixteen
FROM batting
WHERE yearid = 2016
GROUP by playerid, yearid
ORDER BY player_hr_sixteen DESC),

yearly_hr AS
(SELECT playerid, yearid, SUM(hr) AS hr_yearly,
MAX(SUM(hr)) OVER(PARTITION BY playerid) AS best_year_hrs
FROM batting
GROUP BY playerid, yearid),

yp As
(SELECT COUNT(DISTINCT yearid) AS years_played, playerid
FROM batting 
GROUP BY playerid)

SELECT playerid, namefirst, namelast, hr_yearly AS total_hr_2016, years_played 
FROM yearly_hr
INNER JOIN hr_sixteen
USING(playerid)
INNER JOIN people
USING(playerid)
WHERE best_year_hrs = player_hr_sixteen
AND hr_yearly > 0
AND yearly_hr.yearid = 2016
AND years_played >= 10
ORDER BY playerid




























