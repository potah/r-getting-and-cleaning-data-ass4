# Week 4 assignment code book

Describes the data and the transformations applied to that data.

There is only one script involved in the tranformation: [`run_analysis.R`](run_analysis.R)

## `run_analysis` tranformations

### Function definition and package install and load
Definition of the following utility functions:
- checkPackages
  - check and install passed in package vector if required
- downloadAndExtract
  - download and extract data file if required
- dataFilePath
  - utility to create the test or train data file name
- loadTibble
  - load a tibble from a provided file path
- loadTibbleFromExtractDir
  - load a tibble from the extracted data directory
- loadTestOrTrain
  - load a test or training data tibble
- getLoadTestOrTrainFunc
  - returns a function which can be used to load a test or train tibble
- getFeatures
  - returns a prettified features tibble
- getActivityLabels
  - return a tibble of the activity labels
- activityLabelFromId (unused)
  - unused function

### Script setup
Setup:
- data names
- local extract directory name
- download and extract data file
- load the testing and training data tables

Training datatables are:
- trainData: 7352 x 561
  - 7352 rows of measurement data
- trainActivity: 7352 x 1
  - specified activity id for each training row
- trainSubject: 7352 x 1
  - specified subject id for each training row

Testing datatables are:
- testData: 2947 x 561
  - 2947 rows of measurement data
- testActivity: 2947 x 1
  - specified activity id for each test row
- testSubject: 2947 x 1
  - specified subject id for each test row

### Part 1. Merge train and test data
Combine test and training data using `bind_rows` function.
- `activityData`: 10299 x 561
  - combined trainData and testData
- `activityType`: 10299 x 1
  - combined trainActivity and testActivity
- `subject`: 10299 x 1
  - combined trainSubject and testSubject


### Part 2. Extract mean and std. deviation columns
We clean up the column names and extract only this which are mean and std. deviation.

The resulting dataset is:
- mean_and_std_activities

### Part 3. Apply the descriptive activity names to the activity
The script then produces a list of activity names which match the rows of the activity_data / mean_and_std_activities.

The activity names dataframe produced is:
- activity_type_labels_df

### Part 4. Use the descriptive activity names with the combined mean and std. dataset
Add the descriptive activity names to our data.
We use bind_cols.

The resulting datatable is:
- activities

### Part 5. Summarize mean and std. deviation by activity
We will take advantage of dplyr group_by to summarize by activity_name.

the resulting datatable is:
- mean_by_activity_type

This has 6 rows as per the activity_name and columns are the mean of the values for these activities.


