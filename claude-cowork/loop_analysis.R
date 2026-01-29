# The Loop Clothing Exchange - Data Visualization
# GW Office of Sustainability Data
#
# This script analyzes visitor data from The Loop, GW's free clothing exchange

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(lubridate)
library(scales)

# Read the data
data <- read.csv("/sessions/brave-zen-gauss/loop_data.csv")

# Convert date columns
data$Visit.Date <- as.Date(data$Visit.Date)
data$Timestamp <- as.POSIXct(data$Timestamp)

# Extract month for aggregation
data$Month <- floor_date(data$Visit.Date, "month")
data$MonthLabel <- format(data$Month, "%b %Y")

# Define clothing item columns
clothing_cols <- c("Tops", "Collared.Shirts", "Sweaters", "Pants",
                   "Skirts", "Shorts", "Dresses", "Outerwear",
                   "Shoes", "Accessories")

# Calculate total items per visit (replacing NA with 0)
data$Total.Items <- rowSums(data[, clothing_cols], na.rm = TRUE)

# Create a cleaner month ordering
data$MonthOrder <- as.numeric(format(data$Month, "%Y%m"))

# Aggregate clothing items by type for the pie/bar chart
clothing_totals <- data %>%
  summarise(across(all_of(clothing_cols), ~sum(.x, na.rm = TRUE))) %>%
  pivot_longer(everything(), names_to = "Item", values_to = "Count") %>%
  mutate(Item = gsub("\\.", " ", Item)) %>%
  arrange(desc(Count))

# Monthly visit counts
monthly_visits <- data %>%
  group_by(Month, MonthLabel) %>%
  summarise(Visits = n(),
            Total.Items = sum(Total.Items, na.rm = TRUE),
            .groups = "drop") %>%
  arrange(Month)

# Demographics breakdown
demographics <- data %>%
  count(Demographics) %>%
  mutate(Percentage = n / sum(n) * 100) %>%
  arrange(desc(n))

# Donations breakdown
donations <- data %>%
  count(Did.you.bring.donations.with.you.today.) %>%
  mutate(Percentage = n / sum(n) * 100,
         Response = ifelse(Did.you.bring.donations.with.you.today. == "Yes", "Yes",
                          ifelse(Did.you.bring.donations.with.you.today. == "No", "No",
                                "Donated at blue bin")))

# Set up the multi-panel plot
png("/sessions/brave-zen-gauss/mnt/competition-for-cowork/loop_visualization.png",
    width = 14, height = 10, units = "in", res = 150)

# Create a 2x2 layout
par(mfrow = c(1, 1))

# Use ggplot2 for better aesthetics
theme_set(theme_minimal(base_size = 12))

# Define color palette
colors_main <- c("#00478F", "#FFBF00", "#4A90A4", "#2E8B57", "#DC143C")
colors_items <- c("#003366", "#005599", "#0077BB", "#3399CC", "#66BBDD",
                  "#FFCC00", "#FFD633", "#FFE066", "#99CC66", "#CC6666")

# Plot 1: Monthly Visits Over Time (Line chart)
p1 <- ggplot(monthly_visits, aes(x = Month, y = Visits)) +
  geom_line(color = "#00478F", linewidth = 1.2) +
  geom_point(color = "#FFBF00", size = 3) +
  geom_area(alpha = 0.2, fill = "#00478F") +
  labs(title = "Monthly Visitors to The Loop",
       subtitle = "January - October 2025",
       x = "",
       y = "Number of Visitors") +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  theme(plot.title = element_text(face = "bold", size = 14),
        axis.text.x = element_text(angle = 45, hjust = 1))

# Plot 2: Clothing Items Distribution (Horizontal Bar Chart)
p2 <- ggplot(clothing_totals, aes(x = reorder(Item, Count), y = Count, fill = Item)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = Count), hjust = -0.2, size = 3.5) +
  coord_flip() +
  scale_fill_manual(values = colors_items) +
  labs(title = "Clothing Items Taken by Category",
       subtitle = "Total items distributed (Jan-Oct 2025)",
       x = "",
       y = "Number of Items") +
  theme(plot.title = element_text(face = "bold", size = 14)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)))

# Plot 3: Demographics Pie Chart
p3 <- ggplot(demographics, aes(x = "", y = n, fill = Demographics)) +
  geom_col(width = 1, color = "white") +
  coord_polar("y", start = 0) +
  scale_fill_manual(values = colors_main) +
  labs(title = "Visitor Demographics",
       subtitle = "Who shops at The Loop?",
       fill = "") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "bottom") +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white", fontface = "bold", size = 4)

# Plot 4: Donation Behavior
p4 <- ggplot(donations, aes(x = reorder(Response, n), y = n, fill = Response)) +
  geom_col(show.legend = FALSE, width = 0.7) +
  geom_text(aes(label = paste0(n, " (", round(Percentage, 1), "%)")),
            vjust = -0.3, size = 4) +
  scale_fill_manual(values = c("Yes" = "#2E8B57", "No" = "#DC143C",
                               "Donated at blue bin" = "#4A90A4")) +
  labs(title = "Did Visitors Bring Donations?",
       subtitle = "Contribution behavior of Loop shoppers",
       x = "",
       y = "Number of Visitors") +
  theme(plot.title = element_text(face = "bold", size = 14)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)))

# Combine plots using patchwork
library(patchwork)

combined_plot <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "The Loop: GW's Free Clothing Exchange",
    subtitle = "Data Visualization of Visitor Activity (January - October 2025)",
    caption = "Data source: GW Office of Sustainability | Licensed under CC BY-NC 4.0",
    theme = theme(
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5, color = "#00478F"),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "#666666"),
      plot.caption = element_text(size = 9, color = "#999999", hjust = 1)
    )
  )

print(combined_plot)

dev.off()

cat("\n=== Summary Statistics ===\n")
cat("Total visitors:", nrow(data), "\n")
cat("Total clothing items distributed:", sum(data$Total.Items, na.rm = TRUE), "\n")
cat("Average items per visit:", round(mean(data$Total.Items, na.rm = TRUE), 2), "\n")
cat("Date range:", as.character(min(data$Visit.Date)), "to", as.character(max(data$Visit.Date)), "\n")
cat("Average experience rating:", round(mean(data$Experience.Rating, na.rm = TRUE), 2), "/ 5\n")
cat("\nPlot saved to: loop_visualization.png\n")
