

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
SELECT p.namefirst AS first_name, p.namelast AS last_name, s.schoolname AS school_name, sl.salary AS salary
FROM people AS p
WHERE schoolname = 'Vanderbilt'
JOIN schools AS s
ON s.schoolid = p.playerid
JOIN salaries AS sl
ON p.playerid = sl.playerid
GROUP BY p.namefirst, p.namelast, s.schoolname, sl.salary











