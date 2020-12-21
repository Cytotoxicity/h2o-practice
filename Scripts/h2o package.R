pacman::p_load(h2o, dplyr, readxl, caret)

h2o.init()
h2o.no_progress()

data_origin <- as.h2o(read.csv("Data/train.csv"))
data_csv <- read.csv("Data/train.csv")
data_csv$voted <- as.factor(data_csv$voted)

h2o.ls()
head(data_origin)

idx <- createDataPartition(data_csv$voted, p=0.7, list=F, times=2)
data_train <- as.h2o(data_csv[idx,])
data_test <- as.h2o(data_csv[-idx,])
data_lead <- as.h2o(read.csv("Data/test_x.csv"))

y <- "voted"
x <- setdiff(names(data_train), y)

tmp <- h2o.automl(y=y, x=x, training_frame=data_train, max_runtime_secs_per_model = 60, max_models = 3, validation_frame = data_test, 
                  nfolds=5, stopping_metric = "AUC")

model <- h2o.automl(voted~., training_frame=data_train, max_runtime_secs_per_model = 60, max_models = 15, validation_frame = data_test, 
                    nfolds=5, stopping_metric = "AUC")

tmp@leader
tmp_pred <- h2o.predict(object=tmp@leader, newdata=data_lead)

tmp_result <- as.data.frame(tmp_pred$predict)
colnames(tmp_result) <- c("voted")
tmp_result$index <- c(0:11382)

write.csv(tmp_result, "Outputs/test.csv")
