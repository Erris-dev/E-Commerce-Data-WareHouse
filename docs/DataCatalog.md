# 📘 Data Catalog: Gold Layer (Star Schema)

**Layer:** Gold (Semantic/Business Layer)  
**Format:** SQL Views  
**Update Frequency:** Real-time (Schema-on-Read from Silver)

---

## 👥 Dimension: `gold.dim_customers`
Describes unique customers and their primary geographic locations.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| **customer_key** | `INT` | **Surrogate Key:** Unique identifier generated for the Star Schema using `ROW_NUMBER()`. |
| **customer_id** | `VARCHAR` | The original ID from the source system (Natural Key). |
| **customer_unique_id** | `VARCHAR` | Unique identifier used to link multiple orders to a single customer entity. |
| **zip_code** | `VARCHAR` | The customer's primary postal code prefix. |
| **city** | `VARCHAR` | Standardized city name (Cleaned: TRIM and UPPER applied). |
| **state** | `VARCHAR` | Two-letter state abbreviation (e.g., SP, RJ, SC). |

---

## 📦 Dimension: `gold.dim_products`
Contains physical attributes and categorization for all products.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| **product_key** | `INT` | **Surrogate Key:** Unique identifier for product dimensions. |
| **product_id** | `VARCHAR` | Unique product identifier from the source catalog. |
| **category** | `VARCHAR` | Standardized product category name. |
| **weight_g** | `INT` | Product weight measured in grams. |
| **length_cm** | `INT` | Product package length in centimeters. |
| **height_cm** | `INT` | Product package height in centimeters. |
| **width_cm** | `INT` | Product package width in centimeters. |
| **photos_qty** | `INT` | Number of photos available in the product listing. |

---

## 🏪 Dimension: `gold.dim_sellers`
Details regarding the vendors and their geographic distribution.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| **seller_key** | `INT` | **Surrogate Key:** Unique identifier for sellers. |
| **seller_id** | `VARCHAR` | Unique seller identifier from the source system. |
| **zip_code** | `VARCHAR` | The seller's postal code prefix. |
| **city** | `VARCHAR` | Seller's city location (Cleaned and Standardized). |
| **state** | `VARCHAR` | Seller's state abbreviation. |

---

## 💰 Fact Table: `gold.fact_sales`
The central table containing quantitative metrics for every transaction item.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| **order_id** | `VARCHAR` | Unique identifier for the specific transaction. |
| **order_item_id** | `INT` | Sequence number identifying the item line within an order. |
| **product_key** | `INT` | Foreign Key linking to `gold.dim_products`. |
| **customer_key** | `INT` | Foreign Key linking to `gold.dim_customers`. |
| **seller_key** | `INT` | Foreign Key linking to `gold.dim_sellers`. |
| **order_date** | `DATETIME` | The timestamp when the order was placed. |
| **sales_amount** | `DECIMAL` | The unit price of the product sold. |
| **freight_amount**| `DECIMAL` | The shipping cost associated with the individual item. |
| **total_amount** | `DECIMAL` | **Calculated Metric:** `sales_amount` + `freight_amount`. |
| **delivery_days** | `INT` | **Calculated Metric:** Days between purchase and customer delivery. |

---

## ⭐ Fact Table: `gold.fact_reviews`
Captures customer sentiment and feedback metrics for quality analysis.

| Column | Data Type | Description |
| :--- | :--- | :--- |
| **review_id** | `VARCHAR` | Unique identifier for the review entry. |
| **order_id** | `VARCHAR` | Links the review to the corresponding transaction in `fact_sales`. |
| **review_score** | `INT` | Customer rating from 1 (lowest) to 5 (highest) stars. |
| **is_commented** | `BIT` | **Calculated Flag:** (1/0) indicating if the user provided a text review. |

---

### 💡 Usage Notes
- **Joins:** Always join the `fact_sales` table to the dimensions using the `_key` columns (Surrogate Keys) for optimal performance in BI tools.
- **Aggregations:** Use `total_amount` for revenue analysis and `delivery_days` for logistics performance monitoring.
