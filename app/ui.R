library(shiny)
library(ggplot2)
library(dplyr)
library(wordcloud)
library(RColorBrewer)
library(plotly)

# Load necessary data
sentiment_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/sentiment_scores.csv")
entities_data <- read.csv("C:/Real-time Sentiment Analysis/data/processed/entities.csv")

# Define UI for the application
ui <- fluidPage(
  
  # Application title
  titlePanel("Real-time Sentiment Analysis"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    
    # Sidebar to input hashtag and fetch news articles
    sidebarPanel(
      textInput("hashtag", "Enter Hashtag:", value = "#climatechange"),
      actionButton("fetch", "Fetch News", icon = icon("refresh")),
      hr(),
      helpText("Press the button to fetch news articles containing the hashtag."),
      dateRangeInput("dateRange", "Select Date Range:", 
                     start = Sys.Date() - 30, end = Sys.Date())
    ),
    
    # Main panel to display outputs
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
server <- function(input, output) {
  fetched_data <- reactiveVal(NULL)
  
  observeEvent(input$fetch, {
    hashtag <- input$hashtag
    news_data <- read.csv("C:/Real-time Sentiment Analysis/data/raw/news_articles_data.csv")
    filtered_data <- news_data[grepl(hashtag, news_data$description, ignore.case = TRUE), ]
    
    # Date range filtering
    filtered_data <- filtered_data %>%
      filter(as.Date(published_at) >= input$dateRange[1] & as.Date(published_at) <= input$dateRange[2])
    
    if (nrow(filtered_data) > 0) {
      fetched_data(filtered_data)
      
      # Update sentiment data based on fetched articles
      sentiment_data <<- sentiment_data[sentiment_data$title %in% filtered_data$title, ]
      
      # Update entities data as well if necessary
      entities_data <<- entities_data[entities_data$title %in% filtered_data$title, ]
    } else {
      fetched_data(NULL)
      showModal(modalDialog(
        title = "No Results",
        "No articles found for the entered hashtag.",
        easyClose = TRUE
      ))
    }
  })
  
  output$sentimentPlot <- renderPlot({
    if (!is.null(fetched_data())) {
      ggplot(sentiment_data, aes(x = sentiment)) +
        geom_bar(fill = "blue", color = "yellow") +
        labs(title = "Sentiment Distribution", x = "Sentiment", y = "Count") +
        theme_minimal()
    } else {
      plot.new()
      text(0.5, 0.5, "No sentiment data available. Please fetch news articles.")
    }
  })
  
  output$sentimentTimePlot <- renderPlotly({
    if (!is.null(fetched_data())) {
      time_data <- sentiment_data %>%
        group_by(published_at, sentiment) %>%
        summarise(count = n(), .groups = 'drop')
      
      p <- ggplot(time_data, aes(x = as.Date(published_at), y = count, color = sentiment)) +
        geom_line() +
        labs(title = "Sentiment Over Time", x = "Date", y = "Count") +
        theme_minimal()
      
      ggplotly(p)
    }
  })
  
  output$entityPlot <- renderPlot({
    if (!is.null(entities_data)) {
      entity_counts <- entities_data %>%
        group_by(entity) %>%
        summarise(count = n(), .groups = "drop") %>%
        arrange(desc(count))
      
      ggplot(entity_counts[1:10, ], aes(x = reorder(entity, count), y = count)) +
        geom_bar(stat = "identity", fill = "purple") +
        labs(title = "Top 10 Named Entities", x = "Entity", y = "Count") +
        theme_minimal() +
        coord_flip()
    } else {
      plot.new()
      text(0.5, 0.5, "No entity data available. Please fetch news articles.")
    }
  })
  
  output$wordCloudPlot <- renderPlot({
    if (!is.null(entities_data)) {
      wordcloud(entities_data$entity, min.freq = 1, max.words = 100, random.order = FALSE, colors = brewer.pal(8, "Dark2"))
    }
  })
  
  output$entityTable <- renderTable({
    if (!is.null(entities_data)) {
      entities_data
    } else {
      NULL
    }
  })
  
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
