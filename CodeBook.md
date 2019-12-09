# Week 4 assignment code book

Describes the data and the transformations applied to that data.

There is only one script involved in the tranformation: [`run_analysis.R`](run_analysis.R)

## `run_analysis` tranformations

### Script setup
Download data zip file and unzip.
Ensure that we don't duplicate effort by checking to see if this has previously been done.

### Part 1. Merge train and test data
We are using the dplyr package and functionality for this one.
Create data tables for training and test data for:
- measurements
- activity type
- subject

Datatables are:
- train_data
- train_activity
- train_subject
- test_data
- test_activity
- test_subject

After these datatables have been created, we will merge them using bind_rows
Combined datatables are:
- activity_data
- activity_type
- subject

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


