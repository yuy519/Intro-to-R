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
## "yellow-tripdata_2017-06.csv" from link on intro-to-r.com
## and store it in working directory for this project.
getwd()


# Also, edit the .gitignore file (if necessary) to exclude
# *.csv and *.RData files from being synced by Git. 
file.edit(".gitignore")

# Importing the file and measuring how long the import takes
ptm <- proc.time()
DF.CSV <- read.csv("yellow_tripdata_2017-06.csv")
CSV_READ_TIME <- (proc.time() - ptm)
CSV_READ_TIME

# Looking at what we got
class(DF.CSV)
typeof(DF.CSV)
str(DF.CSV)


## Reading in our csv file using fread() from package data.table 
# Installing data.table (if required) and loading it into memory
if (!require("data.table")) install.packages("data.table")
library("data.table")

#Checking and setting number of cpu threads
getDTthreads()
setDTthreads(0)
getDTthreads()

# Doing a timed read of the same file
ptm <- proc.time()
DF.FREAD <- fread("yellow_tripdata_2017-06.csv", header="auto",
                  data.table=FALSE)
FREAD_READ_TIME <- (proc.time() - ptm)
FREAD_READ_TIME

# Examining what we got
class(DF.FREAD)
typeof(DF.FREAD)
str(DF.FREAD)
names(DF.FREAD)

# Bringing in column headers as names and using them to set names
ptm <- proc.time()
header <- read.table("yellow_tripdata_2017-06.csv", header = TRUE,
                     sep=",", nrow = 1)
DF.FREAD <- fread("yellow_tripdata_2017-06.csv", skip=1, sep=",",
                  header=FALSE, data.table=FALSE)
setnames(DF.FREAD, colnames(header))
FREAD_READ_TIME <- (proc.time() - ptm)
FREAD_READ_TIME

# Examining what we got again
class(DF.FREAD)
typeof(DF.FREAD)
str(DF.FREAD)
names(DF.FREAD)

# Examing the effects of multithreading
for(i in 1:16) {
  setDTthreads(i)
  print(getDTthreads())
  ptm <- proc.time()
  header <- read.table("yellow_tripdata_2017-06.csv", header = TRUE,
                       sep=",", nrow = 1)
  DF.FREAD <- fread("yellow_tripdata_2017-06.csv", skip=1, sep=",",
                    header=FALSE, data.table=FALSE,
                    showProgress=FALSE)
  setnames(DF.FREAD, colnames(header))
  print(proc.time() - ptm)
  gc()
}
FREAD_MP_TIME


# But data.table is not the only game in town...
# What about package readr?

# Installing readr (if required) and loading it into memory
if (!require("readr")) install.packages("readr")
library("readr")

# A timed example of readr::read_csv()
ptm <- proc.time()
DF.READR <- read_csv("yellow_tripdata_2017-06.csv", col_names=TRUE)
READR_READ_TIME <- (proc.time() - ptm)
READR_READ_TIME
CSV_READ_TIME
FREAD_READ_TIME

class(DF.READR)
typeof(DF.READR)
str(DF.READR)
names(DF.READR)

# We've picked a winner: let's run with it. 
rm(list=ls(all=TRUE))
cat("\014")

header <- read.table("yellow_tripdata_2017-06.csv", header = TRUE,
                     sep=",", nrow = 1)
Yellow_Tripdata_2017_06 <- fread("yellow_tripdata_2017-06.csv",
                                 skip=1, sep=",",header=FALSE,
                                 data.table=FALSE)
setnames(Yellow_Tripdata_2017_06, colnames(header))
rm(header)

View(Yellow_Tripdata_2017_06)
str(Yellow_Tripdata_2017_06)

head(Yellow_Tripdata_2017_06)
head(Yellow_Tripdata_2017_06$trip_distance)

summary(Yellow_Tripdata_2017_06)
summary(Yellow_Tripdata_2017_06 $ trip_distance)
#
# Throwing out absurdly long trips
d2<-Yellow_Tripdata_2017_06[which(Yellow_Tripdata_2017_06$trip_distance<1000),]
str(d2)
summary(d2 $ trip_distance)

# Using data.table:fwrite()to save d2 as csv:
fwrite(d2,"ds.csv")

# Let's save our "original" data frame for the next module...

save(Yellow_Tripdata_2017_06,file="Yellow_Tripdata_2017_06.RData")
RDATA_WRITE_TIME <- proc.time() - ptm
