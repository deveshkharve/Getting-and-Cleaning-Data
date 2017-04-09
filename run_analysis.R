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

#read the test and traing DataSet
#read values for Test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featReq]
#read test activites from dataset
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
#read all the subject data
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
#bind all the test data
test <- cbind(testSubjects, testActivities, test)

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featReq]
#read test activites from dataset
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
#read all the subject data
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
#bind all the train data
train <- cbind(trainSubjects, trainActivities, train)

# merge datasets and add labels
allData <- rbind(train, test)
#add column names for subject and activity columns 
colnames(allData) <- c("subject", "activity", featReq.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

#convert all the data for subject and activity column
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

#save allData into txt file
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
