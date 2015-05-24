
# Getting and Cleaning Data
## Course Project
May 2015

RStudio Version 0.98.1103 

Author:  Irena Miller

Contact Info:  https://github.com/irenakmiller

## Background
Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The linked data are collected from the accelerometers on the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 


### Source Dataset
The source dataset is from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.
 
### Requirements
Create an R script called run_analysis.R that does the following:

1. Merge the training and test sets (from the zip file above) to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement.
3. Use descriptive activity names to name the activities in the data set.
4. Appropriately label the data set with descriptive variable names.
5. From data in step 4, create a second, independent tidy day set with the average of each variable for each activity and each subject.

###  Files 
In this repository, you'll find:

*  run_analysis.R : the R-code run on the data set
*  Tidy.txt : the clean data extracted from the original data using run_analysis.R
*  CodeBook.md : the CodeBook reference to the variables in Tidy.txt
*  README.md : the analysis of the code in run_analysis.R

#  Getting Started
______

The R code in run_analysis.R proceeds under the assumption that the zip file available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip is downloaded and extracted into the R Home Directory.

##  Libraries Used
The libraries used in this operation are **dplyr** and **data.table**. *dplyr* is used to aggregate variables to create the tidy data.  *data.table* is efficient in handling large data as tables. 

```
library(dplyr)
library(data.table)
```

##  Format training and test data sets
__________

Training and test data sets are each split into 3 different .txt files that correspond to subject, activity, and features:  

###Training Data
* subject_train.txt - subject 
* y_train.txt - activity
* X_train.txt - features

###Test Data
* subject_test.txt - subject 
* y_test.txt - activity
* X_test.txt - features

### Read training data
```
trainSubject <- read.table("~/UCI HAR Dataset/train/subject_train.txt")
trainActivity <- read.table("~/UCI HAR Dataset/train/y_train.txt")
trainFeatures <- read.table("~/UCI HAR Dataset/train/X_train.txt")
```

### Read test data
```
testSubject <- read.table("~/UCI HAR Dataset/test/subject_test.txt")
testActivity <- read.table("~/UCI HAR Dataset/test/y_test.txt")
testFeatures <- read.table("~/UCI HAR Dataset/test/X_test.txt")
```

##Step 1. 
###Merge the training and test sets to create one data set.

Merge Training and Test data corresponding to subject, activitiy, and features, by rows using rbind.
```
subject <- rbind(trainSubject, testSubject)
activity <- rbind(trainActivity, testActivity)
features <- rbind(trainFeatures, testFeatures)
```

### Add appropriate Column Names

Read in variable names for features from features.txt.  Label activity and features columns with "Activity" and "Subject".

```
featureNames <- read.table("~/UCI HAR Dataset/features.txt")
colnames(features) <- t(featureNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
```

###  Merge features, activity, and subject by columns to create one big table/dataset

```
mergedData <- cbind(features, activity, subject)
```

##Step 2. 
###Extract only the measurements on the mean and standard deviation for each measurement.

Use grep() to search for column indices that match either *mean* or *std*
```
colsStdMean <- grep(".*Mean.*|.*Std.*", names(mergedData), ignore.case=TRUE)
```


Now add back in activity and subject columns to match the mean and std columns
```
colsNeeded <- c(colsStdMean, 562, 563)
```


Create a new subset of data that only includes the needed columns
```
subsetData <- mergedData[, colsNeeded]
```


##Step 3.
###Use descriptive activity names to name the activities in the data set.

Change variable type from int to character
```
subsetData$Activity <- as.character(subsetData$Activity)
```

Get activity labels
```
activityLabels <- read.table("~/UCI HAR Dataset/activity_labels.txt")
```

Loop through the activity labels file, match numeric value to label, and replace.
```
for (i in 1:6) {
        
        subsetData$Activity[subsetData$Activity == i] <- as.character(activityLabels[i,2])
        
}
```

Return activity's class to its original state - factor
```
subsetData$Activity <- as.factor(subsetData$Activity)
```

##Step 4.
###Appropriately label the data set with descriptive variable names.

The following acronyms can be replaced:

1.  **Acc** = Accelerometer
2.  **Gyro** = Gyroscope
3.  **^t** = Time
4.  **^f** = Frequency
5.  **Mag** = Magnitude



```
names(subsetData) <- gsub("-mean()", "Mean", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("-std()", "STD", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("-Freq()", "Frequency", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Acc", "Accelerometer", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Gyro", "Gyroscope", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("^t", "Time", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("^f", "Frequency", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Mag", "Magnitude", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("BodyBody", "Body", names(subsetData), ignore.case = TRUE)
```

##Step 5.
###From data in step 4, create a second, independent tidy day set with the average of each variable for each activity and each subject.

The "subject" column is currently a data frame.  Change it to a factor.
```
subsetData$Subject <- as.factor(subsetData$Subject)
```

Change subsetData from data.frame to table
```
subsetData <- data.table(subsetData)
```

Create a second, independent tidy day set with the average of each variable for each activity and each subject.
```
tidyData <- aggregate(. ~Subject + Activity, subsetData, mean)
```

Order the data according to subject, then activity
```
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
```

Write the data into the file *Tidy.txt*.
```
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
```




