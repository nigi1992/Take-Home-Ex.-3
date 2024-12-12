# Setup -------------------------------------------------------------------

# Install packages
#install.packages(c("dagitty", "ggdag"))
# Load necessary libraries
library(tidyverse)
install.packages("dagitty")
library(dagitty)
install.packages("ggdag")
library(ggdag)
library(ggplot2)
#save cses_imd as .csv
write.csv(cses_imd, "Report/cses_imd.csv")

# Exercise 1 ---------------------------------------------------------------
# Draw a DAG of the causal hypothesis

# IV: IMD3013_1 >>> STATE OF ECONOMY (OVER PAST 12 MONTHS)
# Would you say that over the past twelve months, the state of the economy 
# in [COUNTRY] has gotten better, stayed about the same, or gotten worse?
# Categorical: 1 = Better, 2 = Same, 3 = Worse
# (7 = refused, 8 = don't know, 9 = missing)

# DV: IMD3002_OUTGOV >>> VOTE CHOICE: CURRENT MAIN ELECTION - 
# VOTE FOR OUTGOING GOVERNMENT (INCUMBENT)
# Whether or not the respondent cast a ballot for the outgoing incumbent.
# Binary: 0 = Did not vote for incumbent, 1 = Voted for incumbent
# (999999 for rest of answers)

### Picking control variables

# Socio-Demographic Variables:
# Age: Age: IMD2001_1 (age in years, continous, 015-115), IMD2001_2 (age in categories, 0-6)
# The older, the more likely to vote for the incumbent and more likely to be satisfied with
# economy???
# Gender: IMD2002 (0,1)
# Female more likely to vote for the incumbent??? More satisfied with economy???
# Urban or Rural Residence: IMD2007 (1-4)
# Urban residents more likely to be satisfied with economy?

# Education: IMD2003 (0-6)
# The better educated, the more likely to be satisfied with economy
# Household Income: IMD2006 (1-5)
# The richer, the more likely to be satisfied with economy
# Employment Status: IMD2014 (0-10)
# Employed more likely to be satisfied with economy and more likely to vote for the incumbent

# Political/Partisan Predispositions:
# Party Identification/ Partisan: IMD3005_1 (0,1) "Do you feel close to any one party?", (IMD3005_2)
# If yes, the more likely to vote for own party, regardless of incumbent/challenger status and economy?
# Ideology: IMD3006 (left-right self-placement, 0-10) -> useful for Party id?

# Political Information/Politically Informed:
# IMD3015_1   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 1ST
# IMD3015_2   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 2ND
# IMD3015_3   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 3RD
# IMD3015_4   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 4TH
# 0 = Incorrect, 1 = Correct

# IMD3015_A   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 1 (0-3 SCALE)
# IMD3015_B   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 2 (0-3 SCALE)                 
# IMD3015_C   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 3 (0-3 SCALE)   
# IMD3015_D   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 4 (0-4 SCALE)
# 0-3, 0-4 number of correct answers
# If more informed, the less likely, that the state of economy does matter for voting for incumbent

# Satisfaction with Democracy:
# IMD3010     >>>    SATISFACTION WITH DEMOCRACY (1-6)
# the more satisfied with dem., the less likely the state of eco. has an effect on voting for incumbent

# IMD3011     >>>    EFFICACY: WHO IS IN POWER CAN MAKE A DIFFERENCE (1-5)
# The more agreement, with this statement, the more likely the state of economy has an effect on voting for incumbent
# IMD3012     >>>    EFFICACY: WHO PEOPLE VOTE FOR MAKES A DIFFERENCE (1-5)
# The more agreement, with this statement, the more likely the state of economy has an effect on voting for incumbent


### I pick the following control variables:
# Employment Status, (EP): IMD2014 (0-10)
# Partisan, (P): IMD3005_1 (0,1)
# Political Information, (PI): IMD3015_A (0-3), IMD3015_B (0-3), IMD3015_C (0-3), IMD3015_D (0-4)
# Satisfaction with Democracy, (S): IMD3010 (1-6)

# The DAG will be as follows:
# IV (E) (IMD3013_1) -> DV (I) (IMD3002_OUTGOV)
# Control Variables -> DV
# Control Variables -> IV

# Simple DAG 
dag_text <- "dag {
  Eco [exposure,pos=\"-0.5,0\"]
  Incum [outcome,pos=\"0.5,0\"]
  Emp [pos=\"-1,-1\"]
  Parti [pos=\"-1,1\"]
  Pol_I [pos=\"1,1\"]
  Satis [pos=\"1,-1\"]
  Eco -> Incum
  Emp -> Eco
  Parti -> Eco
  Pol_I -> Eco
  Satis -> Eco
  Emp -> Incum
  Parti -> Incum
  Pol_I -> Incum
  Satis -> Incum}"

g <- dagitty(dag_text)
ggdag(g, layout = "auto") +
  theme_dag_grey() +
  theme(legend.position = "right") +
  ggtitle("DAG of economic voting theory with controls")
ggsave("Output/dag_simple.png")

# Labeled DAG
dag_full_text <- "dag {
  EconomicEvaluation [exposure,pos=\"-0.5,0\"]
  VoteForIncumbent [outcome,pos=\"0.5,0\"]
  Employment [pos=\"-1,-1\"]
  Partisan [pos=\"-1,1\"]
  PoliticallyInformed [pos=\"1,1\"]
  SatisfiedWithDemocracy [pos=\"1,-1\"]
  EconomicEvaluation -> VoteForIncumbent
  Employment -> EconomicEvaluation
  Partisan -> EconomicEvaluation
  PoliticallyInformed -> EconomicEvaluation
  SatisfiedWithDemocracy -> EconomicEvaluation
  Employment -> VoteForIncumbent
  Partisan -> VoteForIncumbent
  PoliticallyInformed -> VoteForIncumbent
  SatisfiedWithDemocracy -> VoteForIncumbent}"
g_full <- dagitty(dag_full_text)
#ggdag(g_full)

# Ploting the DAG with labels
ggdag(g_full, layout = "auto") +
  geom_dag_label(aes(label = name),
                 size = 5, 
                 label.padding = unit(0.5, "lines"),
                 label.r = unit(0.15, "lines"),
                 alpha = 0.7,              # make the label semi-transparent
                 fill = "lightblue",       # background color of the label
                 color = "black"   ) +    # border color of the label
  theme_dag_gray() + ggtitle("DAG of economic voting theory with controls")
ggsave("Output/dag_labeled.png")


# Exercise 2 --------------------------------------------------------------

# Prepare the data

# Possible Control variables:
# Employment Status, (EP): IMD2014 (0-10; 0-5 in Labor Force, 6-10 not in Labor Force, 11-12, 97-99 -> NA)
# Problem: Half in Labor Force, half not in Labor Force, how to operationalize? Mark 1-5 as most to least employed?, 
# Or: 0-3 = employed (1), 4-5 = unemployed (0), drop 6-10?

# Partisan, (P): IMD3005_1 (0 = No, 1 = Yes, 7-9 -> NA)
# Problem: Need new variable: Partisan = Yes & Incumbent = same Party
# Need additional variables to create this control variable: Incumbent Party & respondent's party -> see paper notes

# Political Information, (PI): IMD3015_A (0-3), IMD3015_B (0-3), IMD3015_C (0-3), IMD3015_D (0-4)
# (0-3/0-4 number of correct answers, 9 -> NA)
# Problem: How to operationalize? Sum or aggregate all 4 variables? Or pick one?

# Satisfaction with Democracy, (S): IMD3010 (1-5, 6 = neutral, 6 -> 3, 7-9 -> NA)
# Problem: 6 = neutral -> 3!

# Independent Variable (E) (IMD3013_1) -> Economic Evaluation (1-3, 7-9 -> NA)
# Dependent Variable (I) (IMD3002_OUTGOV) -> Vote for Incumbent (0,1, 999999_ -> NA)

# New, unprepared df with the variables of interest
df <- cses_imd[, c("IMD3013_1", "IMD3002_OUTGOV", "IMD2014", "IMD3005_1",
                   "IMD3015_A", "IMD3015_B", "IMD3015_C", "IMD3015_D", 
                   "IMD3010")]

# Rename the columns
colnames(df) <- c("Eco_Eval", "Vote_For_Incu", "Employment", "Partisan", 
                  "Pol_Info_A", "Pol_Info_B", "Pol_Info_C", "Pol_Info_D", 
                  "Sat_with_Dem")


# Checking Data Structure -------------------------------------------------

## Economic Evaluation
table(df$Eco_Eval)
# Show distribution in %
prop.table(table(df$Eco_Eval))*100
# 40% invalid answers, 60% valid answers -> remove Na's?
is.factor(df$Eco_Eval)
is.numeric(df$Eco_Eval) # is numeric -> turn to ordinal factor

## Vote for Incumbent
table(df$Vote_For_Incu)
prop.table(table(df$Vote_For_Incu))*100
# 30% invalid answers, 70% valid answers -> remove Na's?
is.factor(df$Vote_For_Incu)
is.numeric(df$Vote_For_Incu) # is numeric -> turn to binary dummy 

## Employment
table(df$Employment)
prop.table(table(df$Employment))*100
# 32% invalid answers, 68% valid answers -> impute Na's or remove?
is.factor(df$Employment)
is.numeric(df$Employment) # is numeric -> turn to binary dummy

## Partisan
table(df$Partisan)
prop.table(table(df$Partisan))*100 # 94% valid answers, 6% invalid answers -> Imputation possible!
is.numeric(df$Partisan) # is numeric -> turn to binary dummy

## Political Information
table(df$Pol_Info_A)
prop.table(table(df$Pol_Info_A))*100 # 90% invalid -> remove!
table(df$Pol_Info_B)
prop.table(table(df$Pol_Info_B))*100 # 86% invalid -> remove!
table(df$Pol_Info_C)
prop.table(table(df$Pol_Info_C))*100 # 82% invalid -> remove!
table(df$Pol_Info_D)
prop.table(table(df$Pol_Info_D))*100 # 84% invalid -> remove!

# Pick the other Pol. Info. variable
df <- cses_imd[, c("IMD3013_1", "IMD3002_OUTGOV", "IMD2014", "IMD3005_1",
                   "IMD3015_1", "IMD3015_2", "IMD3015_3", "IMD3015_4", 
                   "IMD3010")]
colnames(df) <- c("Eco_Eval", "Vote_For_Incu", "Employment", "Partisan", 
                  "Pol_Info_1", "Pol_Info_2", "Pol_Info_3", "Pol_Info_4", 
                  "Sat_with_Dem")
table(df$Pol_Info_1)
prop.table(table(df$Pol_Info_1))*100 # 50% invalid -> remove!
table(df$Pol_Info_2)
prop.table(table(df$Pol_Info_2))*100 # 54% invalid -> remove!
table(df$Pol_Info_3)
prop.table(table(df$Pol_Info_3))*100 # 56% invalid -> remove!
table(df$Pol_Info_4)
prop.table(table(df$Pol_Info_4))*100 # 90% invalid -> remove!
# too many invalid answers, remove all Pol. Info. variables!!!


### Redo data set with only the variables of interest
df <- cses_imd[, c("IMD3013_1", "IMD3002_OUTGOV", "IMD2014", "IMD3005_1", "IMD3010")]
colnames(df) <- c("Eco_Eval", "Vote_For_Incu", "Employment", "Partisan", "Sat_with_Dem")


## Satisfaction with Democracy
table(df$Sat_with_Dem)
prop.table(table(df$Sat_with_Dem))*100 # 6% invalid -> impute NA's!
is.numeric(df$Sat_with_Dem) # is numeric -> turn to ordinal factor, 6 -> 3

# Missing Data ------------------------------------------------------------

# Show missing values
sapply(df, function(x) sum(is.na(x)))

## Recode missing values
df$Vote_For_Incu[df$Vote_For_Incu %in% 9999996:9999999] <- NA
df$Eco_Eval[df$Eco_Eval %in% 7:9] <- NA

df$Employment[df$Employment %in% c(11:12, 97:99)] <- NA
df$Partisan[df$Partisan %in% c(7:9)] <- NA
df$Sat_with_Dem[df$Sat_with_Dem %in% c(7:9)] <- NA

# Save df
write.csv(df, "Input Data/df_NA.csv")

# Show missing values
sapply(df, function(x) sum(is.na(x)))

# Impute missing values or Remove????
# IV: nearly 40% missing values, simply removing could lead to a substantial loss of data, which may compromise the statistical power and generalizability of results.
# Imputing the missing values Since the variable is ordinal, consider imputation like predictive mean matching (for ordinal variables) 
# DV: 30% missing values, simply removing could lead to a substantial loss of data, which may compromise the statistical power and generalizability of results.
# However, Missingness in the dependent variable is more problematic because these rows cannot directly contribute to the regression analysis.
# Therefore, it is better to remove the missing values in the dependent variable (listwise deletion)
# CV:
# 1. Employment: 32% missing values, simply removing could lead to a substantial loss of data, which may compromise the statistical power and generalizability of results.
# But I already lost another CV due to overwhelming amount of Na's, so I will try anyway with multiple imputation
# 2. Partisan & Satisfaction: both ca. 6% missing values, both imputation/Removal possible. I will attempt to impute in order to perserve sample size

library(dplyr)
df_cleaned <- df %>% filter(!is.na(Vote_For_Incu)) # remove NA's in DV
str(df_cleaned)

# Recode Variables --------------------------------------------------------

table(df_cleaned$Employment)
table(df_cleaned$Sat_with_Dem)

df_recode <- df_cleaned %>% mutate(
        Employment = ifelse(Employment %in% 0:3, 1, 0),
        Sat_with_Dem = ifelse(Sat_with_Dem == 6, 3, Sat_with_Dem))
str(df_recode)

write.csv(df_recode, "Input Data/df_recode.csv")


# Imputation --------------------------------------------------------------
install.packages("mice")
library(mice)
# Impute missing values for Partisan and Sat_with_Dem (little NA's)
df_recode$Partisan[is.na(df_recode$Partisan)] <- 
  median(df_recode$Partisan, na.rm = TRUE)  # Median imputation
df_recode$Sat_with_Dem[is.na(df_recode$Sat_with_Dem)] <- 
  median(df_recode$Sat_with_Dem, na.rm = TRUE)  # Median imputation

# Impute missing values for Employment and Eco_Eval (lots of NA's) using predictive mean matching
df_impute <- mice(df_recode, method = c(
  "pmm",        # Eco_Eval: Predictive Mean Matching
  "",           # Vote_For_Incu: No missing data (dependent variable)
  "pmm",        # Employment: Predictive Mean Matching
  "",           # Partisan: Already imputed with median
  ""            # Sat_with_Dem: Already imputed with median
), m = 5, seed = 123)

# Extract the completed dataset (first imputed dataset)
df_complete <- complete(df_impute, 1)
str(df_complete)
summary(df_complete)
colSums(is.na(df_complete))

# Check Multicollinearity -------------------------------------------------

library(car)
fit_temp <- lm(Vote_For_Incu ~ Eco_Eval + Employment + Partisan + Sat_with_Dem, data = df_complete)
vif(fit_temp)
# All values are close to 1, indicating minimal or no multicollinearity among the predictors


# Exercise 3 --------------------------------------------------------------

Simple_model <- lm(Vote_For_Incu ~ Eco_Eval, data = df_complete)
summary(Simple_model)

# OLS model
OLS_model <- lm(Vote_For_Incu ~ Eco_Eval + Employment + Partisan + Sat_with_Dem, data = df_complete)
summary(OLS_model)


library(stargazer)
stargazer(Simple_model, OLS_model, type = "text")

# Important!!! I did not inverse the order of Eco_Eval and Sat_with_Dem, so the relationships with the DV are negative!

#Optional: you can plot the predicted probabilities of voting for the incumbent based on economic
#evaluations. This may be helpful for interpreting your results.

# Load required libraries
library(ggplot2)
library(dplyr)

# Create sequence of economic evaluation values
eco_eval_seq <- seq(min(df_complete$Eco_Eval, na.rm = TRUE), 
                    max(df_complete$Eco_Eval, na.rm = TRUE), 
                    length.out = 100)

# Calculate predicted probabilities for both models
predicted_probs <- data.frame(
  Eco_Eval = eco_eval_seq,
  # Full model (Model 2)
  full_model = 0.762 + # intercept
    (-0.080 * eco_eval_seq) + # Eco_Eval coefficient
    (-0.002 * mean(df_complete$Employment)) + # Employment at mean
    (0.023 * mean(df_complete$Partisan)) + # Partisan at mean
    (-0.044 * mean(df_complete$Sat_with_Dem)), # Sat_with_Dem at mean
  # Simple model (Model 1)
  simple_model = 0.684 + # intercept
    (-0.089 * eco_eval_seq) # Eco_Eval coefficient
)

# Create the plot
ggplot(predicted_probs) +
  # Line for full model
  geom_line(aes(x = Eco_Eval, y = full_model, color = "Full Model"), size = 1) +
  geom_ribbon(aes(x = Eco_Eval,
                  ymin = full_model - 0.466/2,
                  ymax = full_model + 0.466/2),
              alpha = 0.1, fill = "blue") +
  # Line for simple model
  geom_line(aes(x = Eco_Eval, y = simple_model, color = "Simple Model"), size = 1) +
  geom_ribbon(aes(x = Eco_Eval,
                  ymin = simple_model - 0.470/2,
                  ymax = simple_model + 0.470/2),
              alpha = 0.1, fill = "green") +
  # Customize colors and labels
  scale_color_manual(values = c("Full Model" = "blue", "Simple Model" = "green")) +
  labs(title = "Predicted Probability of Voting for Incumbent",
       subtitle = "Comparison of Simple and Full Models",
       x = "Economic Evaluation",
       y = "Predicted Probability",
       color = "Model",
       caption = "Shaded areas represent 95% confidence intervals") +
  theme_minimal() +
  scale_y_continuous(limits = c(0, 1)) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "bottom")
ggsave("Output/predicted_probs_plot.png", width = 8, height = 6, dpi = 300)


# Exercise 4 --------------------------------------------------------------


# junk--------------------------------------------------------
table(df_recoded$Employment)
table(df_recoded$Sat_with_Dem)
str(df_recoded)

# Convert to factors for categorical variables
df_recoded <- df_recoded %>%
  mutate(
    Eco_Eval = factor(Eco_Eval, levels = c(5, 3, 1), labels = c("Worse", "Same", "Better"), ordered = TRUE),
    Employment = factor(Employment, levels = c(0, 1)), # Binary factor
    Partisan = factor(Partisan, levels = c(0, 1)),     # Binary factor
    Sat_with_Dem = factor(Sat_with_Dem, levels = c(1, 2, 3, 4, 5), ordered = TRUE) # Ordinal factor
  )
# Check structure of the variables
str(df_recoded)


install.packages("mice")
library(mice)
df_imputed <- mice(df_recode, m = 5, 
                   method = c("polyreg",     # Eco_Eval: ordinal/categorical
                              "",            # Vote_For_Incu: already cleaned
                              "logreg",      # Employment: binary dummy
                              "logreg",      # Partisan: binary dummy
                              "polyreg"),    # Sat_with_Dem: ordinal
                   maxit = 5, seed = 123)
df_imputed <- complete(df_imputed)
str(df_imputed)
summary(df_imputed)
colSums(is.na(df_imputed))



# Code Rest ----------------------------------------------------------

str(df)
## Economic Evaluation
# numeric -> factor
#  1 = Better, 3 = Same, 5 = Worse
# Create an ordered factor
df$Eco_Eval <- factor(df$Eco_Eval,
                            levels = c(5, 3, 1),   # order from worst to best
                            labels = c("Worse","Same","Better"),
                            ordered = TRUE)
# check the structure
str(df$econ_state_ord)



## Employment
# don't drop 6-10, it's more than a third of the data!!!
#df$Employment <- ifelse(df$Employment %in% 0:3, 1, 0)

# Binary classification: employed (including any hours worked) vs. unemployed
df$Employment_bin <- NA
df$Employment_bin[df$Employment %in% c(0,1,2,3,4)] <- 1 # employed
df$Employment_bin[df$Employment == 5] <- 0 # unemployed
#### Decide what to do with values 6-10: either NA or exclude from analysis
df <- df[!df$Employment %in% c(6:10), ]

# OR:
# Three categories: employed, unemployed, not in labor force
df$Employment_cat <- NA
df$Employment_cat[df$Employment %in% c(0,1,2,3,4)] <- "Employed"
df$Employment_cat[df$Employment == 5] <- "Unemployed"
df$Employment_cat[df$Employment %in% c(6:10)] <- "Not_in_LF"
df$Employment_cat <- factor(df$Employment_cat, levels=c("Employed","Unemployed","Not_in_LF"))

# to make it a bit simpler I advise you to categorize into employed (0-3) and unemployed (4-10)!!



## Politically Informed
# Standardize political information scales to a 0–1 range
df$PolInfo_Mod1_std <- df$IMD3015_A / 3  # Module 1
df$PolInfo_Mod2_std <- df$IMD3015_B / 3  # Module 2
df$PolInfo_Mod3_std <- df$IMD3015_C / 3  # Module 3
df$PolInfo_Mod4_std <- df$IMD3015_D / 4  # Module 4

# Aggregate the standardized scales
df$PolInfo_Agg <- rowMeans(df[, c("PolInfo_Mod1_std", "PolInfo_Mod2_std", 
                                  "PolInfo_Mod3_std", "PolInfo_Mod4_std")], 
                           na.rm = TRUE)

# OR: 
# Combine standardized scores into a single measure
df$PolInfo_Combined <- rowMeans(df[, c("PolInfo_Mod1_std", "PolInfo_Mod2_std", 
                                       "PolInfo_Mod3_std", "PolInfo_Mod4_std")], 
                                na.rm = TRUE)

# Note:
# Convert to an ordinal factor
df$PolInfo_Mod1_ordinal <- factor(df$IMD3015_A, levels = 0:3, ordered = TRUE)

# OR: neither -> I suggest summarize the variables you are inspecting!!! -> but too many NA's
# So create a new variable that summarizes the number of correct answers from across the three modules
# but what to do if NA in one?
# Show number of value == 9
sum(df$Pol_Info_A == 9)
sum(df$Pol_Info_B == 9)
sum(df$Pol_Info_C == 9)
sum(df$Pol_Info_D == 9)

### Use binary variable instead!
table(cses_imd$IMD3015_1)
table(cses_imd$IMD3015_2)
table(cses_imd$IMD3015_3)
table(cses_imd$IMD3015_4)


## Partisan
table(df$Partisan)
# Add new columns to data_frame
df3 <- cses_imd[, c("IMD3013_1", "IMD3002_OUTGOV", "IMD2014", "IMD3005_1", 
                    "IMD3005_3", INCUMBENT_PARTY_CODE, "IMD3015_A", "IMD3015_B", 
                    "IMD3015_C", "IMD3015_D", "IMD3010")]
colnames(df3) <- c("Eco_Eval", "Vote_For_Incu", "Employment", "Partisan", 
                   "Resp_Party", "Incum_Party", "Pol_Info_A", "Pol_Info_B", 
                   "Pol_Info_C", "Pol_Info_D", "Sat_with_Dem")
# Create the political predispositions control variable
df3 <- df3 %>%
  mutate(
    political_predisposition = case_when(
      # Respondent identifies with incumbent's party
      Vote_For_Incu == 1 & IMD3005_3 == INCUMBENT_PARTY_CODE ~ "Incumbent",
      # Respondent identifies with a different party
      Vote_For_Incu == 1 & IMD3005_3 != INCUMBENT_PARTY_CODE ~ "Opposition",
      # Respondent does not identify with any party
      Vote_For_Incu == 0 ~ "Non-partisan",
      # If no data or missing
      TRUE ~ NA_character_))
# Optional: Convert the variable to a factor
cses_data$political_predisposition <- factor(
  cses_data$political_predisposition, 
  levels = c("Incumbent", "Opposition", "Non-partisan"))  