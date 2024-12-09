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



### Picking confounding variables

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

# Political Predispositions:
# Party Identification: IMD3005_1 (0,1) "Do you feel close to any one party?", (IMD3005_2)
# If yes, the more likely to vote for own party, regardless of incumbent/challenger status and economy?
# Ideology: IMD3006 (left-right self-placement, 0-10) -> useful for Party id?

# Political Information:
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

# Satisfaction
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
# IV -> Control Variables
# Control Variables -> DV
# Control Variables -> IV

# Create a DAG object
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
  Satis -> Incum
}"

g <- dagitty(dag_text)
# Plot the DAG
ggdag(g, layout = "auto") +
  theme_dag_grey() +
  theme(legend.position = "right") +
  ggtitle("DAG of economic voting theory with controls")

# Create a DAG object with full text
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
  SatisfiedWithDemocracy -> VoteForIncumbent
}"

g_full <- dagitty(dag_full_text)
# Plot the DAG with big nodes
ggdag(g_full)


# Plot the DAG with labels
ggdag(g_full, layout = "auto") +
  geom_dag_label(aes(label = name),
                 size = 5, 
                 label.padding = unit(0.5, "lines"),
                 label.r = unit(0.15, "lines"),
                 alpha = 0.7,              # make the label semi-transparent
                 fill = "lightblue",       # background color of the label
                 color = "black"           # border color of the label
  ) +
  theme_dag_gray() +
  ggtitle("DAG of economic voting theory with controls")


# Exercise 2 --------------------------------------------------------------

# Prepare the data

# control variables:
# Employment Status, (EP): IMD2014 (0-10; 0-5 in Labor Force, 6-10 not in Labor Force, 11-12, 97-99 -> NA)
# Problem: Half in Labor Force, half not in Labor Force, how to operationalize? Mark 1-5 as most to least employed?, 
# Or: 0-3 = employed (1), 4-5 = unemployed (0), drop 6-10?

# Partisan, (P): IMD3005_1 (0 = No, 1 = Yes, 7-9 -> NA)
# Problem: Need new variable: Partisan = Yes & Incumbent = same Party
# Need variable: Incumbent Party & respondent's party -> see paper notes

# Political Information, (PI): IMD3015_A (0-3), IMD3015_B (0-3), IMD3015_C (0-3), IMD3015_D (0-4)
# (0-3/0-4 number of correct answers, 9 -> NA)
# Problem: How to operationalize? Sum or aggregate all 4 variables? Or pick one?

# Satisfaction with Democracy, (S): IMD3010 (1-5, 6 = neutral, 6 -> 3, 7-9 -> NA)
# Problem: 6 = neutral -> 3!

# Independent Variable (E) (IMD3013_1) -> Economic Evaluation (1-3, 7-9 -> NA)
# Dependent Variable (I) (IMD3002_OUTGOV) -> Vote for Incumbent (0,1, 999999_ -> NA)

# New, unprepared df with the variables of interest
df <- cses_imd[, c("IMD3013_1", "IMD3002_OUTGOV", "IMD2014", "IMD3005_1", "IMD3015_A", "IMD3015_B", "IMD3015_C", "IMD3015_D", "IMD3010")]
# Rename the columns
colnames(df) <- c("Eco_Eval", "Vote_For_Incu", "Employment", "Partisan", "Pol_Info_A", "Pol_Info_B", "Pol_Info_C", "Pol_Info_D", "Sat_with_Dem")

