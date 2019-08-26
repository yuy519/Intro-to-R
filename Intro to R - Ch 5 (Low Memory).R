############################################################
# R script to accompany Intro to R for Business, Chapter 5 #
# Written by Troy Adair                                    #
############################################################

## Going to be reading in a lot of data, so let's empty Environment
## and clean up Console
# Clean Up 
rm(list=ls(all=TRUE))
cat("\014") 

## Reading in external data
## Prior to attempting this section, download file
## "Yellow_Sample.csv" from the link on intro-to-r.com
## and store it in working directory for this project.
getwd()


# Also, edit the .gitignore file (if necessary) to exclude
# *.csv and *.RData files from being synced by Git. 
file.edit(".gitignore")

# Importing the file and measuring how long the import takes
ptm <- proc.time()
DF <- read.csv("Yellow_Sample.csv")
CSV_READ_TIME <- (proc.time() - ptm)
CSV_READ_TIME

# Looking at what we got
class(DF)
typeof(DF)
str(DF)


## Reading in our csv file using fread() from package data.table 
# Installing data.table (if required) and loading it into memory
if (!require("data.table")) install.packages("data.table")
library("data.table")

#Checking and setting number of cpu threads
getDTthreads()
getDTthreads(verbose=TRUE)
setDTthreads(0)
getDTthreads()

# Doing a timed read of the same file
ptm <- proc.time()
DF <- fread("Yellow_Sample.csv", header="auto", 
            data.table=FALSE)
FREAD_READ_TIME <- (proc.time() - ptm)
FREAD_READ_TIME

# Examining what we got
class(DF)
typeof(DF)
str(DF)
names(DF)

# Bringing in column headers as names and using them to set names
ptm <- proc.time()
header <- read.table("Yellow_Sample.csv", header = TRUE,
                     sep=",", nrow = 1)
DF <- fread("Yellow_Sample.csv", skip=1, sep=",",
                  header=FALSE, data.table=FALSE)
setnames(DF, colnames(header))
rm(header)
FREAD_READ_TIME <- (proc.time() - ptm)
FREAD_READ_TIME

# Examining what we got again
class(DF)
typeof(DF)
str(DF)
names(DF)

# Examing the effects of multithreading
for(i in 1:getDTthreads()) {
  setDTthreads(i)
  print(getDTthreads())
  ptm <- proc.time()
  header <- read.table("Yellow_Sample.csv", header = TRUE,
                       sep=",", nrow = 1)
  DF <- fread("Yellow_Sample.csv", skip=1, sep=",",
              header=FALSE, data.table=FALSE,
              showProgress=FALSE)
  setnames(DF, colnames(header))
  rm(header)
  print(proc.time() - ptm)
  gc()
}

# But data.table is not the only game in town...
# What about package readr?

# Installing readr (if required) and loading it into memory
if (!require("readr")) install.packages("readr")
library("readr")

# A timed example of readr::read_csv()
ptm <- proc.time()
DF <- read_csv("Yellow_Sample.csv", col_names=TRUE)
READR_READ_TIME <- (proc.time() - ptm)
READR_READ_TIME
CSV_READ_TIME
FREAD_READ_TIME

class(DF)
typeof(DF)
str(DF)
names(DF)

# We've picked a winner: let's run with it. 
rm(list=ls(all=TRUE))
cat("\014")

header <- read.table("Yellow_Sample.csv", header = TRUE,
                     sep=",", nrow = 1)
Yellow_Tripdata_2017_06 <- fread("Yellow_Sample.csv",
                                 skip=1, sep=",",header=FALSE,
                                 data.table=FALSE)
setnames(Yellow_Tripdata_2017_06, colnames(header))
rm(header)

# Looking at our data
View(Yellow_Tripdata_2017_06)
str(Yellow_Tripdata_2017_06)

# Using head()
head(Yellow_Tripdata_2017_06)
head(Yellow_Tripdata_2017_06, n=3)
head(Yellow_Tripdata_2017_06$trip_distance, n=10)
head(Yellow_Tripdata_2017_06[4:5])

# Using summary()
summary(Yellow_Tripdata_2017_06)
summary(Yellow_Tripdata_2017_06 $ trip_distance)
#
# Throwing out "non-fares"
d2<-Yellow_Tripdata_2017_06[which(
  Yellow_Tripdata_2017_06$fare_amount>=0 & 
  Yellow_Tripdata_2017_06$fare_amount<100000),]
summary(d2 $ fare_amount)

# Constraining passenger_count to = 1 or 2
d3<-Yellow_Tripdata_2017_06[which(
  Yellow_Tripdata_2017_06$passenger_count==1 | 
    Yellow_Tripdata_2017_06$passenger_count==2),]
summary(d3 $ passenger_count)

# Using data.table:fwrite()to save d3 as csv:
fwrite(d3,"d3.csv")

# Let's save our "original" data frame for the next module...
save(Yellow_Tripdata_2017_06,file="Yellow_Tripdata_2017_06.RData")
