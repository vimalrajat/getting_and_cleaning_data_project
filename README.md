# getting_and_cleaning_data_project
Entire code is divided into seven parts which are :
1. creating a directory and downloading a file : uses the link and download.file fuction to download the file and setting the working        directory after the unzipping the file
2. Activity Labels which labesls the activity and subjectnumber : uses the grep function to filter those variables which contain either      mean or standard deviation and then subsetting to get the desired variables
3. cleaning the train data: naming the variables and filtering the required variables
4. cleaning the test data :naming the variables and filtering the required variables
5. merging the test and train dataset 
6. changing the class type of the variables subjectnumber and activity
7. Grouping by the subjectnuberwise and activitywise mean  

# 1.Creating a directory and downloading a file 
library(data.table)
library(reshape2)
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("Module_3_Project")){dir.create("./Module_3_Project")}
download.file(Url, destfile = "./Module_3_Project/data", method = "curl")
unzip("./Module_3_Project/data")
setwd("./UCI HAR Dataset")

# 2.Activity Labels and subjectnumbers
activitylabels <- fread("activity_labels.txt", header = F, sep = " ",col.names = c("activityclass", "activityname"))
features <- fread("features.txt", header = F,sep = " ", col.names = c("index", "feature"))
featuresrequired <- grep("(mean|std)\\(\\)", features[ , feature])
measurements <- features[featuresrequired, feature]
measurements <- gsub("[()]", "", measurements)

# 3.cleaning the train data set
traindata <- fread("train/X_train.txt", header = F, sep = " ", col.names = features$feature)
traindata <- traindata[,featuresrequired, with = F]
names(traindata) <- measurements
trainactivities <- fread("train/y_train.txt", header = F, sep = " ", col.names = "activity")
trainsubject <- fread("train/subject_train.txt", header = F, sep = " ", col.names = "subjectnumber" )
train <- cbind(trainsubject,trainactivities,traindata)

# 4.cleaning the test data set
testdata <- fread("test/X_test.txt", header = F, sep = " ", col.names = features$feature)
testdata <- testdata[, featuresrequired, with = F]
names(testdata) <- measurements
testactivities <-fread("test/y_test.txt", header = F, sep = " ", col.names = "activity")
testsubject <- fread("test/subject_test.txt", header = F, sep = " ", col.names = "subjectnumber" )
test <- cbind(testsubject,testactivities,testdata)

# 5.merging the test and train dataset 
dataset <- rbind(train,test)

# 6.changing the class type of the variables subjectnumber and activity
dataset[,"subjectnumber"] <- sapply(dataset[,"subjectnumber"], as.factor)
dataset[["activity"]] <- factor(dataset[, activity]
                                 , levels = activitylabels[["activityclass"]]
                                 , labels = activitylabels[["activityname"]])

# 7.Grouping by the subjectnuberwise and activitywise mean     
dataset <- melt(data = dataset, id = c("subjectnumber", "activity"))
dataset <- dcast(data = dataset, subjectnumber + activity ~ variable, fun.aggregate = mean)
fwrite(x = dataset, file = "tidyData.csv", quote = FALSE)
