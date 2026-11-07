# Zomato Restaurant Analytics

An end-to-end data analytics project exploring restaurant ratings, customer engagement, pricing, cuisine preferences, and service availability using **MySQL and Power BI**.

## Project Overview

This project analyzes restaurant data from Zomato to identify patterns in customer ratings, restaurant pricing, voting behavior, and service availability.

The goal is to transform raw restaurant data into meaningful business insights and present the findings through an interactive Power BI dashboard.

## Business Questions

The analysis focuses on the following questions:

1. How do restaurant ratings vary across different price ranges?
2. Which price ranges have the highest number of restaurants?
3. Is customer engagement (votes) associated with restaurant pricing and ratings?
4. How do ordinary average ratings compare with vote-weighted ratings?
5. Does online delivery availability relate to restaurant ratings?
6. Which cities and cuisine combinations perform well?
7. How does rating coverage vary across price ranges?

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL | Data cleaning, validation, and exploratory analysis |
| Power BI | Interactive dashboard and visualization |
| DAX | Measures and calculated metrics |
| Excel / CSV | Dataset inspection and preparation |

## Dataset Overview

The dataset contains restaurant-level information, including:

- Restaurant ID and name
- Country and city
- Restaurant location
- Cuisines
- Average cost for two
- Price range
- Aggregate rating
- Rating text and color
- Votes
- Table booking availability
- Online delivery availability

**Dataset size:** 9,551 unique restaurants after duplicate removal.

## Data Cleaning & Preparation

The data preparation process included:

- Identifying and removing duplicate restaurant records.
- Validating restaurant IDs and record counts.
- Checking missing and blank values.
- Examining numeric fields for invalid values.
- Reviewing rating ranges and rating categories.
- Inspecting unusual cost and geographic coordinate values.
- Preserving questionable records rather than making unsupported assumptions.

The cleaned dataset contains 9,551 records with unique restaurant IDs.

## Exploratory Data Analysis

The analysis explored several dimensions:

- Restaurant ratings by price range
- Restaurant distribution by price range
- Rating coverage
- Customer votes and engagement
- Online delivery and table booking
- Cuisine and city performance
- Ordinary versus vote-weighted ratings

## Key Findings

### 1. Ratings and Price Range

| Price Range | Restaurants | Average Rating | Rating Coverage |
|---|---:|---:|---:|
| 1 | 4,444 | 3.24 | 61.75% |
| 2 | 3,113 | 3.38 | 87.09% |
| 3 | 1,408 | 3.78 | 97.51% |
| 4 | 586 | 3.89 | 98.12% |

Higher price ranges have higher average ratings and rating coverage in this dataset.

### 2. Customer Engagement

Average votes per restaurant:

| Price Range | Average Votes |
|---|---:|
| 1 | 44.60 |
| 2 | 147.61 |
| 3 | 443.86 |
| 4 | 368.60 |

Price Range 3 has the highest average votes, while Price Range 4 has fewer average votes despite having the highest average rating.

### 3. Ordinary vs. Vote-Weighted Ratings

The analysis compares two ways of calculating restaurant ratings:

- **Ordinary Average Rating:** Gives every rated restaurant equal weight.
- **Vote-Weighted Rating:** Gives greater weight to restaurants with more votes.

| Price Range | Ordinary Rating | Weighted Rating |
|---|---:|---:|
| 1 | 3.24 | 3.78 |
| 2 | 3.38 | 3.84 |
| 3 | 3.78 | 4.08 |
| 4 | 3.89 | 4.14 |

The weighted ratings are higher across all four price ranges. This indicates that restaurants receiving more votes have a stronger influence on the weighted average.

### 4. Online Delivery

| Online Delivery | Restaurants | Average Rating | Rating Coverage |
|---|---:|---:|---:|
| No | 7,100 | 3.47 | 71.10% |
| Yes | 2,451 | 3.38 | 96.08% |

Restaurants offering online delivery have slightly lower average ratings in this dataset, but substantially higher rating coverage.

These are associations, not evidence that online delivery causes a change in ratings.

### 5. Rating Coverage

A notable finding is that 2,102 of the 2,148 unrated restaurants belong to Price Ranges 1 and 2.

That represents approximately **97.86% of all unrated restaurants**.

This highlights an important limitation when comparing average ratings across price segments.

## Power BI Dashboard

The interactive dashboard includes:

- KPI cards for total restaurants, rated coverage, and average rating.
- Average restaurant rating by price range.
- Restaurant count by price range.
- Ordinary versus vote-weighted rating comparison.
- Weighted versus average rating gap.
- Average customer votes by price range.
- Rating coverage by price range.
- Average rating by online delivery.
- Top cities by average rating.

Interactive slicers allow users to explore the data by:

- Price Range
- City
- Online Delivery

## Repository Structure

```text
Zomato-Restaurant-Analytics/
│
├── sql/
│   ├── 01_data_quality_validation.sql
│   ├── 02_ratings_and_price_analysis.sql
│   ├── 03_customer_engagement.sql
│   └── 04_cuisine_city_and_services.sql
│
├── powerbi/
│   └── Zomato_Dashboard.pbix
│
├── docs/
│   └── dashboard_screenshot.png
│
└── README.md
```

## Business Takeaways

- Higher price ranges show higher average restaurant ratings in this dataset.
- Price Range 3 receives the highest average number of votes.
- Vote-weighted ratings are consistently higher than ordinary averages.
- Rating coverage is considerably lower in the two cheapest price ranges.
- Online delivery availability is associated with higher rating coverage, but not higher average ratings.
- Restaurant ratings should be interpreted alongside engagement and rating coverage.

## Limitations

- The dataset represents a particular snapshot and may not reflect current restaurant performance.
- Cuisine entries are combinations of cuisine labels rather than fully standardized categories.
- Votes are used as an engagement measure and should not automatically be interpreted as unique customers.
- Correlations and group comparisons do not establish causation.
- Unusual or questionable source values were not arbitrarily corrected.

## Conclusion

This project demonstrates an end-to-end analytics workflow, from data validation and SQL-based exploration to DAX calculations and interactive Power BI reporting.

It highlights how combining multiple metrics—ratings, votes, price ranges, and service availability—can provide a more complete understanding of restaurant performance.

---

**Author:** Nandesh
**Project:** Zomato Restaurant Analytics
**Tools:** MySQL | Power BI | DAX
