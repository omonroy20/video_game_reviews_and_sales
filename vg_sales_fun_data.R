library(dplyr)
library(ggplot2)
library(tidyr)
vgs <- read.csv("game_sales_data.csv")
summary(vgs) # Seems mostly normal except for the NA's
sum(duplicated(vgs)) # Nor duplicated rows, luckily
head(vgs) # These 6 games are the highest selling (physical) games of all time


# Visualization of the Average Review Score and Shipments Throughout the Years


vgs_year_s <- vgs %>%
  select(Year, Critic_Score, User_Score, Total_Shipped) %>%
  group_by(Year) %>%
  summarize(
    avg_critic_score = mean(Critic_Score, na.rm = T),
    avg_user_score = mean(User_Score, na.rm = T),
    avg_total_shipped = mean(Total_Shipped, na.rm = T)
  )
vgs_year_s[, c(2, 3)] <- round(vgs_year_s[, c(2, 3)], 1)
vgs_year_s1 <- vgs_year_s[-c(1:7), ]

review_scores <- vgs_year_s1 %>%
  pivot_longer(cols = "avg_critic_score":"avg_user_score", 
               names_to = "review_type", values_to = "score")

ggplot(review_scores, aes(x = Year, y = score, group = review_type, color = review_type)) +
  geom_line() + 
  ggtitle("Average Review Scores by Year")

ggplot(vgs_year_s, aes(x = Year, y = avg_total_shipped)) +
  geom_line() + 
  ggtitle("Average Shipments of Game Units by Year")
# There are some major peaks in 1985 and 1989. Let's find out 
# what cause these sudden surges in game shipment numbers.
vgs[which(vgs$Year == 1985), c(2, 8, 9)]
vgs[which(vgs$Year == 1989), c(2, 8, 9)]
# As we can see, these 2 years have a low samples size and 
# were also headlined by major video game releases, namely
# Super Mario Bros and Duck Hunt in 1985 followed by
# Tetris and Super Mario Land in 1989, causing the 
# average total shipping numbers to be inflated.


cs <- ggplot(vgs, aes(x = Year, y = Critic_Score)) +
  geom_point() +
  ggtitle("Scatterplot of Critic Review Scores")
us <- ggplot(vgs, aes(x = Year, y = User_Score)) +
  geom_point(color = "red") +
  ggtitle("Scatterplot of User Review Scores")
cs 
us


# Observing the Discrepancy in Critic and User Review Scores


# Critic_Score - User_Score = Difference Score
dif <- vgs$Critic_Score - vgs$User_Score
na_index <- which(is.na(dif) == TRUE)
dif_df <- cbind("game" = vgs$Name, vgs[, c(6, 7)], "difference" = dif)
dif_df1 <- dif_df[-na_index, ]

# Games favored more positively by the critic than the user
head(dif_df1 %>% arrange(desc(difference)), 25)
# Games favored more positively by the user than the critic
tail(dif_df1 %>% arrange(desc(difference)), 25)
boxplot(dif_df1$difference, main = "Boxplot of Review Discrepancy",
        ylab = "Difference Score")
summary(dif_df1$difference)

no_dif <- which(dif_df1$difference == 0)
# Rare occasions where critic and user reviews agree on a score.
tail(dif_df1[no_dif, ], 20)

# Often these discrepancies in scores for the two types 
# are due to limitations of professionalism in critic reviews
# versus the lack of in the average user reviews. Sometimes,
# games are "review-bombed", a trend where ordinary internet
# users drown user reviews of a game due to a variety of reasons
# such as disagreements in publisher/developer policies and ideals.
# We can see that in the FIFA games where due to user complaints
# of the games' annual releases with little changes, we see a huge
# difference in the way a user and a critic reviews these games.
# Often, they are just the work of disagreements in the quality of
# the game; maybe a critic just wasn't able to see the positives of 
# a certain game and reviewed it unfavorably while users loved the game.