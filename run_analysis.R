#
# utility function to check and install packages
#
checkPackages <- function(packageNames) {
    # make sure we remove duplicates
    packageNames <- unique(packageNames)
    installedPackages <- installed.packages()[,1]

    #sapply(packageNames, getInstallPackageFunction())
    sapply(packageNames,
           function(pkg) {
               if (!is.element(pkg, installedPackages)) {
                   install.packages(pkg)
               }
               # use character.only for a character vector
               require(pkg,
                       character.only = TRUE,
                       warn.conflicts = FALSE,
                       quietly = TRUE)
           })
}


# make sure we have our needed packages installed
checkPackages(c("dplyr", "lubridate", "purrr"))

#
# download and extract file
# return the extract directory
#
downloadAndExtract <- function(extractDir) {
    if (!dir.exists(extractDir)) {
        dir.create(extractDir)
    }

    unzipDir <- paste(extractDir, "UCI HAR Dataset", sep = "/")
    
    if (!dir.exists(unzipDir)) {
        localZip <- paste(extractDir, "dataset.zip", sep = "/")
        
        if (!file.exists(localZip)) {
            url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        
            download.file(url = url,
                          destfile = localZip,
                          method = "auto",
                          quiet = T)
        }
        
        unzip(zipfile = localZip,
              exdir = unzipDir)
    }

    # return the combined directory
    unzipDir
}

#
# create a couple of helper functions for loading our tibbles
#
# note that this is expecting the current directory to
# be the root directory inside the unzipped data
dataPath <- function(baseDir, dataType, testOrTrain) {
    fileName <- paste(dataType, "_", testOrTrain, ".txt", sep="")

    paste(baseDir, testOrTrain, fileName, sep="/")
}

loadTibble <- function(baseDir, dataType, testOrTrain) {
    as.tbl(
        read.csv(
            dataPath(baseDir, dataType, testOrTrain), 
            sep="", 
            header=FALSE, 
            stringsAsFactors=FALSE))
}


getLoadTibbleFunc <- function(extractPath) {
    partial(loadTibble, baseDir = extractPath)
}

getFeatures <- function(extractPath) {
    features_file <- paste(extractPath, "features.txt", sep = "/")
    features <- read.csv(features_file, sep="", header=FALSE, stringsAsFactors=FALSE)[,2]
    features <- gsub("-", "_", features)
    features <- gsub("\\(|\\)", "", features)
    features <- gsub("^f", "freq", features)
    features <- gsub("^t", "time", features)
    
    features
}

getActivityLabels <- function(extractPath) {
    activityLabelsFile <- paste(extractPath, "activity_labels.txt", sep = "/")
    activityLabels <- as.tbl(read.csv(activityLabelsFile, sep="", header=FALSE, stringsAsFactors=FALSE))
    colnames(activityLabels) <-  c("id", "label")
    
    # return the tibble
    activityLabels
}

activityLabelFromId <- function(activity_id) {
    (activity_labels %>% filter(id == activity_id))$label
}

#
# setup section
#

# set our working directory to the extracted path
# setwd(extractedFileDirectory)

# we know the structure of our unzipped files
# setup our names
testName <- "test"
trainName <- "train"
dataName <- "X"
activityName <- "Y"
subjectName <- "subject"

#
# download and extract our files
#
extractTo <- "data"
extractedFileDirectory <- downloadAndExtract(extractTo)

# get our tibble loader function
loadTibbleFunc <- getLoadTibbleFunc(extractedFileDirectory)

# load the train data
trainData <- loadTibbleFunc(dataName, trainName)
trainActivity <- loadTibbleFunc(activityName, trainName)
trainSubject <- loadTibbleFunc(subjectName, trainName)

# load the test data
testData <- loadTibbleFunc(dataName, testName)
testActivity <- loadTibbleFunc(activityName, testName)
testSubject <- loadTibbleFunc(subjectName, testName)

#
# Part 1 start - merge the dataset
#
# combine the tables
activityData <- bind_rows(trainData, testData)
activityType  <- bind_rows(trainActivity, testActivity)
subject <- bind_rows(trainSubject, testSubject)
#
# Part 1 end


#
# Part 2 start - extract the mean and standard deviation columns
#

#
# get the feature names in a nicer format
#
features <- getFeatures(extractedFileDirectory)

# select the columns which are "mean" and "std"
whichMeanAndStdFeatures <- grep("mean_|std_", features)
meanAndStdFeatures <- features[whichMeanAndStdFeatures]
meanAndStdActivities <- activityData[,whichMeanAndStdFeatures]

# set the column names for the chosen columns
colnames(meanAndStdActivities) <- meanAndStdFeatures

#
# Part 2 end
#

#
# Part 3 start - descriptive activity names
#

# let's add in the activity names
activityLabelsTbl <- getActivityLabels(extractedFileDirectory)
activityLabels <- activityLabelsTbl$label

# set the column name for our activity types to refer to it more easily
colnames(activityType) <- c("id")

# make a data.frame from our activity type labels
# set the column heading to "activity_name"
activityType <- 
    as.tbl(
        data.frame(
            activity_name = map_chr(activityType$id, 
                                    function(activityId) {
                                        activityLabels[activityId]
                                    })))
#
# Part 3 end
#

#
# Part 4.  Add the descriptive names to the activity data table
#
# bind the activity labels as a column with the heading "activity_label"
# and set to a new data.table
# add the subject column with a heading of subject
activities <- bind_cols(meanAndStdActivities, activityType)
# make it a nice column name
colnames(subject) <- c("subject")
# add subject column to the end
activities <- bind_cols(activities, subject)

#
# Part 5.  Summarize by activity
#
summariseByActivitySubject <- 
    activities %>% 
    group_by(activity_name, subject) %>%
    summarize_all(mean)


#write.table(activities, file = "tidy_data.txt", row.names = FALSE)
#write.table(mean_by_activity_type, file = "tidy_data_summary.txt", row.names = FALSE)
