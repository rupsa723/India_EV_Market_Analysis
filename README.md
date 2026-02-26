# 🚗⚡ India EV Market Analysis — AtliQ Motors Expansion Strategy

> **Business Question:** Which Indian states and vehicle segments should AtliQ Motors prioritise to grow from <2% to meaningful market share — and what will it take to compete against Tata Motors and OLA Electric?

---

## 📌 The Business Problem

AtliQ Motors holds **25% market share in North America's EV segment** but less than **2% in India** — one of the fastest-growing EV markets in the world. The India leadership team needed a data-backed market entry strategy before committing capital to manufacturing, distribution, and brand partnerships.

**Key decisions this analysis had to inform:**
- Which states to enter first (by penetration, growth, and infrastructure readiness)
- Which vehicle segment (2-wheeler vs 4-wheeler) offers the better near-term ROI
- Who the real competitive threats are — and where the gaps are
- Where to locate a manufacturing facility
- What the realistic growth trajectory looks like by 2030

---

## 📊 Key Findings at a Glance

| Metric | Finding |
|---|---|
| India EV Market CAGR (2022–2024) | **93.91%** |
| Revenue Growth (2022–2024) | **+324.92%** → ₹209.63 billion |
| 2-Wheeler market share of total EV sales | **91.48%** |
| 4-Wheeler revenue CAGR | **367.79%** — faster revenue growth despite lower volume |
| Fastest growing manufacturer | **BYD India at 566.52% CAGR** |
| Projected India EV sales by 2030 | **~54 million units** |
| Top 2 states by penetration | **Karnataka (10.18%)** and **Maharashtra (8.60%)** |
| Seasonal peak | **March (Q4)** — driven by fiscal year-end purchases |

---

## 🔍 Analysis Approach
```
Raw CSVs (Vahan Sewa)
       │
       ▼
  SQL — Data exploration, aggregation, CAGR calculations,
        state-level ranking, manufacturer growth analysis
       │
       ▼
  Python (pandas, matplotlib, seaborn)
        — EDA, outlier handling, penetration rate modelling,
          2030 projection using compound growth
       │
       ▼
  Power BI — Interactive dashboard
           — Market Overview | State Performance |
             Manufacturer Rankings | Segment Comparison
```

---

## 📁 Repository Structure
```
India_EV_Market_Analysis/
│
├── datasets/
│   ├── electric_vehicle_sales_by_state.csv     # Monthly EV sales by state & category
│   ├── electric_vehicle_sales_by_makers.csv    # Manufacturer-level sales data
│   └── dim_date.csv                            # Date dimension (fiscal year, quarter)
│
├── ev_market_queries.sql                       # SQL queries — CAGR, rankings, penetration
├── ev_market_analysis.ipynb                    # Python EDA & projections notebook
├── EV_Insights Dashboard.pbix                  # Power BI dashboard (interactive)
├── EV_Insights Dashboard.pdf                   # Dashboard export (static preview)
├── India's EV Market Analysis.pptx             # Executive presentation deck
└── India's EV Market Analysis.pdf              # PDF version of the presentation
```

---

## 📈 Dashboard Preview

> 💡 **[Download the .pbix file](./EV_Insights%20Dashboard.pbix)** to explore the 
> interactive Power BI dashboard, or **[view the PDF export](./EV_Insights%20Dashboard.pdf)** 
> for a static preview.

*The dashboard covers four views:*
- **Market Overview** — Total sales, revenue, CAGR, 2030 projection
- **State Deep-Dive** — Penetration rate map, top/bottom 5 states, YoY growth
- **Manufacturer Rankings** — Sales volume, CAGR, market share by segment
- **Segment Comparison** — 2-wheeler vs 4-wheeler: volume, revenue, growth trajectory

---

## 🏆 Strategic Findings

### 1. The 2-Wheeler Segment is Volume; 4-Wheelers Are the Margin Play

2-wheelers dominate **91.5% of units sold**, but 4-wheelers are growing faster in 
**revenue terms (+367.79% CAGR)**. For a premium brand like AtliQ Motors entering 
from a position of strength, competing in 4-wheelers against Tata Motors is viable 
— without getting crushed on volume by OLA Electric in 2-wheelers.

### 2. Three States Account for Disproportionate Opportunity

**Karnataka, Maharashtra, and Kerala** lead on both absolute sales and penetration 
rate. Critically, they also have:
- Active state EV subsidy programmes
- Established charging infrastructure
- Urban consumer bases with demonstrated willingness to pay for premium EVs

**Goa and Meghalaya** show surprisingly high penetration rates relative to their 
size — signals of early-adopter markets that could be influenced before they 
consolidate around competitors.

### 3. BYD India is the Wildcard — Not Tata

Tata Motors is the **dominant incumbent** in 4-wheelers. But **BYD India's 566.52% 
CAGR** is the number that should concern AtliQ Motors' strategy team. BYD has global 
manufacturing efficiency, a proven product range, and is aggressively pricing into 
the Indian premium segment. AtliQ's differentiation cannot be price alone.

### 4. March Seasonality is a Launch Timing Signal

Peak EV sales occur in **Q4 (January–March)**, driven by year-end corporate fleet 
purchases and consumer deadline buying before subsidy cycles reset. Any product 
launch or marketing push should peak in February to capture the March spike.

---

## 📋 Recommendations

### Where to Enter First
**Primary markets:** Karnataka (Bengaluru focus) and Maharashtra (Mumbai/Pune corridor)
- Highest penetration, strongest infrastructure, premium consumer base
- Both states have dealer network density AtliQ can partner with immediately

**Secondary markets:** Kerala and Delhi
- Kerala: high green-consumer index, strong EV adoption trajectory
- Delhi: subsidy-driven but largest absolute urban market; strong fleet/B2B opportunity

### Which Segment to Lead With
**4-Wheeler segment, mid-to-premium tier (₹15–25L)**
- 4-wheelers growing faster in revenue than volume
- Tata dominates sub-₹15L — competing there is a price war AtliQ cannot win in Year 1
- The ₹15–25L gap between Tata's Nexon EV Max and BYD's Atto 3 is the whitespace 
  where AtliQ can position with credibility

### Manufacturing Location
**Gujarat (Ahmedabad–Vadodara corridor)**
- Highest ease-of-doing-business score among EV-relevant states
- PLI scheme eligibility for EV component localisation
- Proximity to Mundra port for import of components before full localisation
- Existing Tier-1 auto supplier ecosystem (Bosch, Motherson, Tata AutoComp)

### Go-to-Market Timing
Launch Q3 (October) → peak marketing in Q4 (January–March) → capture the March 
buying surge

---

## 🗂️ Data Sources

| Dataset | Source | Coverage |
|---|---|---|
| EV Sales by State | [Vahan Sewa — MoRTH](https://vahan.parivahan.gov.in/) | State × Month × Category |
| EV Sales by Maker | Vahan Sewa | Manufacturer × Month |
| Date Dimension | Derived | FY, Quarter, Month flags |

> All data covers **April 2021 – March 2024** (FY2022 to FY2024).

---

## 🛠️ Technical Stack

| Tool | Usage |
|---|---|
| **SQL** (MySQL) | CAGR calculations, penetration rate ranking, manufacturer growth queries, seasonal aggregation |
| **Python** (pandas, matplotlib, seaborn) | EDA, data cleaning, 2030 projection modelling, correlation analysis |
| **Power BI** | Interactive dashboard — 4 report pages, DAX measures, state map visual |
| **PowerPoint** | Executive presentation for leadership stakeholders |

---

## ⚡ How to Explore This Project

1. **Start with the SQL file** → see how CAGR and penetration rates were calculated 
   from raw data
2. **Open the Jupyter notebook** → follow the EDA and projection methodology  
3. **Download the .pbix file** → open in Power BI Desktop to interact with the dashboard
4. **Read the presentation PDF** → executive summary with all key recommendations

---

## 👩‍💻 About

**Rupsa Chaudhuri** — Data Analyst · M.Sc. Applied Mathematics  
Specialising in business intelligence, market analysis, and Power BI dashboards.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/rupsa-chaudhuri/)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-black?style=flat&logo=github)](https://github.com/rupsa723)

---

*Data sourced from Vahan Sewa (Ministry of Road Transport & Highways, Government of India).  
For portfolio and educational purposes.*
