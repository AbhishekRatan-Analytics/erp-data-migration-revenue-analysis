## 📊 ERP Data Migration & Revenue Integrity Analysis

### 📌 Overview
This project simulates a real-world ERP migration from a legacy CRM system (HubSpot/Kaggle-style dataset) to Dynamics 365 Finance. The objective was to ensure data integrity, identify revenue leakage, and establish a clean financial baseline during system cutover.

---

## 🎯 Business Problem
Legacy CRM data lacked reliability due to:
- Inconsistent pricing records  
- Uncontrolled credit exposure  
- Data mismatches across systems  

This resulted in:
- Revenue leakage  
- Financial reporting delays  
- Risk of bad debt  

---

## 🧩 Project Breakdown

## 🔹 Phase 1: Data Migration & Data Quality (Project Alpha)

### Objective
Ensure accurate migration of CRM data to ERP.

### Key Tasks
- Performed data profiling and schema mapping between CRM and ERP systems  
- Developed SQL-based validation and “quarantine” logic to isolate inconsistent records  
- Identified and isolated 147 records with pricing/data inconsistencies  
- Resolved schema mismatch issues impacting migration  

### Outcome
- Successfully migrated 8,653 clean records  
- Achieved 98.3% data accuracy  
- Enabled 100% financial reconciliation between systems  

---

## 🔹 Phase 2: Credit Risk Control (Project Beta)

### Objective
Reduce financial risk from high-value transactions.

### Key Tasks
- Designed dynamic credit limit logic (5% of customer revenue)  
- Analyzed customer financial capacity vs sales exposure  
- Implemented automated order-blocking logic for high-risk transactions  

### Outcome
- Blocked 236 high-risk transactions  
- Prevented $339K potential bad debt  
- Strengthened Order-to-Cash (O2C) financial controls  

---

## 🔹 Phase 3: Revenue Leakage Analysis (Project Gamma)

### Objective
Identify and quantify revenue leakage in legacy operations.

### Key Tasks
- Performed financial variance analysis (Gross vs Realizable Revenue)  
- Analyzed pricing discrepancies and unauthorized discounting  
- Evaluated impact of credit risk on revenue realization  

### Outcome
- Identified 11.2% revenue leakage (~$1.1M)  
- Established clean revenue baseline of $8.88M  
- Enabled accurate financial reporting for ERP system  

## Dashboard Preview
<img width="1327" height="734" alt="image" src="https://github.com/user-attachments/assets/63e44050-b4f4-41bd-8910-4ad392e82077" />




---

## 📊 Key Insights
- Pricing leakage (~7.8%) was the primary contributor to revenue loss  
- Credit risk exposure (~3.4%) led to potential bad debt  
- Lack of validation and controls in legacy systems caused financial inconsistencies  

---

## 🛠️ Tech Stack
- SQL (Data validation, joins, aggregations, analysis)  
- Power BI (Dashboarding, KPI tracking, visualization)  
- Excel (Data preparation, preprocessing)  

---

## 📈 Deliverables
- Migration Integrity Dashboard (Power BI)  
- SQL scripts for validation and credit logic  
- Revenue leakage analysis report  

---

## 🚀 Business Impact
- Improved data reliability during ERP migration  
- Enabled audit-ready financial reconciliation  
- Reduced financial risk and manual data correction efforts  

