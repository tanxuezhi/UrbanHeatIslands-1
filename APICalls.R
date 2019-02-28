### Packages ###
library(jsonlite)
library(httr)

### Functions ###
# Get data from the climate bureau API
getClimateData <- function(url) {
  authToken <- "XMsfwcICOajIgIeFdsYuYJnkxuWIrBKk"
  urlPrefix <- "https://www.ncdc.noaa.gov/cdo-web/api/v2/"
  url <- paste(urlPrefix, url, sep="")
  request <- GET(url, add_headers(token=authToken))
  json <- content(request, as="text")
  json <- fromJSON(json)
  # If it fails due to ratelimiting, try again after a second
  if ("status" %in% names(json)) {
    Sys.sleep(1)
    request <- GET(url, add_headers(token=authToken))
    json <- content(request, as="text")
    json <- fromJSON(json)
  }
  return(data.frame(json$results))
}

# Get data from the census API
getCensusData <- function(url) {
  authToken <- "67671962d899413a75eed4bffb25e957458a750b"
  urlPrefix <- "https://api.census.gov/data/"
  urlPostfix <- paste("&key=", authToken, sep="")
  url <- paste(urlPrefix, url, urlPostfix, sep="")
  request <- GET(url)
  json <- content(request, as="text")
  return(fromJSON(json))
}

# Grab climate data of one type
getDataType <- function(data, type) {
  data <- data$results
  return(data[data$datatype == type,])
}