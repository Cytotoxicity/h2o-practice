pacman::p_load(h2o, dplyr, readxl, caret)

h2o.init()

data_origin <- as.h2o(read.csv("Data/train.csv"))
data_csv <- read.csv("Data/train.csv")
h2o.ls()
head(data_origin)

idx <- createDataPartition(data_csv$voted, p=0.7, list=F, times=2)
data_train <- as.h2o(data_csv[idx,])
data_test <- as.h2o(data_csv[-idx,])

