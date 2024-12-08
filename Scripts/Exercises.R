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

# DV: IMD3002_OUTGOV >>> VOTE CHOICE: CURRENT MAIN ELECTION - 
# VOTE FOR OUTGOING GOVERNMENT (INCUMBENT)
# Whether or not the respondent cast a ballot for the outgoing incumbent.

# The DAG will be as follows:

# next step: pick control variables based on theoretical reasoning
