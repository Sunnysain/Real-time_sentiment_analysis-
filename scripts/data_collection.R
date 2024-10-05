# Load required libraries
library(httr)
library(jsonlite)

# Set your News API key
news_api_key <- "6031d4cd5e1d4691bf3cd9c7ed4d357a"

# Function to fetch news articles using News API
fetch_news_articles <- function(query, n = 100) {
  # Construct the API request URL
  url <- paste0(
    "https://newsapi.org/v2/everything?",
    "q=", URLencode(query),
    "&pageSize=", n,
    "&apiKey=", news_api_key
  )
  
  # Send the GET request
  response <- GET(url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Parse the response as JSON
    articles_data <- content(response, as = "parsed", type = "application/json")
    
    # Check if articles are present
    if (!is.null(articles_data$articles) && length(articles_data$articles) > 0) {
      # Standardize the data fields (ensure all articles have the same fields)
      articles_list <- lapply(articles_data$articles, function(article) {
        data.frame(
          source_name = ifelse(!is.null(article$source$name), article$source$name, NA),
          author = ifelse(!is.null(article$author), article$author, NA),
          title = ifelse(!is.null(article$title), article$title, NA),
          description = ifelse(!is.null(article$description), article$description, NA),
          url = ifelse(!is.null(article$url), article$url, NA),
          published_at = ifelse(!is.null(article$publishedAt), article$publishedAt, NA),
          content = ifelse(!is.null(article$content), article$content, NA),
          stringsAsFactors = FALSE
        )
      })
      
      # Combine all article data into a data frame
      articles_df <- do.call(rbind, articles_list)
      return(articles_df)
    } else {
      message("No articles found for the specified query.")
      return(data.frame())
    }
  } else {
    stop("Failed to fetch data from News API. Status: ", status_code(response))
  }
}

# Main execution block
main <- function() {
  # Set the query and number of articles to fetch
  query <- "climate change"  # Replace with your desired keyword or topic
  n <- 100  # Number of articles to fetch
  
  # Fetch news articles
  articles_data <- fetch_news_articles(query, n)
  
  # Check if articles_data is not empty before writing to CSV
  if (nrow(articles_data) > 0) {
    # Create directory if it doesn't exist
    dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
    
    # Write articles data to CSV
    write.csv(articles_data, "data/raw/news_articles_data.csv", row.names = FALSE)
    message("News articles fetched and saved successfully.")
  } else {
    message("No articles found for the specified query.")
  }
}

# Run the main function
main()
