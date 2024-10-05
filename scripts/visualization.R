# Load necessary libraries
library(ggplot2)
library(dplyr)
library(readr)

# Load sentiment scores (update path if necessary)
sentiment_data <- read_csv("C:/Real-time Sentiment Analysis/data/processed/sentiment_analysis_results.csv")

# Check if sentiment_data is loaded correctly
if (nrow(sentiment_data) == 0) {
  stop("No data loaded. Please check the sentiment_analysis_results.csv file.")
}

# Create directory for processed images if it doesn't exist
if (!dir.exists("C:/Real-time Sentiment Analysis/data/processed")) {
  dir.create("C:/Real-time Sentiment Analysis/data/processed", recursive = TRUE)
}

# 1. Bar plot of sentiment distribution
sentiment_plot <- ggplot(sentiment_data, aes(x = sentiment)) +
  geom_bar(fill = "blue", color = "yellow") +
  labs(title = "Sentiment Distribution", x = "Sentiment", y = "Count") +
  theme_minimal()

# Save sentiment distribution plot
ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_distribution.png", plot = sentiment_plot)
print("Sentiment distribution plot saved as sentiment_distribution.png")

# 2. Sentiment by Source
# Assuming your sentiment_data includes a 'source_name' column
if ("source_name" %in% colnames(sentiment_data)) {
  source_sentiment_plot <- sentiment_data %>%
    group_by(source_name, sentiment) %>%
    summarise(count = n(), .groups = "drop") %>%
    ggplot(aes(x = source_name, y = count, fill = sentiment)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = "Sentiment Distribution by Source", x = "Source", y = "Count") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Save sentiment by source plot
  ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_by_source.png", plot = source_sentiment_plot)
  print("Sentiment by source plot saved as sentiment_by_source.png")
} else {
  print("Column 'source_name' not found in the data.")
}

# 3. Pie Chart of Sentiment Distribution
pie_data <- sentiment_data %>%
  group_by(sentiment) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(sentiment))

pie_plot <- ggplot(pie_data, aes(x = "", y = count, fill = sentiment)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  labs(title = "Sentiment Distribution (Pie Chart)") +
  theme_void()

# Save pie chart
ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_pie_chart.png", plot = pie_plot)
print("Sentiment pie chart saved as sentiment_pie_chart.png")

# 4. Sentiment Over Time
# Assuming your sentiment_data has a 'published_at' column
if ("published_at" %in% colnames(sentiment_data)) {
  sentiment_data$published_at <- as.Date(sentiment_data$published_at)
  
  time_series_plot <- sentiment_data %>%
    group_by(published_at, sentiment) %>%
    summarise(count = n(), .groups = "drop") %>%
    ggplot(aes(x = published_at, y = count, color = sentiment)) +
    geom_line(size = 1) +
    labs(title = "Sentiment Over Time", x = "Date", y = "Count") +
    theme_minimal()
  
  # Save time series plot
  ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_over_time.png", plot = time_series_plot)
  print("Sentiment over time plot saved as sentiment_over_time.png")
} else {
  print("Column 'published_at' not found in the data.")
}

# 5. Boxplot of Sentiment Scores
# Assuming you have sentiment scores in a numerical format
# Add a numeric column to represent sentiment scores (e.g., Positive = 1, Neutral = 0, Negative = -1)
sentiment_data$scores <- recode(sentiment_data$sentiment,
                                "Positive" = 1,
                                "Neutral" = 0,
                                "Negative" = -1)

boxplot_plot <- ggplot(sentiment_data, aes(x = sentiment, y = scores, fill = sentiment)) +
  geom_boxplot() +
  labs(title = "Boxplot of Sentiment Scores", x = "Sentiment", y = "Scores") +
  theme_minimal()

# Save boxplot
ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_boxplot.png", plot = boxplot_plot)
print("Sentiment boxplot saved as sentiment_boxplot.png")

# Optional: Display plots in R Markdown or Shiny if needed
