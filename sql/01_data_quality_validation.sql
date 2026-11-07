/*
Project: Zomato Restaurant Analytics
Script: 01_data_quality_validation.sql
Purpose: Reconstruct core data-quality checks for the existing MySQL dataset.

Database: zomato_analysis
Working table: zomato_clean
Expected rows: 9,551

IMPORTANT:
- SELECT statements only; this script does not modify or delete data.
- Run sections individually if you want to inspect each result.
- Previously observed findings are notes from the earlier analysis and should
  be re-verified if the database has since changed.
*/

USE zomato_analysis;

-- 1. TABLE INVENTORY AND ROW COUNTS
SHOW TABLES;

SELECT 'zomato' AS table_name, COUNT(*) AS total_rows FROM zomato
UNION ALL
SELECT 'zomato_clean', COUNT(*) FROM zomato_clean;

-- 2. WORKING TABLE ROW COUNT AND UNIQUE IDS
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Restaurant ID`) AS unique_restaurant_ids,
    COUNT(*) - COUNT(DISTINCT `Restaurant ID`) AS repeated_id_rows
FROM zomato_clean;
-- Previously observed: 9,551 rows, 9,551 unique IDs, 0 repeated-ID rows.

-- 3. ORIGINAL TABLE DUPLICATE-IMPORT CHECK
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `Restaurant ID`) AS unique_restaurant_ids,
    COUNT(*) - COUNT(DISTINCT `Restaurant ID`) AS repeated_id_rows
FROM zomato;
-- Previously observed: 19,102 rows, 9,551 unique IDs, 9,551 repeated-ID rows.
-- This supports a duplicate-import explanation, but repeated IDs alone do not
-- prove full rows are identical.

-- Preliminary distinct-record check. CONCAT_WS skips NULL values, so this
-- is not a perfect NULL-aware full-row comparison.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT_WS(
        '|',
        `Restaurant ID`, `Restaurant Name`, `Country Code`, `City`,
        `Address`, `Locality`, `Locality Verbose`, `Longitude`, `Latitude`,
        `Cuisines`, `Average Cost for two`, `Currency`, `Has Table booking`,
        `Has Online delivery`, `Is delivering now`, `Switch to order menu`,
        `Price range`, `Aggregate rating`, `Rating color`, `Rating text`,
        `Votes`
    )) AS distinct_records
FROM zomato;

-- 4. WORKING TABLE SCHEMA
DESCRIBE zomato_clean;

-- 5. NULL AUDIT ACROSS ALL 21 COLUMNS
SELECT
    SUM(`Restaurant ID` IS NULL) AS null_restaurant_id,
    SUM(`Restaurant Name` IS NULL) AS null_restaurant_name,
    SUM(`Country Code` IS NULL) AS null_country_code,
    SUM(`City` IS NULL) AS null_city,
    SUM(`Address` IS NULL) AS null_address,
    SUM(`Locality` IS NULL) AS null_locality,
    SUM(`Locality Verbose` IS NULL) AS null_locality_verbose,
    SUM(`Longitude` IS NULL) AS null_longitude,
    SUM(`Latitude` IS NULL) AS null_latitude,
    SUM(`Cuisines` IS NULL) AS null_cuisines,
    SUM(`Average Cost for two` IS NULL) AS null_average_cost,
    SUM(`Currency` IS NULL) AS null_currency,
    SUM(`Has Table booking` IS NULL) AS null_table_booking,
    SUM(`Has Online delivery` IS NULL) AS null_online_delivery,
    SUM(`Is delivering now` IS NULL) AS null_is_delivering_now,
    SUM(`Switch to order menu` IS NULL) AS null_switch_to_order_menu,
    SUM(`Price range` IS NULL) AS null_price_range,
    SUM(`Aggregate rating` IS NULL) AS null_aggregate_rating,
    SUM(`Rating color` IS NULL) AS null_rating_color,
    SUM(`Rating text` IS NULL) AS null_rating_text,
    SUM(`Votes` IS NULL) AS null_votes
FROM zomato_clean;
-- Previously observed: zero SQL NULL values in all 21 columns.

-- 6. BLANK OR WHITESPACE-ONLY TEXT VALUES
SELECT
    SUM(TRIM(COALESCE(`Restaurant Name`, '')) = '') AS blank_restaurant_name,
    SUM(TRIM(COALESCE(`City`, '')) = '') AS blank_city,
    SUM(TRIM(COALESCE(`Address`, '')) = '') AS blank_address,
    SUM(TRIM(COALESCE(`Locality`, '')) = '') AS blank_locality,
    SUM(TRIM(COALESCE(`Locality Verbose`, '')) = '') AS blank_locality_verbose,
    SUM(TRIM(COALESCE(`Cuisines`, '')) = '') AS blank_cuisines,
    SUM(TRIM(COALESCE(`Currency`, '')) = '') AS blank_currency,
    SUM(TRIM(COALESCE(`Has Table booking`, '')) = '') AS blank_table_booking,
    SUM(TRIM(COALESCE(`Has Online delivery`, '')) = '') AS blank_online_delivery,
    SUM(TRIM(COALESCE(`Is delivering now`, '')) = '') AS blank_is_delivering_now,
    SUM(TRIM(COALESCE(`Switch to order menu`, '')) = '') AS blank_switch_to_order_menu,
    SUM(TRIM(COALESCE(`Rating color`, '')) = '') AS blank_rating_color,
    SUM(TRIM(COALESCE(`Rating text`, '')) = '') AS blank_rating_text
FROM zomato_clean;
-- Previously observed: 9 blank Cuisines values; 0 blanks in the other checked fields.
-- Preserve those nine records unless reliable source data resolves the cuisine.

-- 7. INSPECT RECORDS WITH BLANK CUISINES
SELECT
    `Restaurant ID`, `Restaurant Name`, `City`, `Votes`, `Aggregate rating`
FROM zomato_clean
WHERE TRIM(COALESCE(`Cuisines`, '')) = ''
ORDER BY City, `Restaurant Name`;

-- 8. NUMERIC RANGE AND VALIDITY CHECKS
SELECT
    MIN(`Restaurant ID`) AS min_restaurant_id,
    SUM(`Restaurant ID` <= 0) AS nonpositive_restaurant_ids,
    MIN(`Country Code`) AS min_country_code,
    SUM(`Country Code` <= 0) AS nonpositive_country_codes,
    MIN(`Average Cost for two`) AS min_average_cost,
    SUM(`Average Cost for two` < 0) AS negative_costs,
    SUM(`Average Cost for two` = 0) AS zero_costs,
    MIN(`Price range`) AS min_price_range,
    MAX(`Price range`) AS max_price_range,
    SUM(`Price range` NOT BETWEEN 1 AND 4) AS invalid_price_ranges,
    MIN(`Aggregate rating`) AS min_rating,
    MAX(`Aggregate rating`) AS max_rating,
    SUM(`Aggregate rating` NOT BETWEEN 0 AND 5) AS out_of_range_ratings,
    MIN(Votes) AS min_votes,
    SUM(Votes < 0) AS negative_votes
FROM zomato_clean;
-- Previously observed: no nonpositive IDs/country codes, negative costs, invalid
-- price ranges, out-of-range ratings, or negative votes. There were 18 zero costs.

-- 9. INSPECT ZERO-COST RECORDS (DO NOT MODIFY AUTOMATICALLY)
SELECT
    `Restaurant ID`, `Restaurant Name`, `Country Code`, `City`,
    `Average Cost for two`, `Currency`, `Aggregate rating`, Votes
FROM zomato_clean
WHERE `Average Cost for two` = 0
ORDER BY `Country Code`, City, `Restaurant Name`;
-- Previously observed: 18 zero-cost records; whether these are invalid is unconfirmed.

-- 10. PRICE RANGE DISTRIBUTION
SELECT `Price range`, COUNT(*) AS total_restaurants
FROM zomato_clean
GROUP BY `Price range`
ORDER BY `Price range`;
-- Previously observed: range 1 = 4,444; range 2 = 3,113; range 3 = 1,408;
-- range 4 = 586.

-- 11. RATING TEXT / COLOR COMBINATIONS
SELECT
    `Aggregate rating`, `Rating color`, `Rating text`,
    COUNT(*) AS record_count
FROM zomato_clean
GROUP BY `Aggregate rating`, `Rating color`, `Rating text`
ORDER BY `Aggregate rating`, `Rating text`;

-- 12. CURRENCY LABELS
SELECT Currency, COUNT(*) AS record_count
FROM zomato_clean
GROUP BY Currency
ORDER BY record_count DESC, Currency;
-- Previously observed: 12 labels. A corrupted Pounds label was previously
-- corrected to 'Pounds(£)'. Verify against source data before further edits.

-- 13. SERVICE OPTION DISTRIBUTIONS
SELECT `Has Table booking`, COUNT(*) AS record_count
FROM zomato_clean GROUP BY `Has Table booking`;

SELECT `Has Online delivery`, COUNT(*) AS record_count
FROM zomato_clean GROUP BY `Has Online delivery`;

SELECT `Is delivering now`, COUNT(*) AS record_count
FROM zomato_clean GROUP BY `Is delivering now`;

SELECT `Switch to order menu`, COUNT(*) AS record_count
FROM zomato_clean GROUP BY `Switch to order menu`;

-- 14. GEOGRAPHIC COORDINATE VALIDATION
SELECT
    COUNT(*) AS total_records,
    SUM(`Latitude` < -90 OR `Latitude` > 90) AS invalid_latitudes,
    SUM(`Longitude` < -180 OR `Longitude` > 180) AS invalid_longitudes,
    SUM(`Latitude` = 0) AS zero_latitudes,
    SUM(`Longitude` = 0) AS zero_longitudes,
    SUM(`Latitude` = 0 AND `Longitude` = 0) AS both_coordinates_zero,
    SUM((`Latitude` = 0 AND `Longitude` <> 0)
        OR (`Longitude` = 0 AND `Latitude` <> 0)) AS only_one_coordinate_zero
FROM zomato_clean;
-- Previously observed: no out-of-range coordinates; 498 zero latitudes and
-- 498 zero longitudes; 497 records had both coordinates zero and 2 had only
-- one zero coordinate. The original CSV contained these zeros too.

-- 15. POSSIBLY ENCODING-AFFECTED CITY LABELS
SELECT City, COUNT(*) AS record_count
FROM zomato_clean
WHERE City LIKE '%ï¿½%'
GROUP BY City
ORDER BY City;
-- Previously observed labels appeared to represent Brasília, São Paulo, and
-- İstanbul. Verify with the original CSV before updating.

-- END OF SCRIPT
