library(data.table)
library(dplyr)

# Load data sets.
train_xs <- fread("UCI HAR Dataset/train/X_train.txt")
train_ys <- fread("UCI HAR Dataset/train/y_train.txt")
train_subject <- fread("UCI HAR Dataset/train/subject_train.txt")

test_xs <- fread("UCI HAR Dataset/test/X_test.txt")
test_ys <- fread("UCI HAR Dataset/test/y_test.txt")
test_subject <- fread("UCI HAR Dataset/test/subject_test.txt")

# Concatenate training and test data sets.
data <- rbind(train_xs, test_xs)
all_ys <- rbind(train_ys, test_ys)
all_subject <- rbind(train_subject, test_subject)

# Apply feature names to the data columns.
feature_names <- fread("UCI HAR Dataset/features.txt")
names(data) <- feature_names[[2]]

# Filter data set down to desired columns
data <- data[,grep("-(mean|std)\\(\\)", names(data)), with=FALSE]

# Add activities and subjects to the data.
activity_labels <- fread("UCI HAR Dataset/activity_labels.txt")[[2]]
data$activity <- sapply(all_ys[[1]], function(label_index) { activity_labels[label_index] })
data$subject <- all_subject[[1]]

# Produce data set with averages broken bown by subject and activity.
averages_by_activity_subject <- data %>% group_by(subject, activity) %>% summarize_each(funs(mean)) %>% arrange(subject, activity)
write.csv(averages_by_activity_subject, "averages_by_activity_subject.csv", row.names=FALSE)
