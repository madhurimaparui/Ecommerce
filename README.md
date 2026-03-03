# 🛒 E-Commerce Sales Intelligence Platform

**Power BI | SQL Server | Excel | SharePoint | REST API | DAX | Git**

---

## 📌 Project Overview

A comprehensive sales intelligence platform built for an e-commerce business, analyzing 10,000+ transactions across products, customers, and sales channels. Connects four different data sources into a unified Power BI data model to deliver actionable insights on revenue, profitability, inventory, and customer behavior.

---

## 🗂️ Repository Structure

```
Ecommerce-Sales-PowerBI/
│
├── sql/
│   └── 01_ecommerce_db.sql          # Full schema + sample data
│
├── dax/
│   └── DAX_Measures.dax             # All DAX measures
│
├── powerquery/
│   └── MultiSource_Queries.m        # Power Query M scripts for all 4 data sources
│
├── powerbi/
│   └── Ecommerce_Dashboard.pbix     # Power BI report (add your .pbix here)
│
└── README.md
```

---

## 🔌 Data Sources

| Source | Tool | Data |
|--------|------|------|
| SQL Server | DirectQuery / Import | Orders, Customers, Products, Channels |
| Excel (.xlsx) | Power Query | Product master list, pricing |
| SharePoint List | Power Query | Inventory levels, reorder data |
| REST API | Power Query (Web.Contents) | Live exchange rates (USD/EUR/GBP) |

---

## 🗃️ Data Model

```
dim_customer ──┐
dim_product  ──┤── fact_sales ──── dim_channel
dim_date     ──┘
                        +
               stg_inventory   (SharePoint)
               stg_exchange_rates (REST API)
```

---

## 📊 Dashboard Pages & Visuals

### Page 1 — Executive Sales Overview
| Visual | Purpose |
|--------|---------|
| Card KPIs (5) | Total Revenue, Total Profit, Profit Margin %, Total Orders, Avg Order Value |
| Line Chart | Monthly revenue trend with YoY comparison |
| Clustered Bar Chart | Revenue by product category |
| Donut Chart | Sales channel split (Website / App / Marketplace / Social) |
| KPI Visual | Revenue MTD vs target |
| Slicer | Year, Quarter, Channel, Segment |

### Page 2 — Product Performance
| Visual | Purpose |
|--------|---------|
| Bar Chart | Top 10 products by revenue |
| Bar Chart | Top 10 products by profit margin |
| Scatter Plot | Revenue vs Profit Margin by product |
| Treemap | Revenue by category & sub-category |
| Table | Full product performance (revenue, cost, profit, units, returns) |
| Slicer | Category, Sub-category, Brand |

### Page 3 — Customer Intelligence
| Visual | Purpose |
|--------|---------|
| Donut Chart | Customer segment split (Consumer / Corporate / Home Office) |
| Map Visual | Revenue by customer state |
| Bar Chart | Top 10 customers by revenue |
| Line Chart | New customer acquisition by month |
| Card KPI | Total Customers, Avg Order Value, Repeat Rate %, Revenue per Customer |
| Slicer | Segment, State, Registration Year |

### Page 4 — Sales Channel Analysis
| Visual | Purpose |
|--------|---------|
| Clustered Column Chart | Revenue by channel per quarter |
| Donut Chart | Channel revenue share % |
| Line Chart | Channel trend over time |
| Matrix | Channel vs Category revenue breakdown |
| Card KPI | Top channel, Channel with highest margin |
| Slicer | Channel, Year, Quarter |

### Page 5 — Inventory & Stock
| Visual | Purpose |
|--------|---------|
| Bar Chart | Stock qty vs reorder level by product |
| Table | Low stock products (stock < reorder level) |
| Card KPI | Total Stock, Low Stock Products, Inventory Health % |
| Gauge | Overall inventory health score |
| Slicer | Warehouse, Category |

### Page 6 — Profitability & Discounts
| Visual | Purpose |
|--------|---------|
| Scatter Plot | Discount % vs Profit Margin by product |
| Bar Chart | Revenue by discount bucket (0%, 5%, 10%, 15%+) |
| Line Chart | Monthly profit trend |
| Card KPI | Avg Discount %, Return Rate %, Best Margin Category |
| Slicer | Category, Channel, Year |

---

## 🚀 How to Set Up

1. Run `sql/01_ecommerce_db.sql` on SQL Server
2. Open Power BI Desktop → Get Data → SQL Server → connect to EcommerceDB
3. Use `powerquery/MultiSource_Queries.m` to set up Excel, SharePoint, and REST API connections
4. Copy DAX measures from `dax/DAX_Measures.dax` into Power BI Desktop
5. Build relationships in the data model as shown above
6. Publish to Power BI Service and schedule refresh

---

## 🛠️ Power Query Setup Notes

- **Excel**: Update file path in `MultiSource_Queries.m` to your local Excel file location
- **SharePoint**: Replace SharePoint URL with your company SharePoint site
- **REST API**: Exchange rate API is free — replace with your preferred provider
- **SQL Server**: Update server name and database name in the SQL connection

---

## 👩‍💻 Author

**Madhurima Parui** — Power BI Developer | Data Analyst
📧 madhuriaparui@gmail.com | 🔗 [LinkedIn](https://linkedin.com/in/madhurima-parui-586b50189)
