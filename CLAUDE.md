# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Data visualization competition project analyzing customer visit data from The Loop clothing exchange program at George Washington University (Mount Vernon Campus). Data covers January 2025 - October 2025.

## Project Narrative

**Story & Goal:** This visualization explores the relationship between giving and taking at The Loop clothing exchange. The central insight is that while undergraduates dominate visitor volume, staff and faculty demonstrate higher donation rates proportionally. The dashboard reveals seasonal patterns in exchange activity and identifies which clothing categories drive the most engagement, helping program coordinators understand community participation and optimize inventory planning.

**Design Choice:** A four-panel dashboard was chosen to present complementary perspectives on the same dataset. Line charts effectively show temporal trends in items taken versus donations. Horizontal bar charts allow easy comparison of item categories and demographic groups. A donut chart visualizes the proportion of visitors who donate, providing an at-a-glance summary of giving behavior.

**Design Process:** The design began by identifying three key questions: How does exchange activity vary over time? What items are most popular? Who donates? Each question mapped naturally to a visualization type. Panels were arranged in a 2×2 grid using patchwork, with temporal data at top-left (the natural starting point for reading), item totals at top-right, and donation analysis across the bottom row to tell a cohesive story from activity patterns to community impact.

## Commands

```bash
# Run all visualizations
Rscript code/loop-clothing-viz.R
```

## Project Structure

```
├── code/
│   └── loop-clothing-viz.R       # Main visualization script
├── data/
│   ├── loop-data-ldw-2026.xlsx   # Source data (2nd sheet: "Data (Jan-Oct 25)")
│   ├── loop-data.csv             # Converted CSV (generated)
│   └── README -- Loop Clothing Dataset 2025.pdf
└── plot/                         # Generated visualizations (300 DPI PNG)
```

## R Dependencies

- `readxl` - Excel file reading
- `tidyverse` - Data manipulation and ggplot2
- `patchwork` - Combining multiple plots

## Dataset Schema

| Column | Type | Description |
|--------|------|-------------|
| Timestamp | Date-Time | When observation was recorded |
| Visit Date | Date | Customer's visit date |
| Demographics | Categorical | Undergraduate, Graduate, Non-GW-affiliated, Staff, Faculty |
| Tops, Collared Shirts, Sweaters, Pants, Skirts, Shorts, Dresses, Outerwear, Shoes, Accessories | Count | Number of items taken |
| Experience Rating | Ordinal (1-5) | 1 = Very Poor, 5 = Excellent |
| Brought Donations | Categorical | No, Yes, Donated at blue bin |

**Notes:**
- 877 rows × 15 columns (2nd Excel sheet)
- 13 rows have missing demographic data
- Column `Did you bring donations with you today?` → `brought_donations`

## Licensing Requirements

**License:** CC BY-NC 4.0 (noncommercial only)

**Required attribution:** GW Office of Sustainability (2025). *The Loop Data for GW LAI Data Visualization Competition* [Data set]. https://gwu.box.com/s/498wga8hci1wuxqigjeluwoalvhq39z9
