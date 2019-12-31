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
# utility function to download and extract file
# do not change the working directory
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
              exdir = extractDir)
    }

    # return the combined directory
    unzipDir
}

#
# create helper functions for loading our tibbles
#
# return the name of a data file
dataFilePath <- function(dataType, testOrTrain) {
    paste(testOrTrain, 
          paste(dataType, "_", testOrTrain, ".txt", sep=""),
          sep = "/")
}

# function to return our standard tibble for a dataset
loadTibble <- function(filePath) {
    as.tbl(
        read.csv(
            filePath,
            sep="",
            header=FALSE,
            stringsAsFactors=FALSE))
}

# load a tibble from a file in our extract directory
loadTibbleFromExtractDir <- function(extractDir, fileName) {
    loadTibble(paste(extractDir, fileName, sep = "/"))
}

# function to return a tibble for a particular data file
loadTestOrTrain <- function(extractDir, dataType, testOrTrain) {
    loadTibbleFromExtractDir(extractDir, dataFilePath(dataType, testOrTrain))    
}

# use purrr::partial to return a func that doesn't need the 
# extractPath repeated in the function call
getLoadTestOrTrainFunc <- function(extractPath) {
    partial(loadTestOrTrain, extractDir = extractPath)
}

# utility func to return a features tibble that has nicer column names
getFeatures <- function(extractPath) {
    # We will create a function composition that we can use
    # in mutate to make the feature names nicer
    prettifyFeatureName <- compose(
        partial(gsub, pattern = "-|,", replacement = "_"),
        partial(gsub, pattern = "\\(|\\)", replacement = ""),
        partial(sub, pattern = "^f", replacement = "freq"),
        partial(sub, pattern = "^t", replacement = "time"))
    
    loadTibbleFromExtractDir(extractDir = extractPath, 
                             "features.txt") %>% 
        select(name = V2) %>%
        mutate(name = prettifyFeatureName(name))
}

# return a tibble of the activity labels
getActivityLabels <- function(extractPath) {
    activityLabels <- loadTibbleFromExtractDir(extractDir = extractPath,
                                               "activity_labels.txt")
    colnames(activityLabels) <-  c("id", "label")

    # return the tibble
    activityLabels
}


# unused
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
activityName <- "y"
subjectName <- "subject"

#
# download and extract our files
#
extractTo <- "data"
extractedFileDirectory <- downloadAndExtract(extractTo)

# get our tibble loader function
loadTestOrTrain <- getLoadTestOrTrainFunc(extractedFileDirectory)

# load the train data
trainData <- loadTestOrTrain(dataName, trainName)
trainActivity <- loadTestOrTrain(activityName, trainName)
trainSubject <- loadTestOrTrain(subjectName, trainName)

# load the test data
testData <- loadTestOrTrain(dataName, testName)
testActivity <- loadTestOrTrain(activityName, testName)
testSubject <- loadTestOrTrain(subjectName, testName)

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
colnames(activityData) <- features$name

# can't run the select below as we have duplicate column names
# meanAndStdActivities <- activityData %>%
#     select(matches("_mean_|_std_"))
whichMeanAndStdFeatures <- grep("_mean_|_std_", features$name)
meanAndStdActivities <- activityData[,whichMeanAndStdFeatures]

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

# make a tibble from our activity type labels
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
# Part 5.  Get the summary mean by activity and subject
#
meanByActivitySubject <-
    activities %>%
    group_by(activity_name, subject) %>%
    summarize_all(mean)

write.table(meanByActivitySubject, file = "tidy_data.txt", row.names = FALSE, quote = FALSE)
