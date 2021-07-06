### Cyclistic_Exercise_Full_Year_Analysis ###

# This analysis is for case study 1 from the Google Data Analytics Certificate (Cyclistic). 
# It is originally based on the case study "Sophisticated, Clear, and Polished": Divvy and Data Visualisation" written by Kevin Hartman.
# Source: https://divvy-tripdata.s3.amazonaws.com/index.html (Link from Google Data Analytics Certificate Case Study 1 (Cyclistic))
# The casestudy is based on Divvy dataset used from April 2020 to March 2021 with minor amendments made to the raw data to include more cleaning functions like removing additional columns.
# The purpose of the script is to explore the monthly data files before consolidating into a single dataframe and then conduct analysis to answer the key question.
# Key question: "In what ways do members and casual riders use Divvy bikes differently?" 


#===========
# Setting up
#===========

# Install required packages
# tidyverse for data import and wrangling
# ggplot2 for graph plotting
# janitor, skimr and dplyr for cleaning data

# Installing packages
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("janitor")
install.packages("skimr")
install.packages("dplyr")

# Calling out the library
library(tidyverse) 
library(lubridate)
library(ggplot2)
library(skimr)
library(janitor)
library(dplyr)

# Setting the working directory to the correct location
getwd() # To display the working directory
setwd("C:/Users/wilso/OneDrive/Desktop/Portfolio_Project/zR project files/Casestudy_capstone_R/Sample_CSV") # To set up the folder to make retrieving files easier

#===============================
# Step 1: Importing the datasets
#===============================

# Upload the Divvy datasets here (CSV formats)
apr_2020 <- read_csv("2020_04_tripdata.csv")
may_2020 <- read_csv("2020_05_tripdata.csv")
jun_2020 <- read_csv("2020_06_tripdata.csv")
jul_2020 <- read_csv("2020_07_tripdata.csv")
aug_2020 <- read_csv("2020_08_tripdata.csv")
sep_2020 <- read_csv("2020_09_tripdata.csv")
oct_2020 <- read_csv("2020_10_tripdata.csv")
nov_2020 <- read_csv("2020_11_tripdata.csv")
dec_2020 <- read_csv("2020_12_tripdata.csv")
jan_2021 <- read_csv("2021_01_tripdata.csv")
feb_2021 <- read_csv("2021_02_tripdata.csv")
mar_2021 <- read_csv("2021_03_tripdata.csv")

#====================================================
# Step 2: Wrangle data and combine into a single file
#====================================================

# Compare column names
colnames(apr_2020)
colnames(may_2020)
colnames(jun_2020)
colnames(jul_2020)
colnames(aug_2020)
colnames(sep_2020)
colnames(oct_2020)
colnames(nov_2020)
colnames(dec_2020)
colnames(jan_2021)
colnames(feb_2021)
colnames(mar_2021)

# Most of the column names are the same except for the last few columns.
# From apr 2020 to sep 2020, there is a column named "usertype".
# While from oct 2020 to mar 2021, there are 4 more columns named "member_casual", "ride_length", "day_of_week", "month_year".
# Check apr 2020 dataframe and oct 2020 dataframe to see the content of these columns to see which ones are meant to merge together. 

# Check apr 2020 specific column "usertype"
head(apr_2020$usertype)

# Check oct 2020 columns
head(oct_2020[c("member_casual","ride_length","day_of_week","month_year")])

# "usertype" returns member and casual
# "member_casual" return casual, "ride_length" return MM:SS format, "day_of_week" return single number and "month_year" return MMM-YY format
# usertype and member_casual returns similar output

# Rename "usertype" to "member_casual" so that it is standardise 
apr_2020 <- rename(apr_2020, member_casual = usertype)

# Check that the rename took place correctly
colnames(apr_2020)

# Rename the other files 
may_2020 <- rename(may_2020, member_casual = usertype)
jun_2020 <- rename(jun_2020, member_casual = usertype)
jul_2020 <- rename(jul_2020, member_casual = usertype)
aug_2020 <- rename(aug_2020, member_casual = usertype)
sep_2020 <- rename(sep_2020, member_casual = usertype)

# Inspect the dataframes
str(apr_2020)
str(may_2020)
str(jun_2020)
str(jul_2020)
str(aug_2020)
str(sep_2020)
str(oct_2020)
str(nov_2020)
str(dec_2020)
str(jan_2021)
str(feb_2021)
str(mar_2021)

# Convert ride_length from time format to character type to allow combining
mar_2021 <- mutate(mar_2021, ride_length = as.character(ride_length))
feb_2021 <- mutate(feb_2021, ride_length = as.character(ride_length))
jan_2021 <- mutate(jan_2021, ride_length = as.character(ride_length))
nov_2020 <- mutate(nov_2020, ride_length = as.character(ride_length))
oct_2020 <- mutate(oct_2020, ride_length = as.character(ride_length))

# Inspect to see the dataframe has been changed
str(mar_2021)

# Convert start_station_id and end_station_id from num to chr to allow combining
# From Apr 2020 to Nov 2020
apr_2020 <- mutate(apr_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
str(apr_2020)
may_2020 <- mutate(may_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
jun_2020 <- mutate(jun_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
jul_2020 <- mutate(jul_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
aug_2020 <- mutate(aug_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
sep_2020 <- mutate(sep_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
oct_2020 <- mutate(oct_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))
nov_2020 <- mutate(nov_2020, start_station_id = as.character(start_station_id), end_station_id = as.character(end_station_id))

# Stack individual dataframes into one big data frame
all_trips <- bind_rows(apr_2020, may_2020, jun_2020, jul_2020, aug_2020, sep_2020, oct_2020, nov_2020, dec_2020, jan_2021, feb_2021, mar_2021) 
                  
# Inspect the new dataframe
head(all_trips)
colnames(all_trips)
glimpse(all_trips)

# Remove columns that are not present in all the files: "ride_length", "day_of_week", "month_year"
all_trips <- select(all_trips, -c(ride_length, day_of_week, month_year))

# Inspect the dataframe again to ensure that the extra columns has been removed
glimpse(all_trips)

#======================================================
# Step 3: Clean up and add data to prepare for analysis
#======================================================

# Inspect the new table that has been created
colnames(all_trips) # List of column names
nrow(all_trips) # How many rows are in data frame?
dim(all_trips) # Dimensions of the data frame?
head(all_trips) # See the 6 rows of data frame.
str(all_trips) # See list of columns and data types (numeric, character, etc)
summary(all_trips) # Statistical summary of data. Mainly for numerics

glimpse(all_trips) # Summary of columns and datasets
skim_without_charts(all_trips) # Gives a detailed summary (Rows, columns, variable type)

# There are a few problems that need to be fixed:
# (1) Using skim_without_charts, it is observed that for member_casual have 4 unique values instead of 2 unique values ("member", "casual")
# (2) There is a need for additional columns of data -- such as day, month, year -- that provide additional opportunities to aggregate the data.
# (3) To have a calculated field for length of ride for the entire dataframe.

# Identify the unique values in the member_casual column 
unique(all_trips[c("member_casual")])

# Check the number of observations before reassigning
table(all_trips$member_casual)

# By using unique function, the 4 unique values are identified ("member", "casual", "customer", "subscriber")
# member and subscriber are meant to be the same while casual and customer are meant to be the same
# To replace the values in the column accordingly
all_trips <- mutate(all_trips, member_casual = recode(member_casual, "subscriber" = "member", "customer" = "casual"))

# Check the unique values again
unique(all_trips[c("member_casual")])

# Check to make sure the proper number of observations were reassigned
table(all_trips$member_casual)

# Add columns that list the data, month, day and year of each ride to allow analysis
# Add in the date column by converting the start date into date format 
all_trips$date <- as.POSIXct(all_trips$started_at, format = "%d/%m/%Y")

# Add in the month, day, year and which day column
all_trips$month <- format(all_trips$date,format = "%m")
all_trips$day <- format(all_trips$date,format = "%d")
all_trips$year <- format(all_trips$date,format = "%Y")
all_trips$day_of_week <- format(all_trips$date,format = "%A")

# Inspect the columns
glimpse(all_trips)

# Convert the started_at and ended_at into datetime format for the calculation
all_trips$started_at <- as.POSIXct(all_trips$started_at, format = "%d/%m/%Y %H:%M")
all_trips$ended_at <- as.POSIXct(all_trips$ended_at, format = "%d/%m/%Y %H:%M")

# Calculate the ride length by deducting the start time from end time
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at, units = "auto")

# Convert "ride_length" from factor to numeric to run calculations 
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)

# Quick check on the output 
max(all_trips$ride_length)
min(all_trips$ride_length)
str(all_trips)

# Inspect the ride lengths that are negative 
all_trips %>%
 select(started_at,ended_at,ride_length) %>%
 filter(ride_length < 0)

# Remove "bad" data 
# Removing the data where ride_length was negative and store into a dataframe
all_trips_v2 <- all_trips[!(all_trips$ride_length < 0),]

# Inspect the new dataframe for negative values in ride length 
all_trips_v2 %>%
 select(started_at,ended_at,ride_length) %>%
 filter(ride_length < 0)

# Inspect new dataframe
glimpse(all_trips_v2)

#=====================================
# Step 4: Conduct descriptive analysis
#=====================================

# Descriptive analysis on ride_length (all figures in seconds)
mean(all_trips_v2$ride_length)#straight average (total ride length/ rides)
median(all_trips_v2$ride_length) #midpoint number in the ascending array of ride lengths
max(all_trips_v2$ride_length)#longest ride
min(all_trips_v2$ride_length)#shortest ride

# Summary of different stats
summary(all_trips_v2$ride_length)

# Comparing members and casual users using different stats
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual, FUN = min)

# Generating the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Sort the days of the weeks into the correct order (Sunday until Saturday)
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels = c("Sunday","Monday", "Tuesday", "Wednesday", "Thursday",
"Friday", "Saturday"))

# Generating the average ride time by each day for members vs casual users (After sorting the days)
aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Analyse the ridership data by type and weekday
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%   # Creates temporary weekday field using wday() 
  group_by(member_casual, weekday) %>%                   # Groups by usertype and weekday
  summarise(number_of_rides = n()                        # Calculates the number of rides and average duration
            ,average_duration = mean(ride_length)) %>%   # Calculates the average duration
            arrange(member_casual, weekday)              # Sorts by member and by the weekday

# Visualise the number of rides by rider type
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>%
            arrange(member_casual, weekday)        %>%
            ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
            geom_col(position = "dodge")

# Visualise for average duration
all_trips_v2 %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>%
            arrange(member_casual, weekday)        %>%
            ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
            geom_col(position = "dodge")

#=================================================
# Step 5: Export Summary File for further analysis
#=================================================

# Create a csv file that can be used to visualise in other software
counts <- aggregate(all_trips_v2$ride_length~all_trips_v2$member_casual +
                    all_trips_v2$day_of_week, FUN = mean)
write.csv(counts, file = 'C:/Users/wilso/OneDrive/Desktop/avg_ride_length.csv')

































