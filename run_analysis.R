
library(dplyr)

#
# download the data
#
download_dir <- "data"

if (!dir.exists(download_dir)) {
    dir.create(download_dir)
}
# change to the download the data directory
setwd(download_dir)

data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data_file <- "dataset.zip"
if (!file.exists(data_file)) {
    download.file(url = data_url,
                  destfile = data_file,
                  mode = 'wb')
}

# we know that this is the directory name
# check if we have already unzipped
unzip_dir <- "UCI HAR Dataset"
if (!dir.exists(unzip_dir)) {
    unzip(data_file, exdir=".")
}
# change to our unzipped data directory
setwd(unzip_dir)

# setup our names
test_name <- "test"
train_name <- "train"
data_name <- "X"
activity_name <- "Y"
subject_name <- "subject"

#
# create a couple of helper functions for loading our tibbles
#
# note that this is expecting the current directory to
# be the root directory inside the unzipped data
data_path <- function(data_type, test_or_train) {
    file_name <- paste(data_type, "_", test_or_train, ".txt", sep="")

    paste(test_or_train, file_name, sep="/")
}

load_tibble <- function(data_type, test_or_train) {
    as.tbl(read.csv(data_path(data_type, test_or_train), sep="", header=FALSE, stringsAsFactors=FALSE))
}

# load the train data
train_data <- load_tibble(data_name, train_name)
train_activity <- load_tibble(activity_name, train_name)
train_subject <- load_tibble(subject_name, train_name)

# load the test data
test_data <- load_tibble(data_name, test_name)
test_activity <- load_tibble(activity_name, test_name)
test_subject <- load_tibble(subject_name, test_name)

#
# Part 1.  Merge the dataset
#
# combine the tables
activity_data <- bind_rows(train_data, test_data)
activity_type  <- bind_rows(train_activity, test_activity)
subject <- bind_rows(train_subject, test_subject)

# make everything a bit nicer
# get the feature names
features_file <- "features.txt"
features <- read.csv(features_file, sep="", header=FALSE, stringsAsFactors=FALSE)[,2]
features <- gsub("-", "_", features)
features <- gsub("\\(|\\)", "", features)
features <- gsub("^f", "freq", features)
features <- gsub("^t", "time", features)

#
# Part 2.  Extract the mean and std columns
#
# select the columns which are "mean" and "std"
which_mean_and_std_features <- grep("mean[^F]|std[^F]", features)
mean_and_std_features <- features[which_mean_and_std_features]
mean_and_std_activities <- activity_data[,which_mean_and_std_features]

# set the column names for the chosen columns
colnames(mean_and_std_activities) <- mean_and_std_features

# let's add in the activity names
activity_labels_file <- "activity_labels.txt"
activity_labels <- as.tbl(read.csv(activity_labels_file, sep="", header=FALSE, stringsAsFactors=FALSE))
colnames(activity_labels) <-  c("id", "label")

activity_label_from_id <- function(activity_id) {
    (activity_labels %>% filter(id == activity_id))$label
}

# should run install.packages("tidyverse")
# load the library to get the map functions
library(purrr)

# set the column name for our activity types to refer to it more easily
colnames(activity_type) <- c("id")

#
# Part 3.  Descriptive activity names
#
# make a data.frame from our activity type labels
# set the column heading to "activity_name"
activity_type_labels_df <- 
    data.frame(activity_name = map_chr(activity_type$id, activity_label_from_id))

#
# Part 4.  Add the descriptive names to the activity data table
#
# bind the activity labels as a column with the heading "activity_label"
# and set to a new data.table
activities <- bind_cols(mean_and_std_activities, as.tbl(activity_type_labels_df))

#
# Part 5.  Summarize by activity
#
mean_by_activity_type <- 
    group_by(activities, activity_name) %>%
    summarize_all(mean)


#write.table(activities, file = "tidy_data.txt", row.names = FALSE)
#write.table(mean_by_activity_type, file = "tidy_data_summary.txt", row.names = FALSE)
