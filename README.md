# Getting and cleaning data - Week 4 assignment

This repository contains a script and associated codebook for the transformations and data.

# Relevant files

There are 2 other important files in this repository:
- [CodeBook.md](CodeBook.md)
- [run_analysis.R](run_analysis.R)

The main output of the run_analysis.R script will be to have in your global environment:
- activities data table
- mean_by_activity_type data table

The `activities` data table holds all the mean and standard deviation measurements of the training and test data combined.

The `mean_by_activity_type` data table holds the mean of the above `activities` data table summarized by the type of activity which has been labelled for the data.
