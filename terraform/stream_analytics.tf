resource "azurerm_stream_analytics_job" "stream_analytics_job" {
  name                                     = "bde-stream-analytics-job"
  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 1

  transformation_query = <<QUERY
    SELECT asin
        , overall
        , reviewText
        , reviewerId
        , reviewerName
        , summary
        , EventEnqueuedUtcTime
        , verified
        , style
        , vote 
        , image
        , EventProcessedUtcTime
    INTO [eventhub-stream-output-amazon-reviews]
    FROM [eventhub-stream-input-amazon-reviews]
QUERY
}



resource "azurerm_stream_analytics_stream_input_eventhub_v2" "stream_input_amazon_reviews" {
  name                         = "eventhub-stream-input-amazon-reviews"
  stream_analytics_job_id      = azurerm_stream_analytics_job.stream_analytics_job.id
  servicebus_namespace         = "factored-datathon"
  eventhub_name                = "factored_datathon_amazon_reviews_2"
  eventhub_consumer_group_name = "brazil_data_engineering"
  shared_access_policy_key     = var.event_hub_sas_policy_key
  shared_access_policy_name    = "datathon_group_2"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_output_blob" "stream_output_amazon_reviews" {
  name                      = "eventhub-stream-output-amazon-reviews"
  stream_analytics_job_name = azurerm_stream_analytics_job.stream_analytics_job.name
  resource_group_name       = azurerm_stream_analytics_job.stream_analytics_job.resource_group_name
  storage_account_name      = azurerm_storage_account.lake.name
  storage_account_key       = azurerm_storage_account.lake.primary_access_key
  storage_container_name    = "default"
  path_pattern              = "amazon_reviews_streaming/{date}/{time}"
  date_format               = "yyyy-MM-dd"
  time_format               = "HH"
  batch_min_rows            = "1"
  batch_max_wait_time       = "00:02:00"

  serialization {
    type            = "Parquet"
  }
}