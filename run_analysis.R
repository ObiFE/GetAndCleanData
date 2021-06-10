rm(list = ls())

#Download the file and save in the data folder

if(!file.exists("./data")){
  dir.create("./data")}

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./data/Dataset.zip", mode = "wb")

#Unzip the file
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

#The unzipped files are in the folder named UCI HAR Dataset. 
#Get the list of the files

#Construct the path to a file from components in a platform-independent way.

path <- file.path("./data", "UCI HAR Dataset")

#These function produce a character vector of the names of files or directories
#in the named directory.

files <- list.files(path, recursive = TRUE)
files

#Read data from the files into the variables

#Read the Activity files

ActivityTest  <- read.table(file.path(path, "test", "Y_test.txt"),
                                header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),
                                header = FALSE)

#Read the Subject files

SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),
                               header = FALSE)
SubjectTest  <- read.table(file.path(path, "test", "subject_test.txt"),
                               header = FALSE)

#Read Fearures files

FeaturesTest  <- read.table(file.path(path, "test", "X_test.txt"),
                                header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),
                                header = FALSE)

#Look at the properties of the six datasets
ls.str() 


#1. Merges the training and the test sets to create one data set
#Join the data tables by rows, on top of each other

Subject <- rbind(SubjectTrain, SubjectTest)
Activity <- rbind(ActivityTrain, ActivityTest)
Features <- rbind(FeaturesTrain, FeaturesTest)

sapply(list(Subject, Activity, Features), head, n = 2)

#set names to variables

library(dplyr)

Subject <- rename(Subject, subject = V1) 
Activity <- rename(Activity, activity = V1)

FeaturesNames <- read.table(file.path(path, "features.txt"), header = FALSE)

#Rename all the 561 columns in Features using the names in FeaturesNames

names(Features) <- FeaturesNames$V2

#Merge columns to get the data frame for all data

AllData <- cbind(Features, Subject, Activity)
head(AllData, 1)

#2. Extracts only the measurements on the mean and standard deviation for each 
#measurement.

SubAllData <- AllData %>% select(subject, activity, contains("mean"),
                                 contains("std"))
head(SubAllData, 2)
str(SubAllData)

#3. Uses descriptive activity names to name the activities in the data set

#Read descriptive activity names from "activity_labels.txt"

ActivityLabels <- read.table(file.path(path, "activity_labels.txt"),
                             header = FALSE)

SubAllData$activity <- ActivityLabels[SubAllData$activity, 2]
head(SubAllData$activity, 40)


#4. Appropriately labels the data set with descriptive variable names. 

names(SubAllData) <- gsub("^t", "Time", names(SubAllData))
names(SubAllData) <- gsub("^f", "Frequency", names(SubAllData))
names(SubAllData) <- gsub("Acc", "Accelerometer", names(SubAllData))
names(SubAllData) <- gsub("Gyro", "Gyroscope", names(SubAllData))
names(SubAllData) <- gsub("BodyBody", "Body", names(SubAllData))
names(SubAllData) <- gsub("Mag", "Magnitude", names(SubAllData))
names(SubAllData) <- gsub("tBody", "TimeBody", names(SubAllData))
names(SubAllData) <- gsub("-mean()", "Mean", names(SubAllData), 
                          ignore.case = TRUE)
names(SubAllData) <- gsub("-std()", "STD", names(SubAllData), 
                          ignore.case = TRUE)
names(SubAllData) <- gsub("-freq()", "Frequency", names(SubAllData), 
                          ignore.case = TRUE)
names(SubAllData) <- gsub("angle", "Angle", names(SubAllData))
names(SubAllData) <- gsub("gravity", "Gravity", names(SubAllData))

names(SubAllData)

#5. From the data set in step 4, creates a second, independent tidy data set
#with the average of each variable for each activity and each subject.

TidyData <- SubAllData %>% group_by(subject, activity) %>%
  summarise_all(funs(mean))

head(TidyData)

write.table(TidyData, "TidyData.txt", row.name = FALSE)

