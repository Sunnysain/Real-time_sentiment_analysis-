library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(spacyr)
library(wordcloud)
library(RColorBrewer)

# Load necessary data
news_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/cleaned_news_data.csv")
sentiment_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/sentiment_analysis_results.csv")
entities_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/entities.csv")


# Initialize spacy for NER
spacy_initialize(model = "en_core_web_sm")

# Define UI
ui <- fluidPage(
  titlePanel("Real-time Sentiment Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("hashtag", "Enter Hashtag:", value = "climate change"),
      actionButton("fetch", "Fetch News", icon = icon("refresh")),
      hr(),
      helpText("Press the button to fetch news articles containing the hashtag."),
      dateRangeInput("dateRange", "Select Date Range:", 
                     start = Sys.Date() - 30, end = Sys.Date())
    ),
    
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Sentiment Distribution",
                           plotOutput("sentimentPlot"),
                           plotlyOutput("sentimentTimePlot")
                  ),
                  tabPanel("Named Entities",
                           plotOutput("entityPlot"),
                           hr(),
                           tableOutput("entityTable"),
                           plotOutput("wordCloudPlot")
                  ),
                  tabPanel("Raw Data",
                           tableOutput("rawDataTable")
                  )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  fetched_data <- reactiveVal()
  sentiment_data_filtered <- reactiveVal()
  entity_counts <- reactiveVal()
  
  observeEvent(input$fetch, {
    hashtag <- input$hashtag
    filtered_data <- news_data %>%
      filter(grepl(hashtag, description, ignore.case = TRUE)) %>%
      filter(as.Date(published_at) >= input$dateRange[1] & as.Date(published_at) <= input$dateRange[2])
    
    if (nrow(filtered_data) > 0) {
      fetched_data(filtered_data)
      
      if ("title" %in% colnames(filtered_data) && nrow(filtered_data) > 0) {
        filtered_sentiment_data <- sentiment_data %>%
          filter(title %in% filtered_data$title)
        
        if (nrow(filtered_sentiment_data) == 0) {
          showModal(modalDialog(
            title = "No Sentiment Data",
            "No sentiment data available for the fetched news articles.",
            easyClose = TRUE
          ))
          sentiment_data_filtered(NULL)
          entity_counts(NULL)
          return()
        }
        
        sentiment_data_filtered(filtered_sentiment_data)
        
        ner_results <- spacy_parse(fetched_data()$description)
        entity_counts(ner_results %>%
                        group_by(entity) %>%
                        summarise(count = n(), .groups = 'drop'))
        
      } else {
        showModal(modalDialog(
          title = "Data Error",
          "The filtered data does not contain the required 'title' column.",
          easyClose = TRUE
        ))
        fetched_data(NULL)
        sentiment_data_filtered(NULL)
        entity_counts(NULL)
      }
      
    } else {
      fetched_data(NULL)
      sentiment_data_filtered(NULL)
      entity_counts(NULL)
      showModal(modalDialog(
        title = "No Results",
        "No articles found for the entered hashtag.",
        easyClose = TRUE
      ))
    }
  })
  # Sentiment distribution plot
  output$sentimentPlot <- renderPlot({
    if (!is.null(fetched_data()) && !is.null(sentiment_data_filtered())) {
      ggplot(sentiment_data_filtered(), aes(x = sentiment, fill = sentiment)) +
        geom_bar(color = "black", size = 0.3) +
        scale_fill_manual(values = brewer.pal(3, "Set1")) +
        labs(title = paste("Sentiment Distribution for", input$hashtag), x = "Sentiment", y = "Count") +
        theme_minimal(base_size = 15) +
        theme(legend.position = "top", legend.title = element_blank())
    } else {
      plot.new()
      text(0.5, 0.5, "No sentiment data available. Please fetch news articles.")
    }
  })
  
  # Table for named entities
  output$entityTable <- renderTable({
    if (!is.null(entities_data)) {
      # You can limit the number of rows displayed or modify columns as needed
      head(entities_data, 10)
    } else {
      NULL
    }
  })
  
  
  
  
# Sentiment over time plot
output$sentimentTimePlot <- renderPlotly({
  if (!is.null(fetched_data()) && !is.null(sentiment_data_filtered())) {
    time_data <- sentiment_data_filtered() %>%
      group_by(published_at, sentiment) %>%
      summarise(count = n(), .groups = 'drop')

    # Ensure the published_at column is in Date format
    time_data$published_at <- as.Date(time_data$published_at)

    # Create the plot using plotly
    p <- plot_ly(data = time_data, 
                  x = ~published_at, 
                  y = ~count, 
                  color = ~sentiment, 
                  type = "scatter", 
                  mode = "lines+markers", 
                  line = list(width = 2), 
                  marker = list(size = 5)) %>%
      layout(title = paste("Sentiment Over Time for", input$hashtag),
             xaxis = list(title = "Date"),
             yaxis = list(title = "Count"),
             legend = list(title = list(text = ""), position = "top")) %>%
      config(displayModeBar = FALSE)  # Optional: remove the mode bar

    # Optional: Add smoothing manually for aesthetics
    # This part has been commented out to avoid the error.
    # smoothed_data <- smooth.spline(x = time_data$published_at, y = time_data$count)
    # p <- p %>% add_lines(x = ~published_at, y = ~predict(smoothed_data)$y, line = list(dash = 'dash', width = 1.5))

    p
  } else {
    NULL
  }
})


  
  # Named Entities plot
  output$entityPlot <- renderPlot({
    if (!is.null(entity_counts()) && nrow(entity_counts()) > 0) {
      ggplot(entity_counts()[1:10, ], aes(x = reorder(entity, count), y = count, fill = entity)) +
        geom_bar(stat = "identity") +
        scale_fill_brewer(palette = "Paired") +
        labs(title = "Top 10 Named Entities", x = "Entity", y = "Count") +
        theme_minimal(base_size = 15) +
        theme(legend.position = "none") +
        coord_flip()
    } else {
      plot.new()
      text(0.5, 0.5, "No entity data available.")
    }
  })
  
  # Word cloud for entities
  output$wordCloudPlot <- renderPlot({
    if (!is.null(entity_counts())) {
      wordcloud(entity_counts()$entity, min.freq = 1, max.words = 100, random.order = FALSE, 
                colors = brewer.pal(8, "Dark2"), scale = c(3, 0.5))
    }
  })
  
  # Table of raw data
  output$rawDataTable <- renderTable({
    if (!is.null(fetched_data())) {
      fetched_data()
    } else {
      NULL
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
