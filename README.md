# Factored Datathon
Brazil Data Engineering

## 1. Context
In this datathon Factored created a challenge to ingest e-commerce data from a data lake and an event hub, this data consists in product metadata and customer reviews, work with text isn't a simple task, with big data is worst, so this challange aggregates a lot in my data engineer skills, and much more in my data analytics and data science skills, I work as a data engineer since 2019, I really love this part, but data analysis wasn't my strong point, but this datathon helped me to evolve.

## 2. Architecture
I choosed to use Azure for this datathon, because I could use Azure Synapse and Stream Analytics, AWS and GCP offers tools that are similiar to these ones, but I already worked with this, this way I could spend less time in Data Engineering and more in Data Analysis, but I challanged myself using Terraform, I have provisioned Azure Synapse Workspace, Azure Spark Pool, Azure Stream Analytics Job and Azure Storage Account using terraform, the code is stored in terraform folder.

![Factored Datathon Architecture](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Factored%20Datathon%20Architecture.jpg)

## 3. Text Processing and LDA Model
After ingesting data into data lake it`s time to process our review text, I have listed the product categories, and selected main_category automotive to work with, because I like this subject, I have decided to do a topic modeling using LDA (Latent Dirichlet Allocation), this name isn't easy :D

I started using spark nlp lib to do this process, i did the following steps:

![Text Processing](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Text%20Processing.png)

This code is stored in azure/synapse/notebooks/EDA_1_1..., in tokenization I splitted the review text in a list after removing ponctuation and numbers, in normalization all words were transformed to lower case and plurals removed, removed stop words and then lemmatization, in this step common words were transformed, for example worked became work.

This list of words were transformed to a vector using count vectorizer and IDF, now we can train the LDA model. 
In the first train I have set up 4 topics, but it wasn't good, so I trained with 15 topics, and results were better.

I plotted this visual, we have some specific topics, for example, topic 9 is related to car parts for lighining, we have some frequent terms like bulb, light, yellow, bright and so on.

![LDA](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/LDA_visual.png)

A future implementation could be analyzing this specific topics to understand more about possible concentrated problems, for example topic 5 is related to shipping, this way we can know more details about the products delivery.

## 4. Graph Database
Graphs are good to understand about relationships, I have uploaded the streaming data to Neo4j database, and started to analyze the relationships, using graph databases is possible to create recommendation systems

Graph Example:

![Graph](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Neo4J_graph_example.png)

let's suppose that a customer A have bought product 1, customer B also bought this product, and both rated with 4 stars or more, so both customer have similiar preferences, we can recommend to customer A a product that customer B bought and liked.

Using this logic I built a web app using streamlit, where you can add a reviewer_id and get the recommended products
* link: https://factored-datathon-2023-brazil-data-engineering-uoa5p86azufxzm3.streamlit.app/
  
![Web App](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/WebApp.png)

## 5. Power BI
Using Power BI is possible to create some interesting dashboards to help stakeholders take decisions, I created a dashboard where stakeholders can fill their brand name and see overall avarage, quantity of itens by category and most used words in reviews for that selection.

![Power BI](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Dashboard.png)

## 6. Final Notebook and presentation

* Presentation: https://tome.app/factored-datathon/fundraising-pitch-copy-clkx28drb0078pv5pytulpnvd
* Notebook: https://colab.research.google.com/gist/Gabrielvinicius27/3dd7e8e3b01e06329c88f687991a877b/topic-modelling-and-graph-analysis.ipynb#scrollTo=gyi50pyLqgis



