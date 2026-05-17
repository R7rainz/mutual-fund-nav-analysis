-- ============================================================
-- Mutual Fund Performance Analysis - SQL Queries
-- ============================================================

-- This file contains SQL queries that can be used to analyze
-- cleaned mutual fund NAV data.
--
-- Expected table name: nav_data
--
-- Expected columns:
-- fund_name        TEXT
-- date             DATE
-- nav              DECIMAL
-- daily_return     DECIMAL
-- drawdown         DECIMAL
--
-- Note:
-- The exact table/column names can be changed based on your CSV
-- or database schema.
-- ============================================================


-- ============================================================
-- 1. View Complete NAV Dataset
-- ============================================================

SELECT *
FROM nav_data
ORDER BY fund_name, date;


-- ============================================================
-- 2. Count Total Records
-- ============================================================

SELECT COUNT(*) AS total_records
FROM nav_data;


-- ============================================================
-- 3. Count Records for Each Mutual Fund
-- ============================================================

SELECT
    fund_name,
    COUNT(*) AS total_records
FROM nav_data
GROUP BY fund_name
ORDER BY total_records DESC;


-- ============================================================
-- 4. Find Date Range Available for Each Fund
-- ============================================================

SELECT
    fund_name,
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM nav_data
GROUP BY fund_name
ORDER BY fund_name;


-- ============================================================
-- 5. Get First and Last NAV for Each Fund
-- ============================================================

WITH ranked_nav AS (
    SELECT
        fund_name,
        date,
        nav,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date ASC
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date DESC
        ) AS last_rank
    FROM nav_data
)

SELECT
    fund_name,
    MAX(CASE WHEN first_rank = 1 THEN date END) AS start_date,
    MAX(CASE WHEN first_rank = 1 THEN nav END) AS first_nav,
    MAX(CASE WHEN last_rank = 1 THEN date END) AS end_date,
    MAX(CASE WHEN last_rank = 1 THEN nav END) AS last_nav
FROM ranked_nav
GROUP BY fund_name
ORDER BY fund_name;


-- ============================================================
-- 6. Calculate Total Return Percentage for Each Fund
-- ============================================================

WITH ranked_nav AS (
    SELECT
        fund_name,
        date,
        nav,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date ASC
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date DESC
        ) AS last_rank
    FROM nav_data
),

first_last_nav AS (
    SELECT
        fund_name,
        MAX(CASE WHEN first_rank = 1 THEN nav END) AS first_nav,
        MAX(CASE WHEN last_rank = 1 THEN nav END) AS last_nav
    FROM ranked_nav
    GROUP BY fund_name
)

SELECT
    fund_name,
    first_nav,
    last_nav,
    ROUND(((last_nav - first_nav) / first_nav) * 100, 2) AS total_return_percentage
FROM first_last_nav
ORDER BY total_return_percentage DESC;


-- ============================================================
-- 7. Calculate Average NAV for Each Fund
-- ============================================================

SELECT
    fund_name,
    ROUND(AVG(nav), 2) AS average_nav
FROM nav_data
GROUP BY fund_name
ORDER BY average_nav DESC;


-- ============================================================
-- 8. Find Highest NAV Reached by Each Fund
-- ============================================================

SELECT
    fund_name,
    MAX(nav) AS highest_nav
FROM nav_data
GROUP BY fund_name
ORDER BY highest_nav DESC;


-- ============================================================
-- 9. Find Lowest NAV Reached by Each Fund
-- ============================================================

SELECT
    fund_name,
    MIN(nav) AS lowest_nav
FROM nav_data
GROUP BY fund_name
ORDER BY lowest_nav ASC;


-- ============================================================
-- 10. Find Date on Which Each Fund Reached Its Highest NAV
-- ============================================================

WITH ranked_high AS (
    SELECT
        fund_name,
        date,
        nav,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY nav DESC
        ) AS rank_no
    FROM nav_data
)

SELECT
    fund_name,
    date AS highest_nav_date,
    nav AS highest_nav
FROM ranked_high
WHERE rank_no = 1
ORDER BY highest_nav DESC;


-- ============================================================
-- 11. Find Date on Which Each Fund Reached Its Lowest NAV
-- ============================================================

WITH ranked_low AS (
    SELECT
        fund_name,
        date,
        nav,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY nav ASC
        ) AS rank_no
    FROM nav_data
)

SELECT
    fund_name,
    date AS lowest_nav_date,
    nav AS lowest_nav
FROM ranked_low
WHERE rank_no = 1
ORDER BY lowest_nav ASC;


-- ============================================================
-- 12. Calculate Daily NAV Change
-- ============================================================

SELECT
    fund_name,
    date,
    nav,
    nav - LAG(nav) OVER (
        PARTITION BY fund_name
        ORDER BY date
    ) AS nav_change
FROM nav_data
ORDER BY fund_name, date;


-- ============================================================
-- 13. Calculate Daily Return Percentage
-- ============================================================

SELECT
    fund_name,
    date,
    nav,
    ROUND(
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) * 100,
        4
    ) AS daily_return_percentage
FROM nav_data
ORDER BY fund_name, date;


-- ============================================================
-- 14. Calculate Average Daily Return for Each Fund
-- ============================================================

WITH daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
)

SELECT
    fund_name,
    ROUND(AVG(daily_return) * 100, 4) AS average_daily_return_percentage
FROM daily_returns
WHERE daily_return IS NOT NULL
GROUP BY fund_name
ORDER BY average_daily_return_percentage DESC;


-- ============================================================
-- 15. Calculate Volatility for Each Fund
-- ============================================================

WITH daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
)

SELECT
    fund_name,
    ROUND(STDDEV(daily_return) * 100, 4) AS daily_volatility_percentage
FROM daily_returns
WHERE daily_return IS NOT NULL
GROUP BY fund_name
ORDER BY daily_volatility_percentage DESC;


-- ============================================================
-- 16. Calculate Annualized Volatility for Each Fund
-- ============================================================

WITH daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
)

SELECT
    fund_name,
    ROUND(STDDEV(daily_return) * SQRT(252) * 100, 2) AS annualized_volatility_percentage
FROM daily_returns
WHERE daily_return IS NOT NULL
GROUP BY fund_name
ORDER BY annualized_volatility_percentage DESC;


-- ============================================================
-- 17. Calculate Running Peak NAV
-- ============================================================

SELECT
    fund_name,
    date,
    nav,
    MAX(nav) OVER (
        PARTITION BY fund_name
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_peak_nav
FROM nav_data
ORDER BY fund_name, date;


-- ============================================================
-- 18. Calculate Drawdown for Each Date
-- ============================================================

WITH running_peak AS (
    SELECT
        fund_name,
        date,
        nav,
        MAX(nav) OVER (
            PARTITION BY fund_name
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_peak_nav
    FROM nav_data
)

SELECT
    fund_name,
    date,
    nav,
    running_peak_nav,
    ROUND(((nav - running_peak_nav) / running_peak_nav) * 100, 2) AS drawdown_percentage
FROM running_peak
ORDER BY fund_name, date;


-- ============================================================
-- 19. Calculate Maximum Drawdown for Each Fund
-- ============================================================

WITH running_peak AS (
    SELECT
        fund_name,
        date,
        nav,
        MAX(nav) OVER (
            PARTITION BY fund_name
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_peak_nav
    FROM nav_data
),

drawdown_data AS (
    SELECT
        fund_name,
        date,
        nav,
        ((nav - running_peak_nav) / running_peak_nav) * 100 AS drawdown_percentage
    FROM running_peak
)

SELECT
    fund_name,
    ROUND(MIN(drawdown_percentage), 2) AS maximum_drawdown_percentage
FROM drawdown_data
GROUP BY fund_name
ORDER BY maximum_drawdown_percentage ASC;


-- ============================================================
-- 20. Best Performing Fund by Total Return
-- ============================================================

WITH ranked_nav AS (
    SELECT
        fund_name,
        date,
        nav,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date ASC
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY fund_name
            ORDER BY date DESC
        ) AS last_rank
    FROM nav_data
),

first_last_nav AS (
    SELECT
        fund_name,
        MAX(CASE WHEN first_rank = 1 THEN nav END) AS first_nav,
        MAX(CASE WHEN last_rank = 1 THEN nav END) AS last_nav
    FROM ranked_nav
    GROUP BY fund_name
),

returns AS (
    SELECT
        fund_name,
        ROUND(((last_nav - first_nav) / first_nav) * 100, 2) AS total_return_percentage
    FROM first_last_nav
)

SELECT *
FROM returns
ORDER BY total_return_percentage DESC
LIMIT 1;


-- ============================================================
-- 21. Most Volatile Fund
-- ============================================================

WITH daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
),

volatility AS (
    SELECT
        fund_name,
        ROUND(STDDEV(daily_return) * SQRT(252) * 100, 2) AS annualized_volatility_percentage
    FROM daily_returns
    WHERE daily_return IS NOT NULL
    GROUP BY fund_name
)

SELECT *
FROM volatility
ORDER BY annualized_volatility_percentage DESC
LIMIT 1;


-- ============================================================
-- 22. Fund with Lowest Volatility
-- ============================================================

WITH daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
),

volatility AS (
    SELECT
        fund_name,
        ROUND(STDDEV(daily_return) * SQRT(252) * 100, 2) AS annualized_volatility_percentage
    FROM daily_returns
    WHERE daily_return IS NOT NULL
    GROUP BY fund_name
)

SELECT *
FROM volatility
ORDER BY annualized_volatility_percentage ASC
LIMIT 1;


-- ============================================================
-- 23. Fund with Largest Maximum Drawdown
-- ============================================================

WITH running_peak AS (
    SELECT
        fund_name,
        date,
        nav,
        MAX(nav) OVER (
            PARTITION BY fund_name
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_peak_nav
    FROM nav_data
),

drawdown_data AS (
    SELECT
        fund_name,
        date,
        nav,
        ((nav - running_peak_nav) / running_peak_nav) * 100 AS drawdown_percentage
    FROM running_peak
),

max_drawdown AS (
    SELECT
        fund_name,
        ROUND(MIN(drawdown_percentage), 2) AS maximum_drawdown_percentage
    FROM drawdown_data
    GROUP BY fund_name
)

SELECT *
FROM max_drawdown
ORDER BY maximum_drawdown_percentage ASC
LIMIT 1;


-- ============================================================
-- 24. Monthly Average NAV for Each Fund
-- ============================================================

SELECT
    fund_name,
    DATE_TRUNC('month', date) AS month,
    ROUND(AVG(nav), 2) AS average_monthly_nav
FROM nav_data
GROUP BY fund_name, DATE_TRUNC('month', date)
ORDER BY fund_name, month;


-- ============================================================
-- 25. Yearly Average NAV for Each Fund
-- ============================================================

SELECT
    fund_name,
    EXTRACT(YEAR FROM date) AS year,
    ROUND(AVG(nav), 2) AS average_yearly_nav
FROM nav_data
GROUP BY fund_name, EXTRACT(YEAR FROM date)
ORDER BY fund_name, year;


-- ============================================================
-- 26. Yearly Return for Each Fund
-- ============================================================

WITH yearly_nav AS (
    SELECT
        fund_name,
        EXTRACT(YEAR FROM date) AS year,
        MIN(date) AS start_date,
        MAX(date) AS end_date
    FROM nav_data
    GROUP BY fund_name, EXTRACT(YEAR FROM date)
),

yearly_values AS (
    SELECT
        y.fund_name,
        y.year,
        start_nav.nav AS start_nav,
        end_nav.nav AS end_nav
    FROM yearly_nav y
    JOIN nav_data start_nav
        ON y.fund_name = start_nav.fund_name
       AND y.start_date = start_nav.date
    JOIN nav_data end_nav
        ON y.fund_name = end_nav.fund_name
       AND y.end_date = end_nav.date
)

SELECT
    fund_name,
    year,
    start_nav,
    end_nav,
    ROUND(((end_nav - start_nav) / start_nav) * 100, 2) AS yearly_return_percentage
FROM yearly_values
ORDER BY fund_name, year;


-- ============================================================
-- 27. Monthly SIP Investment Simulation
-- ============================================================

-- Assumption:
-- SIP amount = Rs. 5000 per month
-- Investment is made on the first available NAV date of every month.

WITH monthly_nav AS (
    SELECT
        fund_name,
        DATE_TRUNC('month', date) AS month,
        MIN(date) AS investment_date
    FROM nav_data
    GROUP BY fund_name, DATE_TRUNC('month', date)
),

sip_dates AS (
    SELECT
        n.fund_name,
        n.date,
        n.nav
    FROM nav_data n
    JOIN monthly_nav m
        ON n.fund_name = m.fund_name
       AND n.date = m.investment_date
),

sip_units AS (
    SELECT
        fund_name,
        date,
        nav,
        5000 AS sip_amount,
        5000 / nav AS units_purchased
    FROM sip_dates
),

latest_nav AS (
    SELECT
        fund_name,
        nav AS latest_nav
    FROM (
        SELECT
            fund_name,
            nav,
            ROW_NUMBER() OVER (
                PARTITION BY fund_name
                ORDER BY date DESC
            ) AS rank_no
        FROM nav_data
    ) ranked
    WHERE rank_no = 1
)

SELECT
    s.fund_name,
    COUNT(*) AS total_installments,
    SUM(s.sip_amount) AS total_invested,
    ROUND(SUM(s.units_purchased), 4) AS total_units,
    ROUND(SUM(s.units_purchased) * l.latest_nav, 2) AS current_value,
    ROUND(
        (
            (SUM(s.units_purchased) * l.latest_nav - SUM(s.sip_amount))
            / SUM(s.sip_amount)
        ) * 100,
        2
    ) AS sip_return_percentage
FROM sip_units s
JOIN latest_nav l
    ON s.fund_name = l.fund_name
GROUP BY s.fund_name, l.latest_nav
ORDER BY sip_return_percentage DESC;


-- ============================================================
-- 28. Create Summary Metrics Table
-- ============================================================

CREATE TABLE fund_summary AS
WITH first_last AS (
    SELECT
        fund_name,
        MAX(CASE WHEN first_rank = 1 THEN nav END) AS first_nav,
        MAX(CASE WHEN last_rank = 1 THEN nav END) AS last_nav
    FROM (
        SELECT
            fund_name,
            date,
            nav,
            ROW_NUMBER() OVER (
                PARTITION BY fund_name
                ORDER BY date ASC
            ) AS first_rank,
            ROW_NUMBER() OVER (
                PARTITION BY fund_name
                ORDER BY date DESC
            ) AS last_rank
        FROM nav_data
    ) ranked
    GROUP BY fund_name
),

daily_returns AS (
    SELECT
        fund_name,
        date,
        nav,
        (
            (nav - LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            ))
            /
            LAG(nav) OVER (
                PARTITION BY fund_name
                ORDER BY date
            )
        ) AS daily_return
    FROM nav_data
),

volatility AS (
    SELECT
        fund_name,
        STDDEV(daily_return) * SQRT(252) * 100 AS annualized_volatility_percentage
    FROM daily_returns
    WHERE daily_return IS NOT NULL
    GROUP BY fund_name
),

running_peak AS (
    SELECT
        fund_name,
        date,
        nav,
        MAX(nav) OVER (
            PARTITION BY fund_name
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_peak_nav
    FROM nav_data
),

drawdown AS (
    SELECT
        fund_name,
        MIN(((nav - running_peak_nav) / running_peak_nav) * 100) AS maximum_drawdown_percentage
    FROM running_peak
    GROUP BY fund_name
)

SELECT
    f.fund_name,
    ROUND(((f.last_nav - f.first_nav) / f.first_nav) * 100, 2) AS total_return_percentage,
    ROUND(v.annualized_volatility_percentage, 2) AS annualized_volatility_percentage,
    ROUND(d.maximum_drawdown_percentage, 2) AS maximum_drawdown_percentage
FROM first_last f
JOIN volatility v
    ON f.fund_name = v.fund_name
JOIN drawdown d
    ON f.fund_name = d.fund_name
ORDER BY total_return_percentage DESC;


-- ============================================================
-- 29. View Summary Metrics Table
-- ============================================================

SELECT *
FROM fund_summary
ORDER BY total_return_percentage DESC;


-- ============================================================
-- 30. Drop Summary Table If Needed
-- ============================================================

DROP TABLE IF EXISTS fund_summary;
