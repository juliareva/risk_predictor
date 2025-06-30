library(caret)
library(ggplot2)

set.seed(2000)

# Add fields about social networks:
smmh_detailed = smmh
smmh_detailed = within(smmh_detailed, UsesDiscord <- ifelse(grepl("Discord", X7..What.social.media.platforms.do.you.commonly.use.), "Yes", "No"))
smmh_detailed = within(smmh_detailed, UsesFacebook <- ifelse(grepl("Facebook", X7..What.social.media.platforms.do.you.commonly.use.), "Yes", "No"))
smmh_detailed = within(smmh_detailed, UsesInstagram <- ifelse(grepl("Instagram", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesPinterest <- ifelse(grepl("Pinterest", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesReddit <- ifelse(grepl("Reddit", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesSnapchat <- ifelse(grepl("Snapchat", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesTikTok <- ifelse(grepl("TikTok", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesTwitter <- ifelse(grepl("Twitter", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))
smmh_detailed = within(smmh_detailed, UsesYouTube <- ifelse(grepl("YouTube", X7..What.social.media.platforms.do.you.commonly.use.), "Yes","No"))

# Order of columns for plots:
level_order = c("Less than an Hour", "Between 1 and 2 hours",
                "Between 2 and 3 hours", "Between 3 and 4 hours",
                "Between 4 and 5 hours", "More than 5 hours")

# Correlations:
ggplot(smmh_detailed, aes(x = factor(X8..What.is.the.average.time.you.spend.on.social.media.every.day.,
                                     level = level_order),
                          y = X18..How.often.do.you.feel.depressed.or.down.)) + geom_bin_2d(binwidth=0.9) +
  scale_fill_gradient(low = "white", high = "orange", na.value = NA)


# Prepare data sets for specific social networks:
smmh_detailed_Facebook = smmh_detailed[which(smmh_detailed$UsesFacebook == "Yes"),]
smmh_detailed_Instagram = smmh_detailed[which(smmh_detailed$UsesInstagram == "Yes"),]
smmh_detailed_TikTok = smmh_detailed[which(smmh_detailed$UsesTikTok == "Yes"),]
smmh_detailed_YouTube = smmh_detailed[which(smmh_detailed$UsesYouTube == "Yes"),]


# Facebook
ggplot(smmh_detailed_Facebook, aes(x = factor(X8..What.is.the.average.time.you.spend.on.social.media.every.day.,
                                     level = level_order),
                          y = X18..How.often.do.you.feel.depressed.or.down.)) + geom_bin_2d(binwidth=0.9) +
  scale_fill_gradient(low = "white", high = "blue", na.value = NA)

# Instagram
ggplot(smmh_detailed_Instagram, aes(x = factor(X8..What.is.the.average.time.you.spend.on.social.media.every.day.,
                                              level = level_order),
                                   y = X18..How.often.do.you.feel.depressed.or.down.)) + geom_bin_2d(binwidth=0.9) +
  scale_fill_gradient(low = "white", high = "purple", na.value = NA)

# TikTok
ggplot(smmh_detailed_TikTok, aes(x = factor(X8..What.is.the.average.time.you.spend.on.social.media.every.day.,
                                              level = level_order),
                                   y = X18..How.often.do.you.feel.depressed.or.down.)) + geom_bin_2d(binwidth=0.9) +
  scale_fill_gradient(low = "white", high = "green", na.value = NA)

# YouTube
ggplot(smmh_detailed_YouTube, aes(x = factor(X8..What.is.the.average.time.you.spend.on.social.media.every.day.,
                                              level = level_order),
                                   y = X18..How.often.do.you.feel.depressed.or.down.)) + geom_bin_2d(binwidth=0.9) +
  scale_fill_gradient(low = "white", high = "red", na.value = NA)



# Preparing dataset for training
smmh_for_training = smmh_detailed

# Removing unnecessary columns
smmh_for_training$Timestamp = NULL # No need for timestamp
smmh_for_training$X7..What.social.media.platforms.do.you.commonly.use. = NULL # We added all social medai individually

# Convert string to factors
smmh_for_training[sapply(smmh_for_training, is.character)] = lapply(smmh_for_training[sapply(smmh_for_training, is.character)], as.factor)


# TRAINING
trcontrol = trainControl(method="repeatedcv", number=10,repeats=20)

# Model: k-Nearest Neighbors
kknnModel = train(X18..How.often.do.you.feel.depressed.or.down. ~., data=smmh_for_training, trControl=trcontrol, method="kknn")

# Model: Linear Regression
lmModel = train(X18..How.often.do.you.feel.depressed.or.down. ~., data=smmh_for_training, trControl=trcontrol, method="lm")

# Model: Elastic Net
glmnetModel = train(X18..How.often.do.you.feel.depressed.or.down. ~., data=smmh_for_training, trControl=trcontrol, method="glmnet")


result=resamples(list(kNearestNeighbor=kknnModel, LinearRegression=lmModel, GLMNET=glmnetModel))

bwplot(result,scales=list(relation="free"))
