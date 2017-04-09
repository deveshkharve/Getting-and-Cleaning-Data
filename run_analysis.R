#load libraries
library(dplyr)
library(data.table)
library(reshape2)

filename<- "dataset.zip"

#download file
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

#set as values as characters
activityLabels[,2] <- as.character(activityLabels[,2])
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featReq <- grep(".*mean.*|.*std.*", features[,2])
featReq.names <- features[featReq,2]

# expand abbreviations and clean up names
featReq.names <- gsub('[-()]', '', featReq.names)
featReq.names <- gsub("^f", "frequencyDomain", featReq.names)
featReq.names <- gsub("^t", "timeDomain", featReq.names)
featReq.names <- gsub("Acc", "Accelerometer", featReq.names)
featReq.names <- gsub("Gyro", "Gyroscope", featReq.names)
featReq.names <- gsub("Mag", "Magnitude", featReq.names)
featReq.names <- gsub("Freq", "Frequency", featReq.names)
featReq.names <- gsub("mean", "Mean", featReq.names)
featReq.names <- gsub("std", "StandardDeviation", featReq.names)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featReq]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featReq]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featReq.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
