library(reshape2)

## Source data URL
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


## Check if source data already exists. Else Download
if(!file.exists("./data")){ dir.create("./data") }
if(!file.exists("./data/get_humanActivityData.zip")){ download.file(fileURL,"./data/get_humanActivityData.zip") }

## Change WD to "./data"
setwd("./data")

## Check if unzipped data exists. Else extract
if(!file.exists("UCI HAR Dataset")) { unzip("./get_humanActivityData.zip") } 

## Begin Section - Merging Training and Test data
## Load labels and features

featuresData <- read.table("./UCI HAR Dataset/features.txt")

## Begin section to extract only the measurements on the mean and standard deviation for each measurement
## Corresponding search strings - mean and std

requiredFeatures <- grep("*.mean*|*.std*",featuresData[,2])
requiredFeatures.names <- featuresData[requiredFeatures,2]
requiredFeatures.names <- gsub('-mean','Mean',requiredFeatures.names)
requiredFeatures.names <- gsub('-std','Std',requiredFeatures.names)
requiredFeatures.names <- gsub('[-()]',"",requiredFeatures.names)

## Load datasets - Train

trainingDataset <- read.table("./UCI HAR Dataset/train/X_train.txt")[requiredFeatures]
trainingActivities <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainingDataset <- cbind(trainingActivities,trainingSubjects,trainingDataset)

## Load datasets - Test
testDataset <- read.table("./UCI HAR Dataset/test/X_test.txt")[requiredFeatures]
testActivities <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testDataset <- cbind(testActivities,testSubjects,testDataset)

## Merging dataset
finalDataset <- rbind(trainingDataset,testDataset)
colnames(finalDataset) <- c("Subject","Activity",requiredFeatures.names)

## Create a second, independent tidy data set with the average of each variable for each activity and each subject
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")

cleanData <- melt(finalDataset, id = c("Subject","Activity"))
cleanData <- dcast(cleanData, Subject + Activity ~ variable, mean)

## Write final Data
write.table(cleanData,"./clean_data.txt", row.names = FALSE, quote = FALSE)