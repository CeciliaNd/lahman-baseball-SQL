

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT max(yearid), min(yearid)
FROM allstarfull

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
SELECT round(avg(SO)) AS BStrikeouts, round(avg(SOA)) AS PStrikeouts, round(avg(HR)) AS Homeruns , G AS Games, yearid AS year
From teams as t
where yearid = 1920
group by t.hr, t.g, t.yearid

--6.Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

Select b.sb, b.cs, b.sb/b.cs AS successful_stolen_bases, p.namefirst, p.namelast
From batting as b
join people as p
on b.playerid = p.playerid
where b.yearid=2016 and sb>=20
group by p.namefirst, p.namelast, b.sb, b.cs 
order by successful_stolen_bases desc


























