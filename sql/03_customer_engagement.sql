
/*
Project: Zomato Restaurant Analytics
Script: 03_customer_engagement.sql
Purpose: Analyze votes and customer engagement.
Database: zomato_analysis
Table: zomato_clean
*/

USE zomato_analysis;

-- =====================================================
-- 1. RATINGS BY VOTE COUNT BAND
-- =====================================================

SELECT
    CASE
        WHEN Votes < 50 THEN '0-49'
        WHEN Votes < 100 THEN '50-99'
        WHEN Votes < 500 THEN '100-499'
        WHEN Votes < 1000 THEN '500-999'
        ELSE '1000+'
    END AS vote_band,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(
        AVG(NULLIF(`Aggregate rating`, 0)), 2
    ) AS average_rating,
    SUM(Votes) AS total_votes
FROM zomato_clean
GROUP BY vote_band
ORDER BY MIN(Votes);


-- =====================================================
-- 2. VOTE COUNT VS AVERAGE PRICE RANGE
-- =====================================================

SELECT
    CASE
        WHEN Votes < 50 THEN '0-49'
        WHEN Votes < 100 THEN '50-99'
        WHEN Votes < 500 THEN '100-499'
        WHEN Votes < 1000 THEN '500-999'
        ELSE '1000+'
    END AS vote_band,
    COUNT(*) AS total_restaurants,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2)
        AS average_rating,
    ROUND(AVG(`Price range`), 2)
        AS average_price_range
FROM zomato_clean
GROUP BY vote_band
ORDER BY MIN(Votes);


-- =====================================================
-- 3. TOP 10 RESTAURANTS BY VOTES
-- =====================================================

SELECT
    `Restaurant Name`,
    City,
    `Aggregate rating`,
    Votes,
    `Has Online delivery`,
    `Has Table booking`,
    `Price range`
FROM zomato_clean
ORDER BY Votes DESC
LIMIT 10;


-- =====================================================
-- 4. ORDINARY VS WEIGHTED RATINGS BY CITY
-- =====================================================

SELECT
    City,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,

    ROUND(
        AVG(NULLIF(`Aggregate rating`, 0)), 2
    ) AS ordinary_avg_rating,

    ROUND(
        SUM(
            CASE WHEN `Aggregate rating` > 0
                 THEN `Aggregate rating` * Votes
                 ELSE 0 END
        ) * 1.0 /
        NULLIF(
            SUM(
                CASE WHEN `Aggregate rating` > 0
                     THEN Votes ELSE 0 END
            ), 0
        ), 2
    ) AS weighted_avg_rating

FROM zomato_clean
GROUP BY City
HAVING SUM(`Aggregate rating` > 0) >= 30
ORDER BY total_restaurants DESC;


-- =====================================================
-- 5. ORDINARY VS WEIGHTED RATINGS BY CUISINE
-- =====================================================

SELECT
    Cuisines,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,

    ROUND(
        AVG(NULLIF(`Aggregate rating`, 0)), 2
    ) AS ordinary_avg_rating,

    ROUND(
        SUM(
            CASE WHEN `Aggregate rating` > 0
                 THEN `Aggregate rating` * Votes
                 ELSE 0 END
        ) * 1.0 /
        NULLIF(
            SUM(
                CASE WHEN `Aggregate rating` > 0
                     THEN Votes ELSE 0 END
            ), 0
        ), 2
    ) AS weighted_avg_rating

FROM zomato_clean
GROUP BY Cuisines
HAVING SUM(`Aggregate rating` > 0) >= 30
ORDER BY total_restaurants DESC
LIMIT 15;


-- =====================================================
-- 6. OVERALL ORDINARY VS WEIGHTED RATING
-- =====================================================

SELECT
    ROUND(
        AVG(NULLIF(`Aggregate rating`, 0)), 2
    ) AS ordinary_avg_rating,

    ROUND(
        SUM(
            CASE WHEN `Aggregate rating` > 0
                 THEN `Aggregate rating` * Votes
                 ELSE 0 END
        ) * 1.0 /
        NULLIF(
            SUM(
                CASE WHEN `Aggregate rating` > 0
                     THEN Votes ELSE 0 END
            ), 0
        ), 2
    ) AS weighted_avg_rating

FROM zomato_clean;

-- Notes:
-- Ordinary average gives every rated restaurant equal influence.
-- Weighted average gives restaurants with more votes more influence.
-- Votes are an engagement measure, not necessarily unique customers.
-- These associations do not establish causation.

-- End of script
