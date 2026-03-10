
USE atliq_ev;

-- ============================================================
-- Q1: Top 3 and Bottom 3 makers for FY2023 and FY2024
--     in terms of 2-Wheeler EV units sold
-- ============================================================
-- STEP 1: Aggregate total 2W sales per maker per fiscal year 
 WITH maker_sales AS(
	SELECT fiscal_year,maker,SUM(electric_vehicles_sold) AS total_sold
	FROM electric_vehicle_sales_by_makers
	JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_makers.date
	WHERE vehicle_category='2-Wheelers' AND fiscal_year IN (2023,2024) AND electric_vehicles_sold >0 -- exclude makers with zero sales
	GROUP BY 1,2 ),

/* OLA Electric is #1 in both years and more than doubled — from 1.5L to 3.2L units. That's the dominant player you cannot fight head-on.
The top 3 completely reshuffled between FY2023 and FY2024. OKINAWA and HERO ELECTRIC fell out of top 3 entirely. TVS and ATHER came from nowhere. That tells you the 2W market is still unsettled — no loyalty yet.
BATTRE ELECTRIC at 4,841 units in FY2024 is the weakest performer. That's context for why a new entrant in 2W would struggle — the bottom makers are barely surviving.*/


-- STEP 2: Rank each maker within its fiscal year (best to worst)
ranked AS(
		SELECT  fiscal_year,maker,total_sold,
        RANK() OVER (PARTITION BY  fiscal_year ORDER BY total_sold DESC) AS rank_top,
        RANK() OVER (PARTITION BY fiscal_year ORDER BY total_sold ASC) AS rank_bottom
        FROM maker_sales)
-- STEP 3: Pull top 3 and bottom 3 for each year
SELECT 
	fiscal_year,
    CASE 
		WHEN rank_top<= 3 THEN CONCAT('top ',rank_top)
		WHEN rank_bottom<=3 THEN CONCAT('bottom ',rank_bottom)
	END AS Position,
    maker,
    total_sold
    FROM ranked
    WHERE rank_top<=3 OR rank_bottom<=3
    ORDER BY fiscal_year,rank_top,rank_bottom;
    
    
-- ============================================================
-- Q2: Top 5 states by penetration rate in FY2024
--     separately for 2-Wheelers and 4-Wheelers
-- Penetration Rate = (EV Sold / Total Vehicles Sold) * 100
-- ============================================================
WITH state_penetration AS(
SELECT state,vehicle_category,
		SUM(electric_vehicles_sold) AS ev_sold,
        SUM(total_vehicles_sold) AS total_sold,
		ROUND(SUM(electric_vehicles_sold)/SUM(total_vehicles_sold)*100,2) AS Penetration_rate
FROM electric_vehicle_sales_by_state
JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_state.date
WHERE fiscal_year= 2024
GROUP BY 1,2),

ranked AS(
SELECT state,vehicle_category,ev_sold,total_sold,penetration_rate,
		RANK() OVER( PARTITION BY vehicle_category ORDER BY penetration_rate DESC) AS rnk
FROM state_penetration)

SELECT vehicle_category,rnk,state,ev_sold,total_sold,penetration_rate 
FROM ranked
WHERE rnk<=5
ORDER BY vehicle_category,rnk;
/* Goa, Kerala, and Karnataka are the only three states that lead EV adoption in both 2-wheelers and 4-wheelers simultaneously. That's not a coincidence — all three have active state EV policies,
 relatively high per-capita income, and urban-heavy vehicle ownership patterns. These are your highest-readiness markets for a new entrant.*/
 
 -- ============================================================
-- Q3: States with negative penetration change FY2022 → FY2024
-- i.e. their EV adoption rate DECLINED over 3 years
-- ============================================================
WITH yearly_penetration AS(
SELECT  
	CASE 
		WHEN state = 'Andaman & Nicobar' 
		THEN 'Andaman & Nicobar Island' 
		ELSE state 
	END AS state,
		vehicle_category,fiscal_year,
		SUM(electric_vehicles_sold) AS ev_sold,
        SUM(total_vehicles_sold) AS total_sold,
		ROUND(SUM(electric_vehicles_sold)/SUM(total_vehicles_sold)*100,2) AS Penetration_rate
FROM electric_vehicle_sales_by_state
JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_state.date
WHERE fiscal_year IN (2022,2024)
GROUP BY 1,2,3),
pivoted AS(
SELECT state,vehicle_category,
		MAX(CASE WHEN fiscal_year=2022 THEN penetration_rate END) AS pen_2022,
        MAX(CASE WHEN fiscal_year=2024 THEN penetration_rate END) AS pen_2024
FROM yearly_penetration
GROUP BY 1,2)

SELECT state,vehicle_category,pen_2022,pen_2024,
		ROUND(pen_2024-pen_2022,2) AS change_in_penetration
FROM pivoted
WHERE pen_2024< pen_2022
GROUP BY 1,2;

/* This is actually a strong positive signal — out of 35 states and 2 categories (70 combinations), only 2 showed declining penetration. The EV adoption story in India is overwhelmingly positive across the country.
The two exceptions are both small UTs — Andaman & Nicobar and Ladakh — which have tiny vehicle markets, geographic constraints, and almost no charging infrastructure. Their decline is infrastructure-driven, not demand-driven.*/

-- ============================================================
-- Q4: Quarterly sales trend for top 5 4-Wheeler makers
--     FY2022 to FY2024
-- Top 5 determined by total units sold across all 3 years
-- ============================================================
WITH top5_maker AS(
SELECT maker , SUM(electric_vehicles_sold) AS ev_sold
FROM electric_vehicle_sales_by_makers 
WHERE vehicle_category='4-Wheelers'
GROUP BY maker
ORDER BY ev_sold DESC
LIMIT 5),

quarterly_sales AS(
SELECT maker, fiscal_year, quarter, SUM(electric_vehicles_sold) as ev_sold
FROM electric_vehicle_sales_by_makers
JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_makers.date
WHERE vehicle_category='4-Wheelers' AND maker IN (SELECT maker FROM top5_maker)
GROUP BY maker,fiscal_year,quarter
ORDER BY 1 ,2,3)

SELECT maker,fiscal_year,quarter,ev_sold
FROM quarterly_sales
ORDER BY maker DESC,fiscal_year,quarter;
/* Tata Motors shows consistent growth every single quarter without exception — from 1,031 units in Q1 FY2022 to 17,361 in Q4 FY2024. That's a 17x growth in 3 years. No dips, no volatility. The dominant and most stable player.
Mahindra had a massive Q1 FY2024 spike (10,911 units) — nearly double any other quarter — then dropped sharply. This was the XUV400 launch effect. Worth flagging as a launch-driven spike, not sustained growth.
BYD India started from near zero (1 unit in Q3 FY2022) and reached 400+ per quarter. Tiny absolute numbers but the growth trajectory is steep — this is the early warning signal for a serious competitor in 2-3 years.
MG Motor is the quiet grower — steady every quarter, no dramatic spikes, consistently compounding.*/

-- ============================================================
-- Q5: Delhi vs Karnataka — EV sales and penetration FY2024
-- ============================================================

SELECT
    s.state,
    s.vehicle_category,
    SUM(s.electric_vehicles_sold) AS ev_sold,
    SUM(s.total_vehicles_sold) AS total_sold,
    ROUND(SUM(s.electric_vehicles_sold) /
          SUM(s.total_vehicles_sold) * 100, 2) AS penetration_rate
FROM electric_vehicle_sales_by_state s
JOIN dim_date d ON s.date = d.date
WHERE d.fiscal_year = 2024
  AND s.state IN ('Delhi', 'Karnataka')
GROUP BY s.state, s.vehicle_category
ORDER BY s.state, s.vehicle_category;

/*This comparison is closer than most people expect. Karnataka beats Delhi on 2-wheeler penetration (11.57% vs 9.40%) and also on absolute 4-wheeler EV volume (12,878 vs 8,630 units). 
Delhi is the larger city but Karnataka has stronger EV adoption proportionally.
The near-identical 4-wheeler penetration rates — Karnataka 4.26% vs Delhi 4.29% — tells you both markets are equally ready for a 4-wheeler entrant. But Karnataka's larger total
 vehicle market makes it the higher absolute opportunity.
 
 The reason this comparison exists in the questionnaire is actually about policy effectiveness, not market size. Delhi and Karnataka are the two states that have been most aggressive with EV policy:

Delhi has the Delhi EV Policy 2020 — one of the most comprehensive in India, with direct purchase subsidies up to ₹30,000 for 2W, road tax waiver, registration fee waiver, and a target of 25% EV share by 2024.
Karnataka has the Karnataka EV Policy 2021 with similar incentives plus a focus on manufacturing.

Despite Delhi's superior subsidy structure, Karnataka leads on 2-wheeler penetration — suggesting demand-led adoption is more sustainable than incentive-led adoption.*/

-- ============================================================
-- Q6: CAGR in 4-Wheeler units for top 5 makers
--     FY2022 to FY2024 (n = 2 years)
-- Formula: (FY2024 / FY2022) ^ (1/2) - 1
-- ============================================================
WITH top5_maker AS(
SELECT maker , SUM(electric_vehicles_sold) AS ev_sold
FROM electric_vehicle_sales_by_makers 
WHERE vehicle_category='4-Wheelers'
GROUP BY maker
ORDER BY ev_sold DESC
LIMIT 5),

yearly_sales AS(
SELECT maker, fiscal_year, SUM(electric_vehicles_sold) as ev_sold
FROM electric_vehicle_sales_by_makers
JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_makers.date
WHERE vehicle_category='4-Wheelers' AND maker IN (SELECT maker FROM top5_maker)
GROUP BY maker,fiscal_year
ORDER BY 1 ,2),

fy_pivot AS(
SELECT maker,
		MAX(CASE WHEN fiscal_year=2022 THEN ev_sold END) AS fy_2022,
        MAX(CASE WHEN fiscal_year=2024 THEN ev_sold END) AS fy_2024
FROM yearly_sales
GROUP BY maker)

SELECT maker, fy_2022,fy_2024,
		ROUND((POWER(fy_2024 / fy_2022, 1.0/2) - 1) * 100, 2) AS cagr_pct
FROM fy_pivot
ORDER BY cagr_pct DESC;

/* BYD's 566% CAGR looks explosive but needs context. They started from just 33 units in FY2022. Growing from 33 to 1,466 is mathematically a huge 
CAGR but it's not the same as Tata growing from 12,708 to 48,181. When you present this, always show both the CAGR and the absolute numbers side by side — otherwise it's misleading.
The honest presentation of this data is: Tata Motors is the volume king — 48,181 units in FY2024. BYD India is the fastest grower percentage-wise
 but still a fraction of Tata's scale. Watch BYD in 3-5 years, not today.*/
 
 -- ============================================================
-- Q7: Top 10 states by CAGR in TOTAL vehicles sold
--     FY2022 to FY2024 (both 2W + 4W combined)
-- Note: This is total vehicle market growth, not just EVs
-- ============================================================
WITH yearly_sales AS(
SELECT
        CASE
            WHEN s.state = 'Andaman & Nicobar'
            THEN 'Andaman & Nicobar Island'
            ELSE s.state
        END AS state,
        d.fiscal_year,
        SUM(s.total_vehicles_sold) AS total_sold
    FROM electric_vehicle_sales_by_state s
    JOIN dim_date d ON s.date = d.date
    WHERE d.fiscal_year IN (2022, 2024)
    GROUP BY 1, 2),
fy_pivot AS(
SELECT state,
		MAX(CASE WHEN fiscal_year=2022 THEN total_sold END)  AS fy_2022,
       MAX( CASE WHEN fiscal_year=2024 THEN total_sold END) AS fy_2024
FROM yearly_sales
GROUP BY state)

SELECT state, fy_2022,fy_2024,
		ROUND((POWER(fy_2024 / fy_2022, 1.0/2) - 1) * 100, 2) AS cagr_pct
FROM fy_pivot
ORDER BY cagr_pct DESC
LIMIT 10;
/*These are states where the overall vehicle market is growing fastest — meaning more potential buyers entering the market.
Notice that Meghalaya and Goa lead on CAGR despite being small markets. That's the small-base effect.
Karnataka and Delhi are far more meaningful because they combine high CAGR with large absolute market size.
"Karnataka and Delhi are the only states combining both high total market growth (22-25% CAGR) AND high EV penetration — making them the most attractive entry markets."*/

-- ============================================================
-- Q8: Peak and low season months for EV sales
--     Based on total EV sales aggregated by month
--     across all fiscal years (2022, 2023, 2024)
-- ============================================================

SELECT
    MONTH(STR_TO_DATE(s.date, '%d-%b-%y'))            AS month_num,
    MONTHNAME(STR_TO_DATE(s.date, '%d-%b-%y'))        AS month_name,
    SUM(s.electric_vehicles_sold)                      AS total_ev_sold
FROM electric_vehicle_sales_by_state s
GROUP BY month_num, month_name
ORDER BY total_ev_sold DESC;
/* March is the undisputed peak at 2,91,587 units — nearly 40% more than the second highest month. 
This is India's fiscal year-end effect: corporate fleet purchases, subsidy deadlines, and dealer year-end targets all converge in March.
The real low season is June at 1,06,709 — the monsoon onset month. June is 63% lower than March. This is your "avoid launching in May-June" signal.
October-November-December form a secondary peak — the festive season (Navratri, Dussehra, Diwali, year-end). 
Consumers buy vehicles during festivals and dealers push inventory hard.
The pattern for a new market entrant is clear: Launch inventory build in July-August (monsoon low, less competition for attention),
dealer training in September, full marketing push in October for festive season, then peak campaign in February to capture the March surge. */

-- ============================================================
-- Q9: Projected EV sales in 2030 for top 10 states
--     by FY2024 penetration rate
-- Step 1: Find top 10 states by penetration in FY2024
-- Step 2: Calculate EV CAGR FY2022→FY2024 (n=2)
-- Step 3: Project FY2024 sales forward 6 years to FY2030
-- ============================================================
WITH fy24_penetration AS(
SELECT 
		CASE
            WHEN state = 'Andaman & Nicobar'
            THEN 'Andaman & Nicobar Island'
            ELSE state
        END AS state,
        ROUND(SUM(electric_vehicles_sold)/SUM(total_vehicles_sold)*100,2) as pen_2024
FROM electric_vehicle_sales_by_state
JOIN dim_date ON dim_date.date=electric_vehicle_sales_by_state.date
WHERE fiscal_year= 2024
GROUP BY state
ORDER BY pen_2024 DESC
LIMIT 10),
yearly_ev  AS(
 SELECT 
		CASE
            WHEN state = 'Andaman & Nicobar'
            THEN 'Andaman & Nicobar Island'
            ELSE state
        END AS state, fiscal_year,
        SUM(electric_vehicles_sold) AS ev_sold
FROM electric_vehicle_sales_by_state
JOIN dim_date ON dim_date.date= electric_vehicle_sales_by_state.date
WHERE fiscal_year IN (2022,2024)  AND state IN( SELECT state FROM fy24_penetration)
GROUP BY state, fiscal_year
ORDER BY state,fiscal_year),
fy_pivot AS(
SELECT
        state,
        MAX(CASE WHEN fiscal_year = 2022 THEN ev_sold END) AS ev_2022,
        MAX(CASE WHEN fiscal_year = 2024 THEN ev_sold END) AS ev_2024
    FROM yearly_ev
    GROUP BY state)
SELECT state,ev_2022,ev_2024,
		ROUND((POWER(ev_2024 / ev_2022, 1.0/2) - 1) * 100, 2)   AS cagr_pct,
		ROUND(ev_2024 * POWER(POWER(ev_2024 / ev_2022, 1.0/2), 6)) AS ev_2030_projected
FROM fy_pivot
ORDER BY ev_2030_projected DESC;
/* These projections assume the FY2022-FY2024 CAGR continues unchanged for 6 more years. 
That is mathematically convenient but practically unrealistic — growth always slows as markets mature.
 Chhattisgarh at 150% CAGR projecting to 71 lakh EVs by 2030 is almost certainly an overestimate. 
 Always present these numbers with the note: "Assumes constant historical CAGR — actual numbers will likely be lower as market matures."*/
 
-- ============================================================
-- Q10: Estimated revenue growth for 2W and 4W EVs
--      FY2022 vs FY2024 and FY2023 vs FY2024
-- Assumed prices: 2W = ₹85,000 | 4W = ₹15,00,000
-- ============================================================
WITH revenue_by_year AS (
SELECT
        d.fiscal_year,
        m.vehicle_category,
        SUM(m.electric_vehicles_sold) AS units_sold,
        SUM(m.electric_vehicles_sold *
            CASE
                WHEN m.vehicle_category = '2-Wheelers' THEN 85000
                WHEN m.vehicle_category = '4-Wheelers' THEN 1500000
            END)                                         AS total_revenue
    FROM electric_vehicle_sales_by_makers m
    JOIN dim_date d ON m.date = d.date
    GROUP BY d.fiscal_year, m.vehicle_category),
pivoted AS (
SELECT
        vehicle_category,
        MAX(CASE WHEN fiscal_year = 2022 THEN total_revenue END) AS rev_2022,
        MAX(CASE WHEN fiscal_year = 2023 THEN total_revenue END) AS rev_2023,
        MAX(CASE WHEN fiscal_year = 2024 THEN total_revenue END) AS rev_2024
    FROM revenue_by_year
    GROUP BY vehicle_category)
SELECT
    vehicle_category,
    ROUND(rev_2022 / 1e7, 2)                              AS revenue_fy2022_cr,
    ROUND(rev_2023 / 1e7, 2)                              AS revenue_fy2023_cr,
    ROUND(rev_2024 / 1e7, 2)                              AS revenue_fy2024_cr,
    ROUND((rev_2023 - rev_2022) / rev_2022 * 100, 2)     AS growth_2022_vs_2023,
    ROUND((rev_2024 - rev_2023) / rev_2023 * 100, 2)     AS growth_2023_vs_2024,
    ROUND((rev_2024 - rev_2022) / rev_2022 * 100, 2)     AS growth_2022_vs_2024    
FROM pivoted
ORDER BY vehicle_category;

/*4-wheelers grew revenue by 367.79% from FY2022 to FY2024 — nearly 100 percentage points faster than 2-wheelers (269.28%). 
Even though 2-wheelers dominate in units sold, 4-wheelers are winning on revenue growth. This is your strongest argument for
 why a new entrant should focus on the 4-wheeler segment.
Also note the growth is slowing: 2W grew only 28% from FY2023 to FY2024, while 4W grew 83%. This tells you 2W market is maturing faster while 4W still has strong momentum.
2-wheelers actually grew faster than 4-wheelers from FY2022 to FY2023 — 188% vs 155%. But then 4-wheelers overtook dramatically in FY2023 to FY2024 — 83% vs 28%. 
The 4-wheeler market had a delayed but much stronger second wave. This makes the complete 3-year revenue story much richer than just showing two endpoints.*/
 
 




















