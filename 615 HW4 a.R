# Required libraries
library(data.table)
library(lubridate)

# Function to load data for a single year
load_buoy_data <- function(year) {
  file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
  tail <- ".txt.gz&dir=data/historical/stdmet/"
  path <- paste0(file_root, year, tail)
  
  # Read header and determine if we should skip 1 or 2 lines based on the presence of units
  header <- scan(path, what = 'character', nlines = 1)
  
  if (year < 2000) {
    # Years before 2000 likely have no units, skip 1 line
    buoy <- fread(path, header = FALSE, skip = 1,fill=Inf)
  } else {
    # Years after 2000 likely have units, skip 2 lines
    buoy <- fread(path, header = FALSE, skip = 2,fill=Inf)
  }
  
  # Set the column names from the header
  colnames(buoy) <- header
  
  # Create a proper date column using lubridate (assuming Date components are available)
  # You may need to modify this depending on the actual format of the date columns
  if (all(c("YYYY", "MM", "DD", "hh", "mm") %in% header)) {
    buoy$Date <- make_datetime(buoy$YYYY, buoy$MM, buoy$DD, buoy$hh, buoy$mm)
  } else if (all(c("Year", "Month", "Day", "Hour", "Minute") %in% header)) {
    buoy$Date <- make_datetime(buoy$Year, buoy$Month, buoy$Day, buoy$Hour, buoy$Minute)
  }
  
  return(buoy)
}

# Loop over years 1985 to 2023 and load the data for each year
all_years_data <- lapply(1985:2023, function(year) {
  tryCatch({
    load_buoy_data(year)
  }, error = function(e) {
    message(paste("Error loading data for year", year, ":", e))
    NULL
  })
})

# Combine all the datasets into one data table, removing any NULL entries
all_years_data <- rbindlist(all_years_data, use.names = TRUE, fill = TRUE)

# Show a glimpse of the data
print(head(all_years_data))

