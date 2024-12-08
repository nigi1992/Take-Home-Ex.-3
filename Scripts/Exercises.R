# Setup -------------------------------------------------------------------

# Install packages
#install.packages(c("dagitty", "ggdag"))
# Load necessary libraries
library(tidyverse)
install.packages("dagitty")
library(dagitty)
install.packages("ggdag")
library(ggdag)

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



# Picking confounding variables

# Socio-Demographic Variables:
# Education: IMD2003
# Household Income: IMD2006
# Urban or Rural Residence: IMD2007
# Employment Status: IMD2014

# Political Predispositions:
# Party Identification: IMD3005_1, IMD3005_2
# Ideology: IMD3006 (left-right self-placement)

# Political Information:
# IMD3015_1   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 1ST
# IMD3015_2   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 2ND
# IMD3015_3   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 3RD
# IMD3015_4   >>>    POLITICAL INFORMATION: DICHOTOMIZED ITEM - 4TH

# IMD3015_A   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 1 (0-3 SCALE)
# IMD3015_B   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 2 (0-3 SCALE)                 
# IMD3015_C   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 3 (0-3 SCALE)   
# IMD3015_D   >>>    POLITICAL INFORMATION: SCALE - CSES MODULE 4 (0-4 SCALE)

# Satisfaction
# IMD3010     >>>    SATISFACTION WITH DEMOCRACY
# IMD3011     >>>    EFFICACY: WHO IS IN POWER CAN MAKE A DIFFERENCE
# IMD3012     >>>    EFFICACY: WHO PEOPLE VOTE FOR MAKES A DIFFERENCE

# next step: pick control variables from above based on theoretical reasoning
# The DAG will be as follows: