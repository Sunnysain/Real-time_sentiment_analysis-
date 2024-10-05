# Load necessary libraries
library(dplyr)
library(stringr)
library(tm)

# Load your dataset (ensure the correct file path)
news_data <- read.csv("C:/Real-time Sentiment Analysis/data/raw/news_articles_data.csv")

# Check the structure of the dataset to ensure 'description' column exists
str(news_data)

# Step 1: Text Cleaning for 'description' column
if("description" %in% colnames(news_data)) {
  
  # Clean the 'description' column to create 'cleaned_description'
  news_data$cleaned_description <- news_data$description %>%
    # Convert text to lowercase
    tolower() %>%
    # Remove punctuation
    str_replace_all("[[:punct:]]", " ") %>%
    # Remove numbers
    str_replace_all("[0-9]", " ") %>%
    # Remove extra whitespace
    str_trim() %>%
    # Remove multiple spaces between words
    str_squish()
  
  # Step 2: Remove stopwords using 'tm' package
  # Define stopwords removal function
  remove_stopwords <- function(text) {
    text <- removeWords(text, stopwords("en"))  # Remove English stopwords
    return(text)
  }
  
  # Apply stopwords removal to 'cleaned_description'
  news_data$cleaned_description <- sapply(news_data$cleaned_description, remove_stopwords)
  
  # Step 3: Remove rows where 'cleaned_description' is NA or empty
  news_data <- news_data[!is.na(news_data$cleaned_description) & news_data$cleaned_description != "", ]
  
  # Step 4: Check the cleaned data
  head(news_data$cleaned_description)
  
  # Save the cleaned data to a new CSV file
  write.csv(news_data, "C:/Real-time Sentiment Analysis/data/processed/cleaned_news_data.csv", row.names = FALSE)
  
  print("Text cleaning and stopwords removal completed. Cleaned data saved.")
  
} else {
  stop("The 'description' column is not found in the dataset.")
}

# The cleaned data is now ready for topic modeling or other text analysis tasks.
