# Load necessary libraries
library(dplyr)
library(stringr)
library(spacyr)

# Load your dataset (ensure the correct file path)
news_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/cleaned_news_data.csv")  # Use the cleaned data file

# Check the structure of the dataset to ensure 'cleaned_description' exists
if(!"cleaned_description" %in% colnames(news_data)) {
  stop("The 'cleaned_description' column is missing. Ensure the text cleaning step was completed.")
}

# Initialize SpaCy for NER (use the small English model)
spacy_initialize(model = "en_core_web_sm")

# Perform NER on the cleaned description
ner_results <- spacy_parse(news_data$cleaned_description)

# Extract named entities (e.g., proper nouns and nouns)
entities <- ner_results %>%
  filter(pos %in% c("PROPN", "NOUN"))  # Filter for proper nouns and nouns

# Save the extracted entities
write.csv(entities, "C:/Real-time Sentiment Analysis/data/processed/entities.csv", row.names = FALSE)

# Clean up SpaCy resources
spacy_finalize()

print("NER completed and entities saved to 'entities.csv'.")
