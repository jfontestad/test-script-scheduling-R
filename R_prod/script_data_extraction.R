# Packages ----
library(tidyverse)
library(opendatatoronto)
library(bigrquery)
library(lubridate)
library(janitor)
library(here)
library(DBI)


# Working Dir ----
setwd(here::here("R_prod"))


# Source ----
source("function_data_extraction.R")


# Data Extraction ----
get_data_extraction() %>% 
    get_data_upload()
