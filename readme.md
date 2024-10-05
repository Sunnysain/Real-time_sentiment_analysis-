

---

# 🌐 Real-time Sentiment Analysis Project 🎯

Welcome to the **Real-time Sentiment Analysis** project! This Shiny-based web application leverages machine learning and natural language processing (NLP) techniques to analyze news articles and visualize sentiment, topic modeling, and named entities. It's designed to give you insights into real-time sentiment trends across news sources. 🌟

## 🚀 Project Overview

The application allows users to:
- 🔍 Fetch news articles based on specific hashtags (via the News API).
- 📊 Visualize sentiment distribution using various plots (bar chart, pie chart, and time series).
- 🗂 Analyze named entities within the articles.
- 🧠 Perform topic modeling to discover hidden themes across articles.

## 🛠 Features

### ✅ Sentiment Distribution
- Shows the overall sentiment of news articles: Positive, Neutral, or Negative.
  
### 📈 Sentiment Over Time
- Visualizes how sentiment trends change over time.

### 🥧 Sentiment Pie Chart
- A fun pie chart that gives a quick overview of the sentiment breakdown.

### 📰 Named Entity Recognition (NER)
- Extracts and displays important entities like proper nouns and organizations mentioned in the articles.

### 🧩 Topic Modeling
- Uses Latent Dirichlet Allocation (LDA) to identify and visualize topics discussed in the articles.

## 📦 Technologies & Libraries

This project utilizes a wide array of R packages for web development, data processing, and visualizations:

- **Shiny** 🌟: Web application framework for R.
- **ggplot2** 🎨: Creating interactive and stunning plots.
- **dplyr** 🛠: Data manipulation and transformation.
- **tm** 🧠: Text mining for document-term matrix creation.
- **topicmodels** 🧩: Topic modeling using LDA.
- **spacyr** 🧑‍💻: Named entity recognition (NER) with SpaCy.
- **broom** 🧹: Converting statistical results into tidy data.
- **tidyverse** 🌐: Data science packages for data wrangling and visualization.

## 📋 Prerequisites

To run this project, make sure you have the following:

- R (version 4.0 or higher) installed on your machine.
- RStudio for a more pleasant development experience.
- News API key (to fetch news articles).

## ⚙️ Setup Instructions

Follow these steps to get the application up and running:

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/your-username/real-time-sentiment-analysis.git
   cd real-time-sentiment-analysis
   ```

2. **Install Dependencies**:

   Open RStudio and run the following to install the required R packages:

   ```R
   install.packages(c("shiny", "ggplot2", "dplyr", "tm", "topicmodels", "spacyr", "broom", "tidyverse", "readr", "stringr", "reshape2", "data.table", "tidytext", "scales"))
   ```

3. **Set up your News API Key**:
   
   - Create a `.Renviron` file in the project root.
   - Add your News API key as follows:

     ```bash
     NEWS_API_KEY=your_news_api_key_here
     ```

4. **Run the Application**:

   To start the Shiny app, use the following command:

   ```R
   shiny::runApp()
   ```

   The app will launch in your default web browser.

## 🔧 R Scripts Explained

### 1. **`data_collection.R`**
   - This script collects data from the News API based on a given hashtag and saves it for analysis.

### 2. **`sentiment_analysis.R`**
   - Performs sentiment analysis on the collected news articles using NLP techniques and saves the results as sentiment scores.

### 3. **`topic_modeling.R`**
   - Uses the LDA algorithm to discover latent topics in the news articles.

### 4. **`named_entity_recognition.R`**
   - Identifies named entities such as organizations and people mentioned in the articles using SpaCy.

### 5. **`visualization.R`**
   - Generates various visualizations such as sentiment distribution, pie charts, time series plots, and more.

### 6. **`app.R` and `ui.R`**
   - The main web application logic (server-side and user interface) for running the Shiny app.

## 📊 Visualizations

- **Sentiment Distribution** 📊: Displays the distribution of positive, neutral, and negative sentiments.
- **Sentiment Over Time** ⏳: Tracks how sentiment fluctuates over time.
- **Pie Chart** 🥧: Offers a visual breakdown of sentiment.
- **Topic Modeling** 🧩: Displays the most frequent words associated with each topic.
- **Named Entity Recognition** 📰: Shows important entities extracted from the news articles.

## 🤖 Running the Application

To run the Shiny app locally, execute this command inside RStudio:

```R
shiny::runApp()
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

If you want to contribute to this project, feel free to open issues and submit pull requests. We welcome improvements! 🛠️

## 👏 Acknowledgements

- Shiny for providing a powerful and easy-to-use framework for building web apps in R.
- The amazing R community for creating incredible libraries like `ggplot2`, `dplyr`, `tm`, and `spacyr`.
- News API for providing real-time news data for analysis.

---

Feel free to enhance this `README.md` file to suit your project and branding needs! 🎉