# Load required libraries
library(tidyverse)
library(tm)
library(tidytext)
library(textdata)
library(dplyr)

# Load the news articles data
news_data <- read.csv("data/raw/news_articles_data.csv")  # Update the path as per your file structure

# Preprocess text data
clean_text <- function(text) {
  text <- tolower(text)  # Convert to lowercase
  text <- removePunctuation(text)  # Remove punctuation
  text <- removeNumbers(text)  # Remove numbers
  text <- removeWords(text, stopwords("en"))  # Remove stop words
  text <- stripWhitespace(text)  # Remove extra white space
  return(text)
}

# Apply text pre processing to the 'description' column
news_data$cleaned_description <- clean_text(news_data$description)  # Adjust if your column name differs

# Load the AFINN lexicon
afinn <- get_sentiments("afinn") %>%
  mutate(sentiment = ifelse(value > 0, "positive", "negative")) %>%
  select(word, sentiment)


# Merge all lexicons into one dataset
merged_lexicon <- bind_rows(bing,afinn) %>%
  distinct(word, sentiment)  # Remove duplicates

# Save the merged lexicon as sentiment_lexicon.csv
write.csv(merged_lexicon, "data/processed/sentiment_lexicon.csv", row.names = FALSE)
cat("New sentiment_lexicon.csv has been created with a broader set of words.\n")

# Load the new sentiment lexicon
sentiment_lexicon_path <- "data/processed/sentiment_lexicon.csv"  # Adjust path as necessary

if (file.exists(sentiment_lexicon_path)) {
  sentiment_lexicon <- read.csv(sentiment_lexicon_path)
  if (nrow(sentiment_lexicon) == 0) {
    stop("Sentiment lexicon file is empty.")
  }
} else {
  stop("Sentiment lexicon file does not exist. Please create the file at: ", sentiment_lexicon_path)
}

# Perform sentiment analysis with expanded lexicon
sentiment_scores <- news_data %>%
  rowwise() %>%
  mutate(sentiment = case_when(
    any(str_detect(cleaned_description, paste(sentiment_lexicon$word[sentiment_lexicon$sentiment == "positive"], collapse = "|"))) ~ "positive",
    any(str_detect(cleaned_description, paste(sentiment_lexicon$word[sentiment_lexicon$sentiment == "negative"], collapse = "|"))) ~ "negative",
    TRUE ~ "neutral"
  ))

# Save the sentiment scores
write.csv(sentiment_scores, "data/processed/sentiment_scores.csv", row.names = FALSE)

cat("Sentiment analysis completed and results saved successfully.\n")
