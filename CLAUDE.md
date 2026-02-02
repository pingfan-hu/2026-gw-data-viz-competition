# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Data visualization competition project analyzing customer visit data from The Loop clothing exchange program at George Washington University (Mount Vernon Campus). Data covers January 2025 - October 2025.

## Commands

```bash
# Run all visualizations
Rscript code/visualizations.R
```

## Project Structure

```
├── code/
│   └── visualizations.R          # Main visualization script
├── data/
│   ├── loop-data-ldw-2026.xlsx   # Source data (2nd sheet: "Data (Jan-Oct 25)")
│   ├── loop-data.csv             # Converted CSV (generated)
│   └── README -- Loop Clothing Dataset 2025.pdf
└── plots/                        # Generated visualizations (300 DPI PNG)
```

## R Dependencies

- `readxl` - Excel file reading
- `tidyverse` - Data manipulation and ggplot2
- `patchwork` - Combining multiple plots

## Dataset Notes

- **Source:** 2nd Excel sheet "Data (Jan-Oct 25)" (877 rows × 15 columns)
- **Column rename:** `Did you bring donations with you today?` → `brought_donations`
- **Item columns:** tops, collared_shirts, sweaters, pants, skirts, shorts, dresses, outerwear, shoes, accessories
- **Demographics:** Undergraduate, Graduate, Non-GW-affiliated, Staff, Faculty
- **13 rows have missing demographic data**

## Licensing Requirements

**License:** CC BY-NC 4.0 (noncommercial only)

**Required attribution:** GW Office of Sustainability (2025). *The Loop Data for GW LAI Data Visualization Competition* [Data set]. https://gwu.box.com/s/498wga8hci1wuxqigjeluwoalvhq39z9
