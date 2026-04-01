# E-Commerce-Data-WareHouse Project

Welcome to the  **E-Commerce Data Warehouse Project** repository! 
This project demonstrates a comprehesive data warehousing and analytics solution, from building a datawarehouse to generating actionable insights. Designed as a portofolio project which
highlights industry best practices and data engineering and analytics.

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective 
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from three source systems (ENT,ORD,REF) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective 
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behaviour **
- **Product Performance**
- **Sales Trend**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## 🏗️ Architecture

This project follows a layered data warehouse architecture:

- **Bronze Layer** → Raw data ingestion from CSV files  
- **Silver Layer** → Data cleaning, validation, and transformation  
- **Gold Layer** → Analytical models (fact and dimension tables)  

> See visuals:
- `docs/DataArchitecture.png`  
- `docs/DataFlow.png`  

---

## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/ # Raw datasets (ENT, ORD, REF)
│
├── docs/ # Architecture & data flow diagrams
│ ├── DataArchitecture.png
│ └── DataFlow.png
│
├── scripts/ # SQL ETL pipeline
│ ├── bronze/ # Raw ingestion
│ ├── silver/ # Cleaning & transformation
│ └── gold/ # Analytical models
│
├── tests/ # Data validation & quality checks
│
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt
```
---

## License 

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## About Me

Hello there! Im **Erris Binxhija**, a Full Stack Developer who is interesed on shifting towards Data Engineering. I'll be creating data solutions projects while not forgetting web applications. Stay around to keep
looking at these amazing projects we will be making!



   
