## installing packages and libraries
library(plyr) 
library(dplyr) 
library(tidyr) 
install.packages("data.table")
library(data.table)

%% setting up the working directory %%
setwd("% enter working directory here% ") 
path=getwd()

## downloading data zip file
url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file="Data.zip"
download.file(url,file.path(path,file))

## listing all files in the zip folder
unzip("Data.zip",list=T)
## Manipulating Data to merge training and test sets 
SubjectTrain=read.table(unzip("Data.zip",files="UCI HAR Dataset/train/subject_train.txt"))
SubjectTest=read.table(unzip("Data.zip",files="UCI HAR Dataset/test/subject_test.txt"))
ActivityTrain=read.table(unzip("Data.zip",files="UCI HAR Dataset/train/y_train.txt"))
ActivityTest=read.table(unzip("Data.zip",files="UCI HAR Dataset/test/y_test.txt"))
DataTrain=read.table(unzip("Data.zip",files = "UCI HAR Dataset/train/X_train.txt"))
DataTest=read.table(unzip("Data.zip",files = "UCI HAR Dataset/test/X_test.txt"))
Subject=rbind(SubjectTrain,SubjectTest)
setnames(Subject,"V1","subject")
Activity=rbind(ActivityTrain,ActivityTest)
setnames(Activity,"V1","ActivityNum")
Data=rbind(DataTrain,DataTest)
Subject=cbind(Subject,Activity)
Data=cbind(Subject,Data)
Data=arrange(Data,subject,ActivityNum)
View(Data)


## Extracting mean and std dev for measurements 
Features=read.table(unzip("Data.zip",files = "UCI HAR Dataset/features.txt"))
setnames(Features,names(Features),c("S.No","Name"))
Features_subset=filter(Features,grepl("mean\\(\\)|std",Name))
head(Features_subset,n=5)
Features_subset=mutate(Features_subset,Code=paste0("V",S.No))
Features_subset$Code
setkey(as.data.table(Data),subject,ActivityNum)
n=c(key(Data),Features_subset$Code)
Data_mean_std=Data[,n]
head(Data_mean_std,n=4)


## Using descriptive activity names and labeling data set with descritive variable names
ActivityNames=read.table(unzip("Data.zip",files = "UCI HAR Dataset/activity_labels.txt"))
setnames(ActivityNames,names(ActivityNames),c("ActivityNum","Activity"))
Data_merged=merge(Data,ActivityNames,by="ActivityNum",all.x = T)
Data_melt=data.table(melt(Data_merged,id=c("subject","ActivityNum","Activity"),variable.name = "Code"))
setnames(Data_melt,"variable","Code")
Features=mutate(Features,Code=paste0("V",S.No))
TidyData=merge(Data_melt,Features,by="Code",all.x = T) 
setnames(TidyData,"Name","Activity_Detail") 
TidyData=select(TidyData,-c(S.No,Code,ActivityNum))
head(TidyData,n=4)


## Manipulating TidyData to create second data set
Subset_Data=TidyData %>% group_by(subject,Activity,Activity_Detail) %>% summarize(mean(value)) %>% arrange(subject)
head(Subset_Data,n=5)


## Producing output
dest=file.path(path,"TidyData.txt")
write.table(TidyData,dest, sep="\t")
