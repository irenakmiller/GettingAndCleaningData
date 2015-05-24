##  Getting and Cleaning Data - Course Project
##  May 2015

library(dplyr)
library(data.table)


##  Requirements
## 1. Merge the training and the test sets to create one data set.
## 2. Extract only the measurements on the mean and std deviation for each measurement.
## 3. Use descriptive activity names to name the activities in the data set.
## 4. Appropriately label the data set with descriptive variable names.
## 5. From data in step 4, create a second, independent tidy day set with the average of each variable for each activity and each subject.

##  Read Training data into tables
trainSubject <- read.table("~/UCI HAR Dataset/train/subject_train.txt")
trainActivity <- read.table("~/UCI HAR Dataset/train/y_train.txt")
trainFeatures <- read.table("~/UCI HAR Dataset/train/X_train.txt")



##  Read Test data into tables
testSubject <- read.table("~/UCI HAR Dataset/test/subject_test.txt")
testActivity <- read.table("~/UCI HAR Dataset/test/y_test.txt")
testFeatures <- read.table("~/UCI HAR Dataset/test/X_test.txt")


## Merge Training and Test data by rows
subject <- rbind(trainSubject, testSubject)
activity <- rbind(trainActivity, testActivity)
features <- rbind(trainFeatures, testFeatures)

## Label the data set with appropriate headers.
featureNames <- read.table("~/UCI HAR Dataset/features.txt")
colnames(features) <- t(featureNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"

##  Merge features, activity, and subject by columns to create one big table/dataset
mergedData <- cbind(features, activity, subject)

##  Extract only the measurements on the mean and std deviation for each measurement.
##  Use grep() to search for column indices matches to arguments passed - *mean* and *std*
colsStdMean <- grep(".*Mean.*|.*Std.*", names(mergedData), ignore.case=TRUE)

##  Now add back in activity and subject columns to match the mean and std columns
colsNeeded <- c(colsStdMean, 562, 563)

##  Create a new subset of data that only includes the needed columns
subsetData <- mergedData[, colsNeeded]


##  Add activity label names in place of numeric value
##  Change variable type from int to character
subsetData$Activity <- as.character(subsetData$Activity)

##  Loop through the activity labels file, match numeric value to label, and replace.
activityLabels <- read.table("~/UCI HAR Dataset/activity_labels.txt")

for (i in 1:6) {
        
        subsetData$Activity[subsetData$Activity == i] <- as.character(activityLabels[i,2])
        
}

##  Return activity's class to its original state - factor
subsetData$Activity <- as.factor(subsetData$Activity)

##  Appropriately label the data set with descriptive variable names.
names(subsetData) <- gsub("-mean()", "Mean", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("-std()", "STD", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("-Freq()", "Frequency", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Acc", "Accelerometer", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Gyro", "Gyroscope", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("^t", "Time", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("^f", "Frequency", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("Mag", "Magnitude", names(subsetData), ignore.case = TRUE)
names(subsetData) <- gsub("BodyBody", "Body", names(subsetData), ignore.case = TRUE)




## The "subject" column is currently a data frame.  Change it to a factor.
subsetData$Subject <- as.factor(subsetData$Subject)
## Change subsetData from data.frame to table
subsetData <- data.table(subsetData)


##  Create a second, independent tidy day set with the average of each variable for each activity and each subject.
tidyData <- aggregate(. ~Subject + Activity, subsetData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)


