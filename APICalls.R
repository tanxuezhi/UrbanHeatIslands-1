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
  # If it fails due to ratelimiting, try again after a second
  if ("status" %in% names(json)) {
    Sys.sleep(1)
    request <- GET(url, add_headers(token=authToken))
    json <- content(request, as="text")
  }
  if (validate(json)) {
    json <- fromJSON(json)
    return(data.frame(json$results))
  } else {
    return(data.frame(datatype = "ERROR"))
  }
}
# Get temperature data from the climate bureau API
getTempData <- function(station, year) {
  url <- paste("data?datasetid=GHCND&startdate=", year, "-01-01&enddate=",
               year, "-12-31&stationid=", station, 
               "&datatypeid=TMAX,TMIN&limit=730", sep="")
  data <- getClimateData(url)
  # Make a dummy datastructure to allow for seamless integration
  if (!("value" %in% names(data))) {
    data <- data.frame(date = paste(year,"-00-00",sep=""),
                       datatype = "ERROR",
                       station = station,
                       attributes = "NULL",
                       value = 0)
  }
  return(data)
}

# Get data from the census API
getCensusData <- function(url) {
  authToken <- "67671962d899413a75eed4bffb25e957458a750b"
  urlPrefix <- "https://api.census.gov/data/"
  urlPostfix <- paste("&key=", authToken, sep="")
  url <- paste(urlPrefix, url, urlPostfix, sep="")
  request <- GET(url)
  if (status_code(request) == 200) {
    json <- content(request, as="text")
    return(fromJSON(json))
  } else {
    return(NA)
  }  
}

# Grab census population data for counties in states
censusPop <- function(county, state, baseUrl) {
  results <- getCensusData(paste(baseUrl, county, "&in=state:", state, sep=""))
  if(!is.na(results)) {
    return(results[2,1])
  } else {
    return(NA)
  }
}