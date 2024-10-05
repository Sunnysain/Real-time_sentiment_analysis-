# Load necessary libraries
library(dplyr)
library(tidyr)
library(textdata)
library(stringr)
library(tidytext)
library(readr)

# Set the timeout for downloading files
options(timeout = 180)  # Set timeout to 180 seconds

# Load the AFINN Lexicon
afinn_lexicon <- textdata::lexicon_afinn()

# Define a function to classify sentiment based on text using AFINN
classify_sentiment <- function(text) {
  # Tokenize the text and join with AFINN lexicon to get sentiment scores
  words <- str_split(text, "\\s+")[[1]]
  scores <- afinn_lexicon %>%
    filter(word %in% words) %>%
    summarise(sentiment_score = sum(value)) %>%
    pull(sentiment_score)
  
  # Classify sentiment based on the total score
  if (is.na(scores) || scores == 0) {
    return("Neutral")
  } else if (scores > 0) {
    return("Positive")
  } else {
    return("Negative")
  }
}

# Load your data (replace this path with your actual data source)
data <- read_csv("C:/Real-time Sentiment Analysis/data/raw/news_articles_data.csv")

# Check for any issues with the loaded data
if (is.null(data) || nrow(data) == 0) {
  stop("Data could not be loaded or is empty.")
}

# Create the cleaned_description column from the description column
data <- data %>%
  mutate(cleaned_description = str_to_lower(description))  # Convert to lowercase for uniformity

# Check the updated data
print(head(data))

# Apply sentiment classification
data <- data %>%
  mutate(sentiment = sapply(cleaned_description, classify_sentiment))

# Print the results after adding sentiment
print(head(data))

# Optional: Save the results to a CSV file
write_csv(data, "C:/Real-time Sentiment Analysis/data/processed/sentiment_analysis_results.csv")

# Optional: Visualize sentiment distribution
library(ggplot2)

ggplot(data, aes(x = sentiment)) +
  geom_bar(fill = "blue") +
  labs(title = "Sentiment Distribution", x = "Sentiment", y = "Count") +
  theme_minimal()

# Save the plot
ggsave("C:/Real-time Sentiment Analysis/data/processed/sentiment_distribution_plot.png")
