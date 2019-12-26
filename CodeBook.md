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
  
Note that column headings for the data tables loaded so far are not meaningful.


### Part 2. Extract mean and standard deviation columns

We will use the `getFeatures` function to load a data table from the `features.txt` file included in the downloaded zip.

Resulting datatable is:
- `features`: 561 x 1
  - contains "pretty" names for each of the 561 measurements in the part 1. `activityData`
  - column name is `name`

Set the column names on the `activityData` datatable to the `features` data.

Create a new data table with only the mean and standard deviation measurements:
- `meanAndStdActivities`: 10299 x 48
  - only mean and standard deviation measurements for X,Y,Z axis for:
    - timeBodyAcc
    - timeGravityAcc
    - timeBodyAccJerk
    - timeBodyGyro
    - timeBodyGyroJerk
    - freqBodyAcc
    - freqBodyAccJerk
    - freqBodyGyro

### Part 3. Apply the descriptive activity names to the activity

We will use the `getActivityLabels` function to load a data table from the `activity_labels.txt` file included in the downloaded zip.

Resulting data table is:
- `activityLabelsTbl`: 6 x 2
  - column names: id, label
  
The column `activityLabelsTbl$label` is used to map the `activityType` data table from part 1 to have the activity names instead of the ids.

Resulting data table is:
- `activityType`: 10299 x 1
  - column name: activity_name

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


