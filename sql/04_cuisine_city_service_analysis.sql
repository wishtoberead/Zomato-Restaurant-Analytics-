/*
Project: Zomato Restaurant Analytics
Script: 04_cuisine_city_service_analysis.sql
Purpose: Compare ratings, rating coverage, cities, cuisines, and service options.
Database: zomato_analysis
Working table: zomato_clean

Notes:
- Rating = 0 means "Not rated" and is excluded from average ratings.
- These are descriptive comparisons, not causal findings.
- Cuisine labels are stored as combinations, not normalized individual cuisines.
*/

USE zomato_analysis;

-- 1. TOP-RATED CUISINE GROUPS (at least 30 rated restaurants)
SELECT
    Cuisines,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    ROUND(100.0 * SUM(`Aggregate rating` > 0) / COUNT(*), 2)
        AS rating_coverage_pct
FROM zomato_clean
GROUP BY Cuisines
HAVING SUM(`Aggregate rating` > 0) >= 30
ORDER BY average_rating DESC, rated_restaurants DESC
LIMIT 15;

-- Previously observed examples: Italian 3.95 (50 rated), Mexican 3.85 (34),
-- Desserts 3.60 (40). Re-run to refresh the exact rankings.


-- 2. CUISINE GROUPS WITH THE MOST RATED RESTAURANTS
SELECT
    Cuisines,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    ROUND(100.0 * SUM(`Aggregate rating` > 0) / COUNT(*), 2)
        AS rating_coverage_pct
FROM zomato_clean
GROUP BY Cuisines
HAVING SUM(`Aggregate rating` > 0) >= 30
ORDER BY rated_restaurants DESC
LIMIT 15;

-- Previously observed: North Indian 492 rated out of 936;
-- North Indian, Chinese 397 rated out of 511.


-- 3. CUISINE GROUPS WITH THE MOST UNRATED RESTAURANTS
SELECT
    Cuisines,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` = 0) AS unrated_restaurants,
    ROUND(100.0 * SUM(`Aggregate rating` = 0) / COUNT(*), 2)
        AS unrated_pct
FROM zomato_clean
GROUP BY Cuisines
HAVING COUNT(*) >= 50
ORDER BY unrated_restaurants DESC
LIMIT 15;

-- Previously observed: North Indian 444 unrated (47.44%);
-- Chinese 130 (36.72%); Fast Food 126 (35.59%).
-- Mughlai had the highest displayed unrated proportion: 55/103 (53.40%).
-- These are rating-coverage gaps, not evidence of dissatisfaction.


-- 4. CITY-LEVEL RATINGS AND RATING COVERAGE
SELECT
    City,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(100.0 * SUM(`Aggregate rating` > 0) / COUNT(*), 2)
        AS rating_coverage_pct,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    SUM(Votes) AS total_votes
FROM zomato_clean
GROUP BY City
HAVING SUM(`Aggregate rating` > 0) >= 100
ORDER BY average_rating DESC, total_restaurants DESC;

-- Previously observed Delhi NCR results:
-- Gurgaon: 1,118 total, 890 rated, avg 3.33.
-- New Delhi: 5,473 total, 4,048 rated, avg 3.30.
-- Noida: 1,080 total, 696 rated, avg 3.16.
-- Faridabad: 251 total, 151 rated, avg 3.10.
-- Dataset is concentrated in Delhi NCR; do not generalize to all cities.


-- 5. ONLINE DELIVERY VS RATINGS AND VOTES
SELECT
    `Has Online delivery` AS online_delivery,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    SUM(`Aggregate rating` = 0) AS unrated_restaurants,
    ROUND(100.0 * SUM(`Aggregate rating` > 0) / COUNT(*), 2)
        AS rating_coverage_pct,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    SUM(Votes) AS total_votes,
    ROUND(AVG(Votes), 2) AS average_votes
FROM zomato_clean
GROUP BY `Has Online delivery`
ORDER BY `Has Online delivery`;


-- 6. ONLINE DELIVERY VS PRICE RANGE
SELECT
    `Price range` AS price_range,
    `Has Online delivery` AS online_delivery,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    SUM(Votes) AS total_votes,
    ROUND(AVG(Votes), 2) AS average_votes
FROM zomato_clean
GROUP BY `Price range`, `Has Online delivery`
ORDER BY `Price range`, `Has Online delivery`;


-- 7. TABLE BOOKING VS RATINGS AND VOTES
SELECT
    `Has Table booking` AS table_booking,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating,
    SUM(Votes) AS total_votes,
    ROUND(AVG(Votes), 2) AS average_votes
FROM zomato_clean
GROUP BY `Has Table booking`
ORDER BY `Has Table booking`;


-- 8. TABLE BOOKING AVAILABILITY BY PRICE RANGE
SELECT
    `Price range` AS price_range,
    COUNT(*) AS total_restaurants,
    SUM(`Has Table booking` = 'Yes') AS booking_yes,
    SUM(`Has Table booking` = 'No') AS booking_no,
    ROUND(100.0 * SUM(`Has Table booking` = 'Yes') / COUNT(*), 2)
        AS booking_availability_pct
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;

-- Previously observed booking availability:
-- Range 1: 1/4,444 = 0.02%; range 2: 239/3,113 = 7.68%;
-- range 3: 644/1,408 = 45.74%; range 4: 274/586 = 46.76%.
-- Association only; price does not necessarily cause booking availability.


-- 9. FINAL COMPARISON: RATINGS AND COVERAGE BY PRICE RANGE
SELECT
    `Price range` AS price_range,
    COUNT(*) AS total_restaurants,
    SUM(`Aggregate rating` > 0) AS rated_restaurants,
    SUM(`Aggregate rating` = 0) AS unrated_restaurants,
    ROUND(100.0 * SUM(`Aggregate rating` > 0) / COUNT(*), 2)
        AS rating_coverage_pct,
    ROUND(AVG(NULLIF(`Aggregate rating`, 0)), 2) AS average_rating
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;

-- Previously verified:
-- Range 1: 4,444 total; 2,744 rated; 1,700 unrated; 61.75% coverage; avg 3.24.
-- Range 2: 3,113 total; 2,711 rated; 402 unrated; 87.09% coverage; avg 3.38.
-- Range 3: 1,408 total; 1,373 rated; 35 unrated; 97.51% coverage; avg 3.78.
-- Range 4: 586 total; 575 rated; 11 unrated; 98.12% coverage; avg 3.89.
-- Ranges 1 and 2 contain 2,102 of 2,148 unrated records (97.86%).

-- END OF SCRIPT
