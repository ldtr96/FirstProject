-- Used Azure Data Studio to import the Video Game Sales CSV from Kaggle.

--Use Videogame;

--SELECT *
--FROM GameSales;


/* This selects the top 100 titles that span multiple consoles and it's copies sold (in millions)
  where Global Sales are greater than the overall average */

 WITH Above_Avg AS (
  SELECT Rank,Name, Platform, Year_Released, Genre, Global_Sales
  FROM GameSales
  Where Global_Sales > (
    SELECT AVG(Global_Sales)
    FROM GameSales
)
)
SELECT TOP 100 
Name,
  SUM(Global_Sales) AS Copies_Sold_Per_Title,
  COUNT(Name) AS Number_Of_Versions
FROM Above_Avg 
GROUP BY Name
HAVING COUNT(Name) > 2
ORDER BY Copies_Sold_Per_Title DESC
;

/*This breaks the top 50 games down into a more granular level where
we see each copy, it's best-performing platform, genre, and global sales */

SELECT TOP 50
 Name,
 Platform,
 Genre,
 Global_Sales
 FROM GameSales
  WHERE Global_Sales IN (
     SELECT TOP 50
    MAX(Global_Sales) AS Max_Sales
    FROM GameSales
    GROUP BY Name
    ORDER BY Max_Sales DESC 
 )  
 ORDER BY Global_Sales DESC;

/* Takes the sum of all sales of the top selling version of the top 50 games */
 
 WITH top_50 AS (
     SELECT TOP 50
     Name,
     Platform,
     Genre,
     Global_Sales
 FROM GameSales
  WHERE Global_Sales IN (
     SELECT TOP 50
     MAX(Global_Sales) AS Max_Sales
     FROM GameSales
     GROUP BY Name
     ORDER BY Max_Sales DESC 
 )  
 ORDER BY Global_Sales DESC
 )

 SELECT SUM(Global_Sales) AS Sum_Of_Top_50_Sales
 FROM top_50 

/* Shows the best versions of the top 50 games along with it's Global Sales for that platform
and percentage of the sum */

WITH top_50 AS (
    SELECT TOP 50
    Name,
    Platform,
    Genre,
    Global_Sales
FROM GameSales
WHERE Global_Sales IN (
    SELECT TOP 50
    MAX(Global_Sales) AS Max_Sales
    FROM GameSales
    GROUP BY Name
    ORDER BY Max_Sales DESC 
 )  
 ORDER BY Global_Sales DESC
 )

 SELECT Name,
 Global_Sales,
 (SELECT
    SUM(Global_Sales)
    FROM top_50) AS Sum_of_Global_Sales,
    Global_sales * 100 / (
      SELECT SUM(Global_Sales)
      FROM top_50
 ) AS Percent_Of_Total
 FROM top_50
 ORDER BY Percent_Of_Total DESC;


 /* Shows the sum of sales for each genre in descending order */

 SELECT Genre,
 SUM(Global_Sales) AS Global_Sales
 FROM GameSales
 GROUP BY Genre
 ORDER BY Global_Sales DESC;


/* Returns only the Sales and name of the best performing platform, which is the Wii */


 SELECT Platform, MAX(Global_Sales) AS Sales
 FROM GameSales
 GROUP BY Platform
 HAVING Platform LIKE (
     SELECT Platform
     FROM GameSales
     WHERE Global_Sales = (
         SELECT MAX(Global_Sales)
         FROM GameSales
     )
 )

/* Wii games were listed a total of 1325 times in this whole dataset */

 SELECT COUNT(*) AS Number_of_Wii_Games
 FROM GameSales
 WHERE Platform = 'Wii'

 /* Shows most popular genres and it's sales rounded to 2 decimal points for the Wii */

 SELECT 
 Genre,
 Platform,
  ROUND(MAX(Global_Sales),2) AS Sales 
 FROM GameSales
 GROUP BY Platform, Genre 
 HAVING Platform = 'Wii'
 ORDER BY Sales DESC;