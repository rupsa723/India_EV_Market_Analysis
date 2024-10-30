Use electric_vehicle_data;

# Question 1:List the top 3 and bottom 3 makers for the fiscal years 2023 and 2024 in terms of the number of 2-wheelers sold.
(    SELECT 
        2023 AS fiscal_year,
        'Top 3' AS category,
        maker, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold 
    FROM 
        merged_maker_data
    WHERE 
        fiscal_year = 2023 
        AND vehicle_category = '2-Wheelers'
    GROUP BY maker
    ORDER BY electric_vehicles_sold DESC
    LIMIT 3
)
UNION ALL
(
    SELECT 
        2023 AS fiscal_year,
        'Bottom 3' AS category,
        maker, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold 
    FROM 
        merged_maker_data
    WHERE 
        fiscal_year = 2023 
        AND vehicle_category = '2-Wheelers'
    GROUP BY maker
    ORDER BY electric_vehicles_sold 
    LIMIT 3
)
UNION ALL
(
    SELECT 
        2024 AS fiscal_year,
        'Top 3' AS category,
        maker, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold 
    FROM 
        merged_maker_data
    WHERE 
        fiscal_year = 2024 
        AND vehicle_category = '2-Wheelers'
    GROUP BY maker
    ORDER BY electric_vehicles_sold DESC
    LIMIT 3
)
UNION ALL
(
    SELECT 
        2024 AS fiscal_year,
        'Bottom 3' AS category,
        maker, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold 
    FROM 
        merged_maker_data
    WHERE 
        fiscal_year = 2024 
        AND vehicle_category = '2-Wheelers'
    GROUP BY maker
    ORDER BY electric_vehicles_sold 
    LIMIT 3
)
ORDER BY fiscal_year, category DESC, electric_vehicles_sold DESC;


#Question 2: Top 5 States with the Highest Penetration Rate in 2-Wheeler and 4-Wheeler EV Sales in FY 2024
(    SELECT 
        '2-Wheelers' AS vehicle_category,
        state, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold,
        SUM(electric_vehicles_sold) / SUM(total_vehicles_sold) AS penetration_rate
    FROM 
        merged_state_data
    WHERE 
        fiscal_year = 2024  
        AND vehicle_category = '2-Wheelers'
    GROUP BY 
        state
    ORDER BY 
        penetration_rate DESC
    LIMIT 5
)
UNION ALL
(    SELECT 
        '4-Wheelers' AS vehicle_category,
        state, 
        SUM(electric_vehicles_sold) AS electric_vehicles_sold,
        SUM(electric_vehicles_sold) / SUM(total_vehicles_sold) AS penetration_rate
    FROM 
        merged_state_data
    WHERE 
        fiscal_year = 2024  
        AND vehicle_category = '4-Wheelers'
    GROUP BY 
        state
    ORDER BY 
        penetration_rate DESC
    LIMIT 5
)
ORDER BY 
    vehicle_category, penetration_rate DESC;

#Question 3: States with Negative Penetration (Decline) in EV Sales from 2022 to 2024
WITH state_sales AS (
    SELECT 
        state,
        SUM(CASE WHEN fiscal_year = 2022 THEN electric_vehicles_sold ELSE 0 END) AS electric_vehicles_sold_22,
        SUM(CASE WHEN fiscal_year = 2024 THEN electric_vehicles_sold ELSE 0 END) AS electric_vehicles_sold_24
    FROM 
        merged_state_data
    WHERE 
        fiscal_year IN (2022, 2024)
    GROUP BY 
        state
)
SELECT 
    state,
    electric_vehicles_sold_24 - electric_vehicles_sold_22 AS change_in_sales
FROM 
    state_sales
WHERE 
    electric_vehicles_sold_24 - electric_vehicles_sold_22 < 0
ORDER BY 
    change_in_sales;


#Question 4: What are the quarterly trends based on sales volume for the top 5 EV makers (4-wheelers) from 2022 to 2024?
with top_5_makers as(
select maker,sum(electric_vehicles_sold) as electric_vehicles_sold
from merged_maker_data
where vehicle_category='4-Wheelers'
group by 1
order by 2 Desc
limit 5)
select top_5_makers.maker, fiscal_year,quarter,sum(merged_maker_data.electric_vehicles_sold) as total_ev_sold
from top_5_makers
join merged_maker_data on top_5_makers.maker=merged_maker_data.maker
group by 1,2,3
order by 1,2,3;

#Question 5: How do the EV sales and penetration rates in Delhi compare to Karnataka for 2024?
select state,
sum(electric_vehicles_sold) as electric_vehicles_sold,
sum(electric_vehicles_sold)/sum(total_vehicles_sold) as penetration_rate
from merged_state_data
where state in ('delhi','karnataka') and fiscal_year=2024
group by 1;

#Question 6: List down the compounded annual growth rate (CAGR) in 4-wheeler units for the top 5 makers from 2022 to 2024.
WITH sales_data AS (
    SELECT 
        maker,
        SUM(CASE WHEN fiscal_year = 2022 THEN electric_vehicles_sold ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN fiscal_year = 2024 THEN electric_vehicles_sold ELSE 0 END) AS sales_2024
    FROM 
        merged_maker_data
    WHERE 
        vehicle_category = '4-Wheelers'
        AND fiscal_year IN (2022, 2024)
    GROUP BY 
        maker
),
top_5_makers AS (
	SELECT 
		maker, SUM(electric_vehicles_sold) AS electric_vehicles_sold
	FROM
		merged_maker_data
	WHERE
		vehicle_category = '4-Wheelers'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5
)
SELECT 
    sd.maker,
    POWER((sd.sales_2024 / NULLIF(sd.sales_2022, 0)), 1.0 / 2) - 1 AS maker_CAGR
FROM 
    sales_data sd
JOIN 
    top_5_makers t5 ON sd.maker = t5.maker
ORDER BY 
    maker_CAGR DESC;

#Question 7: Top 10 States with the Highest CAGR from 2022 to 2024 in Total Vehicles Sold
WITH sales_data AS (
    SELECT 
        state,
        SUM(CASE WHEN fiscal_year = 2022 THEN total_vehicles_sold ELSE 0 END) AS total_sales_2022,
        SUM(CASE WHEN fiscal_year = 2024 THEN total_vehicles_sold ELSE 0 END) AS total_sales_2024,
        SUM(total_vehicles_sold) as Total_vehicle_sold
    FROM 
        merged_state_data
    GROUP BY 
        state
)
SELECT 
    state,
    Total_vehicle_sold,
    POWER(NULLIF(total_sales_2024, 0) / NULLIF(total_sales_2022, 0), 1.0 / 2) - 1 AS state_CAGR
FROM 
    sales_data
ORDER BY 
    state_CAGR DESC
LIMIT 10;


#Question 8: Peak and Low Season Months for EV Sales from 2022 to 2024
WITH monthly_sales AS (
    SELECT 
        YEAR(date) AS year,
        MONTH(date) AS month,
        SUM(electric_vehicles_sold) AS total_ev_sales
    FROM merged_state_data
    GROUP BY year, month
),
average_monthly_sales AS (
    SELECT 
        month,
        AVG(total_ev_sales) AS avg_sales
    FROM monthly_sales
    GROUP BY month
),
ranked_sales AS (
    SELECT 
        month,
        avg_sales,
        RANK() OVER (ORDER BY avg_sales DESC) AS sales_rank_desc,
        RANK() OVER (ORDER BY avg_sales ASC) AS sales_rank_asc
    FROM average_monthly_sales
)
SELECT 
    month, 
    avg_sales
FROM ranked_sales
WHERE sales_rank_desc = 1 OR sales_rank_asc = 1;

# Question 9: Projected Number of EV Sales for Top 10 States by Penetration Rate in 2030
with top_10_penetration_rate as ( 
SELECT 
    state,
    SUM(electric_vehicles_sold) AS total_ev_sold_2024,
    SUM(total_vehicles_sold) AS total_v_sold_2024,
    SUM(electric_vehicles_sold) / SUM(total_vehicles_sold) AS penetration_rate
FROM
    merged_state_data
WHERE
    fiscal_year = 2024
GROUP BY state
ORDER BY penetration_rate DESC
LIMIT 10),

sales_2022 as(
SELECT 
    merged_state_data.state,
    SUM(electric_vehicles_sold) AS total_ev_sold_2022
FROM
    merged_state_data
        JOIN
    top_10_penetration_rate ON top_10_penetration_rate.state = merged_state_data.state
WHERE
    fiscal_year = 2022
GROUP BY state),
CAGR_22_24 as (
SELECT 
    t.state,
    t.penetration_rate,
    total_ev_sold_2022,
    total_ev_sold_2024,
    POWER(NULLIF(total_ev_sold_2024 / total_ev_sold_2022,0),1 / 2) - 1 AS state_CAGR
FROM
    sales_2022
        JOIN
    top_10_penetration_rate t ON sales_2022.state = t.state
ORDER BY t.penetration_rate DESC)

SELECT 
    state,
    state_CAGR,
    total_ev_sold_2024 * POWER(1 + state_CAGR, 6) AS projected_sales_2030,
    penetration_rate
FROM
    CAGR_22_24
ORDER BY penetration_rate DESC;

#Question 10: Estimate Revenue Growth Rate of EVs in India for 2022 vs 2024 and 2023 vs 2024
WITH vehicle_sold AS (
    SELECT 
        fiscal_year,
        vehicle_category,
        SUM(electric_vehicles_sold) AS total_ev_sold
    FROM merged_state_data
    GROUP BY fiscal_year, vehicle_category
),
total_revenue AS (
    SELECT 
        fiscal_year, 
        SUM(CASE WHEN vehicle_category = '2-Wheelers' THEN total_ev_sold * 85000
                 WHEN vehicle_category = '4-Wheelers' THEN total_ev_sold * 1500000
            END) AS total_revenue
    FROM vehicle_sold
    GROUP BY fiscal_year
)
SELECT 
    (t2024.total_revenue - t2022.total_revenue) / t2022.total_revenue AS revenue_growth_2022_2024,
    (t2024.total_revenue - t2023.total_revenue) / t2023.total_revenue AS revenue_growth_2023_2024
FROM 
    (SELECT total_revenue FROM total_revenue WHERE fiscal_year = 2022) t2022,
    (SELECT total_revenue FROM total_revenue WHERE fiscal_year = 2023) t2023,
    (SELECT total_revenue FROM total_revenue WHERE fiscal_year = 2024) t2024;
    
    
    
    

    
    
