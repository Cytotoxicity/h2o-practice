pacman::p_load(h2o, dplyr, readxl, caret)

h2o.init()
h2o.no_progress()

data_origin <- as.h2o(read.csv("Data/train.csv"))
data_csv <- read.csv("Data/train.csv")
data_csv <- data_csv %>% select(-index)
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

model <- h2o.automl(y=y, x=x, training_frame=data_train, max_runtime_secs_per_model = 60, max_models = 10, validation_frame = data_test, 
                    nfolds=5, stopping_metric = "AUC")

model@leaderboard
model_ids <- as.data.frame(model@leaderboard$model_id)[,1]
stacked_ensemble_model <- h2o.getModel(grep("StackedEnsemble_AllModels", model_ids, value = TRUE)[1]) #pre-processing 아직 잘 안 됨
h2o.getId()

metalearner <- h2o.getModel(stacked_ensemble_model@model$metalearner$name)

stacked_ensemble_model@allparameters

h2o.varimp_plot(metalearner)

### 시각화
h2o.varimp(metalearner) %>% DT::datatable()

model@leader

#어떻게 선택된 알고리즘으로 다른 데이터를 학습시킴?
finalmodel <- h2o.stackedEnsemble(x=x, y=x, training_frame = data_csv, metal)

model_pred <- h2o.predict(object=model@leader, newdata=data_lead)

model_result <- as.data.frame(model_pred$predict)
colnames(model_result) <- c("voted")
model_result$index <- c(0:11382)

write.csv(model_result, "Outputs/test.csv")

h2o.shutdown(prompt = F)