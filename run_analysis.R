# Getting and Cleaning Data Project John Hopkins Coursera
# You should create one R script called run_analysis.R that does the following.

# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second,
#   independent tidy data set with the average of each variable for each activity and each subject.

# author : RAJAT KUMAR


library(data.table)
library(reshape2)
#creating a directory and downloading a file 
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("Module_3_Project")){dir.create("./Module_3_Project")}
download.file(Url, destfile = "./Module_3_Project/data", method = "curl")
unzip("./Module_3_Project/data")
setwd("./UCI HAR Dataset")

# Activity Labels
activitylabels <- fread("activity_labels.txt", header = F, sep = " ",col.names = c("activityclass", "activityname"))
features <- fread("features.txt", header = F,sep = " ", col.names = c("index", "feature"))
featuresrequired <- grep("(mean|std)\\(\\)", features[ , feature])
measurements <- features[featuresrequired, feature]
measurements <- gsub("[()]", "", measurements)

# cleaning the train data set
traindata <- fread("train/X_train.txt", header = F, sep = " ", col.names = features$feature)
traindata <- traindata[,featuresrequired, with = F]
names(traindata) <- measurements
trainactivities <- fread("train/y_train.txt", header = F, sep = " ", col.names = "activity")
trainsubject <- fread("train/subject_train.txt", header = F, sep = " ", col.names = "subjectnumber" )
train <- cbind(trainsubject,trainactivities,traindata)

#cleaning the test data set
testdata <- fread("test/X_test.txt", header = F, sep = " ", col.names = features$feature)
testdata <- testdata[, featuresrequired, with = F]
names(testdata) <- measurements
testactivities <-fread("test/y_test.txt", header = F, sep = " ", col.names = "activity")
testsubject <- fread("test/subject_test.txt", header = F, sep = " ", col.names = "subjectnumber" )
test <- cbind(testsubject,testactivities,testdata)

#merging the test and train dataset 
dataset <- rbind(train,test)

#changing the class type of the variables subjectnumber and activity
dataset[,"subjectnumber"] <- sapply(dataset[,"subjectnumber"], as.factor)
dataset[["activity"]] <- factor(dataset[, activity]
                                 , levels = activitylabels[["activityclass"]]
                                 , labels = activitylabels[["activityname"]])

#Grouping by the subjectnuberwise and activitywise mean     
dataset <- melt(data = dataset, id = c("subjectnumber", "activity"))
dataset <- dcast(data = dataset, subjectnumber + activity ~ variable, fun.aggregate = mean)
fwrite(x = dataset, file = "tidyData.csv", quote = FALSE)
