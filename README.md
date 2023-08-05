# Factored Datathon
Brazil Data Engineering

## 1. Context
In this datathon Factored created a challange to ingest e-commerce data from a data lake and an event hub, this data consists in product metadata and customer reviews, work with text isn't a simple task, with big data is worst, so this challange aggregates a lot in my data engineer skills, and much more in my data analytics and data science skills, I work as a data engineer since 2019, I really love this part, but data analysis wasn't my strong point, but this datathon helped me to evolve.

## 2. Architecture
I choosed to use Azure for this datathon, because I could use Azure Synapse and Stream Analytics, AWS and GCP offers tools that are similiar to these ones, but I already worked with this, this way I could spend less time in Data Engineering and more in Data Analysis, but I challanged myself using Terraform, I have provisioned Azure Synapse Workspace, Azure Spark Pool, Azure Stream Analytics Job and Azure Storage Account using terraform, the code is stored in terraform folder.

![Factored Datathon Architecture](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Factored%20Datathon%20Architecture.jpg)

## 3. Text Processing and LDA Model
After ingesting data into data lake it`s time to process our review text, I have listed the product categories, and selected main_category automotive to work with, because I like this subject, I have decided to do a topic modeling using LDA (Latent Dirichlet Allocation), this name isn't easy :D

I started using spark nlp lib to do this process, i did the following steps:
![Factored Datathon Architecture](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/Text%20Processing.png)

This code is stored in azure/synapse/notebooks/EDA_1_1..., in tokenization I splitted the review text in a list after removing ponctuation and numbers, in normalization all words were transformed to lower case and plurals removed, removed stop words and then lemmatization, in this step common words were transformed, for example worked became work.

This list of words were transformed to a vector using count vectorizer and IDF, now we can train the LDA model. 
In the first train I have set up 4 topics, but it wasn't good, so I trained with 15 topics, and results were better.

I plotted this visual, we have some specific topics, for example, topic 9 is related to car parts for lighining, we have some frequent terms like bulb, light, yellow, bright and so on.
![Factored Datathon Architecture](https://github.com/Gabrielvinicius27/factored-datathon-2023-brazil-data-engineering/blob/main/images/LDA_visual.png)

A future implementation could be analyzing this specific topics to understand more about possible concentrated problems, for example topic 5 is related to shipping, this way we can know more details about the products delivery.


