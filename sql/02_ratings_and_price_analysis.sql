
/*
Project: Zomato Restaurant Analytics
Script: 02_ratings_and_price_analysis.sql
Purpose: Analyze restaurant ratings, price ranges, and rating coverage.
Database: zomato_analysis
Working table: zomato_clean
*/

USE zomato_analysis;

-- =====================================================
-- 1. RATINGS AND RATING COVERAGE BY PRICE RANGE
-- =====================================================

SELECT
    `Price range` AS price_range,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    SUM(`Aggregate rating` = 0) AS unrated_restaurants,
    ROUND(
        100.0 * SUM(`Aggregate rating` > 0) / COUNT(*),
        2
    ) AS rating_coverage_pct,
    ROUND(
        AVG(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating`
            END
        ),
        2
    ) AS average_rating
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;


-- =====================================================
-- 2. ORDINARY AND VOTE-WEIGHTED RATINGS BY PRICE RANGE
-- =====================================================

SELECT
    `Price range` AS price_range,
    ROUND(
        AVG(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating`
            END
        ), 2
    ) AS ordinary_avg_rating,
    ROUND(
        SUM(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating` * Votes
                ELSE 0
            END
        ) * 1.0 /
        NULLIF(
            SUM(
                CASE
                    WHEN `Aggregate rating` > 0
                    THEN Votes
                    ELSE 0
                END
            ), 0
        ), 2
    ) AS weighted_avg_rating
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;


-- =====================================================
-- 3. VOTE-WEIGHTED RATING GAP BY PRICE RANGE
-- =====================================================

SELECT
    `Price range` AS price_range,
    ROUND(
        SUM(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating` * Votes
                ELSE 0
            END
        ) * 1.0 /
        NULLIF(
            SUM(
                CASE
                    WHEN `Aggregate rating` > 0
                    THEN Votes
                    ELSE 0
                END
            ), 0
        ), 2
    )
    -
    ROUND(
        AVG(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating`
            END
        ), 2
    ) AS rating_gap
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;


-- =====================================================
-- 4. ONLINE DELIVERY VS. RATINGS
-- =====================================================

SELECT
    `Has Online delivery` AS online_delivery,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    SUM(`Aggregate rating` = 0) AS unrated_restaurants,
    ROUND(
        AVG(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating`
            END
        ), 2
    ) AS average_rating
FROM zomato_clean
GROUP BY `Has Online delivery`
ORDER BY online_delivery;


-- =====================================================
-- 5. TABLE BOOKING AVAILABILITY BY PRICE RANGE
-- =====================================================

SELECT
    `Price range` AS price_range,
    `Has Table booking` AS table_booking,
    COUNT(*) AS total_restaurants,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY `Price range`),
        2
    ) AS pct_within_price_range
FROM zomato_clean
GROUP BY `Price range`, `Has Table booking`
ORDER BY `Price range`, `Has Table booking`;


-- =====================================================
-- 6. ONLINE DELIVERY VS. PRICE RANGE
-- =====================================================

SELECT
    `Price range` AS price_range,
    `Has Online delivery` AS online_delivery,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(
        AVG(
            CASE
                WHEN `Aggregate rating` > 0
                THEN `Aggregate rating`
            END
        ), 2
    ) AS average_rating,
    SUM(Votes) AS total_votes
FROM zomato_clean
GROUP BY `Price range`, `Has Online delivery`
ORDER BY `Price range`, `Has Online delivery`;


-- End of script
