# Loop Clothing Exchange Data Visualization
# GW Data Visualization Competition 2026

library(readxl)
library(tidyverse)
library(patchwork)

# ==============================================================================
# Setup paths
# ==============================================================================
project_root <- "/Users/pingfan/Documents/Code/GW Data Visualization Competition 2026"
excel_path <- file.path(project_root, "data", "loop-data-ldw-2026.xlsx")
csv_path <- file.path(project_root, "data", "loop-data.csv")
plot_dir <- file.path(project_root, "plot")

# Create plot directory if it doesn't exist
dir.create(plot_dir, showWarnings = FALSE)

# ==============================================================================
# Check Excel sheets and read data
# ==============================================================================
sheets <- excel_sheets(excel_path)
cat("Available sheets:", paste(sheets, collapse = ", "), "\n")

# Read the 2nd sheet (or 1st if only one exists)
sheet_to_read <- if (length(sheets) >= 2) sheets[2] else sheets[1]
cat("Reading sheet:", sheet_to_read, "\n")

loop_data <- read_excel(excel_path, sheet = sheet_to_read)

# Save as CSV for easier future reading
write_csv(loop_data, csv_path)
cat("Data saved to:", csv_path, "\n")

# ==============================================================================
# Data preview and cleaning
# ==============================================================================
cat(
  "\nData dimensions:",
  nrow(loop_data),
  "rows x",
  ncol(loop_data),
  "columns\n"
)
cat("Column names:\n")
print(names(loop_data))

# Standardize column names (remove spaces, make lowercase)
loop_data <- loop_data %>%
  rename_with(~ str_replace_all(.x, " ", "_") %>% tolower()) %>%
  rename(brought_donations = `did_you_bring_donations_with_you_today?`)

# Parse dates and create month column
loop_data <- loop_data %>%
  mutate(
    visit_date = as.Date(visit_date),
    month = floor_date(visit_date, "month"),
    month_label = format(month, "%b")
  )

# Define item columns
item_cols <- c(
  "tops",
  "collared_shirts",
  "sweaters",
  "pants",
  "skirts",
  "shorts",
  "dresses",
  "outerwear",
  "shoes",
  "accessories"
)

# ==============================================================================
# Plot 1: Seasonal Item Trends (Line/Area Chart)
# ==============================================================================
cat("\nCreating Plot 1: Seasonal Item Trends...\n")

# Aggregate items taken and donations by month
monthly_totals <- loop_data %>%
  mutate(
    total_items = rowSums(across(all_of(item_cols)), na.rm = TRUE),
    donated = brought_donations != "No"
  ) %>%
  group_by(month, month_label) %>%
  summarise(
    Taken = sum(total_items, na.rm = TRUE),
    Donated = sum(donated, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(Taken, Donated), names_to = "type", values_to = "count")

# Order months chronologically
month_order <- loop_data %>%
  distinct(month, month_label) %>%
  arrange(month) %>%
  pull(month_label)

monthly_totals$month_label <- factor(
  monthly_totals$month_label,
  levels = month_order
)

# Create line chart with 2 lines
p1 <- ggplot(
  monthly_totals,
  aes(x = month_label, y = count, color = type, group = type)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Taken" = "#377eb8", "Donated" = "#4daf4a")) +
  labs(
    title = "Monthly Items Taken vs Donations",
    x = "Month",
    y = "Count",
    color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

# ==============================================================================
# Plot 2: Item Totals (Bar Chart)
# ==============================================================================
cat("Creating Plot 2: Item Totals...\n")

# Calculate total items taken across all visits
item_totals <- loop_data %>%
  summarise(across(all_of(item_cols), ~ sum(.x, na.rm = TRUE))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "item",
    values_to = "total_count"
  ) %>%
  mutate(item_label = str_replace_all(item, "_", " ") %>% str_to_title())

# Create bar chart
p2 <- ggplot(
  item_totals,
  aes(x = reorder(item_label, total_count), y = total_count)
) +
  geom_col(fill = "#66c2a5") +
  geom_text(aes(label = total_count), hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Total Items Taken by Category",
    subtitle = "The Loop Clothing Exchange, Jan-Oct 2025",
    x = NULL,
    y = "Total Items Taken",
    caption = "Data: GW Office of Sustainability (2025)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

# ==============================================================================
# Plot 3: Donation Behavior (Two panels)
# ==============================================================================
cat("Creating Plot 3: Donation Behavior...\n")

# Panel A: Donation rates by demographic (bar chart)
donation_by_demo <- loop_data %>%
  mutate(donated = brought_donations != "No") %>%
  group_by(demographics) %>%
  summarise(
    total = n(),
    donors = sum(donated, na.rm = TRUE),
    donation_rate = donors / total * 100,
    .groups = "drop"
  )

p3a <- ggplot(
  donation_by_demo,
  aes(
    x = reorder(demographics, donation_rate),
    y = donation_rate,
    fill = demographics
  )
) +
  geom_col(show.legend = FALSE) +
  geom_text(
    aes(label = sprintf("%.1f%%", donation_rate)),
    hjust = -0.1,
    size = 3.5
  ) +
  coord_flip() +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(
    limits = c(0, max(donation_by_demo$donation_rate) * 1.15)
  ) +
  labs(
    title = "Donation Rate by Demographic",
    x = NULL,
    y = "% of Visitors Who Donated"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

# Panel B: Donation type breakdown (pie/donut)
donation_breakdown <- loop_data %>%
  count(brought_donations) %>%
  mutate(
    pct = n / sum(n) * 100,
    label = sprintf("%s\n(%.1f%%)", brought_donations, pct)
  )

p3b <- ggplot(donation_breakdown, aes(x = 2, y = n, fill = brought_donations)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  scale_fill_manual(
    values = c(
      "No" = "#e41a1c",
      "Donated at blue bin" = "#377eb8",
      "Yes" = "#4daf4a"
    )
  ) +
  labs(
    title = "Donation Behavior Breakdown",
    fill = "Donation Type"
  ) +
  theme_void(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "bottom"
  ) +
  guides(fill = guide_legend(nrow = 2))

# ==============================================================================
# Combine all 4 panels into one dashboard
# ==============================================================================
cat("Combining all panels into dashboard...\n")

combined_dashboard <- (p1 | p2) /
  (p3a | p3b) +
  plot_annotation(
    title = "The Loop Clothing Exchange Dashboard",
    subtitle = "Customer behavior and donation patterns, Jan-Oct 2025",
    caption = "Data: GW Office of Sustainability (2025)",
    theme = theme(
      plot.title = element_text(face = "bold", size = 18),
      plot.subtitle = element_text(size = 12)
    )
  )

ggsave(
  file.path(plot_dir, "loop-clothing-viz.png"),
  combined_dashboard,
  width = 16,
  height = 12,
  dpi = 300
)

# ==============================================================================
# Summary
# ==============================================================================
cat("\n========================================\n")
cat("Visualizations complete!\n")
cat("========================================\n")
cat("\nOutput files:\n")
cat("  - data/loop-data.csv (converted data)\n")
cat("  - plot/loop-clothing-viz.png\n")
