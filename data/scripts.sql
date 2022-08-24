

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT max(yearid), min(yearid)
FROM allstarfull

--2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT min(height) AS height, namefirst, namelast, a.g_all
FROM people AS p
JOIN appearances AS a
ON a.g_all = a.g_all
GROUP BY namefirst, namelast, a.g_all
ORDER BY height

SELECT *
FROM appearances


