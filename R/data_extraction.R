

# Packages ----
library(tidyverse)
library(opendatatoronto)
library(bigrquery)
library(lubridate)
library(janitor)
library(here)
library(DBI)


# Working Dir ----
setwd(here::here("R"))


# Data Extraction ----
info <- show_package("21c83b32-d5a8-4106-a54f-010dbe49f6f2") %>% 
    list_package_resources() %>% 
    filter(str_to_lower(format) %in% c("csv", "geojson")) %>% 
    filter(! is.na(last_modified)) %>% 
    arrange(desc(last_modified)) %>% 
    mutate(last_modified_year = lubridate::year(last_modified)) %>% 
    filter(last_modified_year == 2024) %>%
    arrange(desc(last_modified)) %>% 
    slice(1) 

sample_data_tbl <- info %>% 
    get_resource() %>% 
    janitor::clean_names() %>%
    filter(organization_id %in% c(24, 14)) %>% 
    mutate(timestamp = lubridate::now())


# Data Upload to BigQuery ----

# * Con ----
bigrquery::bq_auth(path = "../credentials.json")


bq_conn <- bigrquery::dbConnect(
    bigrquery::bigquery(),
    project = "chromatic-tree-410802",
    dataset = "schedule_test_r",
    billing = "chromatic-tree-410802"
)

# * Upload Job ----

job <- bq_perform_upload(
    x = bq_table("chromatic-tree-410802", "schedule_test_r", "sample_data"),
    values            = sample_data_tbl,
    write_disposition = "WRITE_APPEND", 
    quiet             = FALSE
    #fields = list(column1 = bq_field(type = "string"), column2 = bq_field(type = "integer"))
)


# Functions ----
get_data_extraction <- function() {
    
    # Data Extraction ----
    info <- show_package("21c83b32-d5a8-4106-a54f-010dbe49f6f2") %>% 
        list_package_resources() %>% 
        filter(str_to_lower(format) %in% c("csv", "geojson")) %>% 
        filter(! is.na(last_modified)) %>% 
        arrange(desc(last_modified)) %>% 
        mutate(last_modified_year = lubridate::year(last_modified)) %>% 
        filter(last_modified_year == 2024) %>%
        arrange(desc(last_modified)) %>% 
        slice(1) 
    
    sample_data_tbl <- info %>% 
        get_resource() %>% 
        janitor::clean_names() %>%
        filter(organization_id %in% c(24, 14)) %>% 
        mutate(timestamp = lubridate::now())
    
    message("Data Extracted!")
    return(sample_data_tbl)
    
}

get_data_upload <- function() {
    
    # Data Upload to BigQuery ----
    
    # * Con ----
    bigrquery::bq_auth(path = "../credentials.json")
    
    
    bq_conn <- bigrquery::dbConnect(
        bigrquery::bigquery(),
        project = "chromatic-tree-410802",
        dataset = "schedule_test_r",
        billing = "chromatic-tree-410802"
    )
    
    # * Upload Job ----
    
    job <- bq_perform_upload(
        x = bq_table("chromatic-tree-410802", "schedule_test_r", "sample_data"),
        values            = sample_data_tbl,
        write_disposition = "WRITE_APPEND", 
        quiet             = FALSE
        #fields = list(column1 = bq_field(type = "string"), column2 = bq_field(type = "integer"))
    )
    
    message("Data Uploaded to BigQuery!")
    
    return(job)
    
}

get_data_upload()


dump(
    list = c("get_data_extraction", "get_data_upload"),
    file = "../R_prod/function_data_extraction.R",
    append = FALSE
)
