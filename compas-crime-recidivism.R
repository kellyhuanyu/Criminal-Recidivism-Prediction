---
title: 'IMT 573: Problem Set 08 - Predictive Modeling'
author: "Kelly Liu"
output: html_document
---

# Instructions

Before beginning this assignment, please ensure you have access to R
and RStudio.

1. Update the lab number and title in the `title:` field.

1. Replace the "Insert Your Name Here" text in the `author:` field
   with your own full name. 

1. Be sure to include well-documented (e.g. commented) code chucks,
   figures and clearly written text-chunk explanations as
   necessary. Any figures should be clearly labeled and appropriately
   referenced within the text.

1. When you have completed the assignment and have **checked** that
   your code both runs in the Console and knits correctly when you
   click `Knit to HTML`, rename the R Markdown file to
   `YourLastName-YourFirstName-labX.Rmd`, where `X` is the lab number, 
   knit the .rmd file as an html, and submit both the .rmd and the .html files 
   on Canvas.
   
1. List any collaborators in the section below.

# Collaborators

# Setup

Do whatever setup you do here, such as loading libraries

```{r setup}
# Load standard libraries
library(tidyverse)
library(dplyr)
```

# Question 1
```{r}
compas <- read.csv(file="/Users/Kelly/Desktop/UW/IMT573/pset08/compas-score-data.csv.bz2", sep = '\t')
```

# Question 2
```{r}
compas <- compas %>% 
  filter(race == "Caucasian" | race == "African-American")
```

# Question 3
```{r}
compas <- compas %>% 
  mutate(high_risk = ifelse(decile_score <= 4,
                       0,
                       1))
```

# Question 4.a
The recidivism rate for low-risk individuals is 32%.
The recidivism rate for high-risk individuals is 63%.
```{r}
low_compas <- compas %>% 
  filter(high_risk == 1) %>% 
  summarize(recid_low = mean(two_year_recid))

high_compas <- compas %>%
  filter(high_risk == 0) %>% 
  summarize(recid_high = mean(two_year_recid))

low_compas
high_compas

```

# Question 4.b
The recidivism rate for African-Americans is 52%.
The recidivism rate for Caucasians is 39%.
```{r}
africans <- compas %>% 
  filter(race == "African-American") %>% 
  summarize(recid_african = mean(two_year_recid))

caucasian <- compas %>%
  filter(race == "Caucasian") %>% 
  summarize(recid_caucasian = mean(two_year_recid))

africans
caucasian

```

# Question 5
In the confusion matrix, TN = 1872, FN = 881, FP = 923, TP = 1602.
The accuracy rate is 66%, which means the COMPAS correctly predicted 65% of all people in the dataset, no matter it's true positives or true negatives. That also means that there are 34% of individuals in the dataset are classified wrong.
The precision rate is 63%, which means the individuals who are predicted as positive, 63% of them are actually true positives, and the remaining 37% are false positives. There are 37% of the individuals who were classified as high risk while they did not actually recidivate in two years.
```{r}
matrix <- table(compas$two_year_recid, compas$high_risk)
matrix

accuracy = (1872+1602)/5278
accuracy

precision = 1602/(923+1602)
precision
```
# Question 6
COMPAS has 65% correct prediction on true positives and true negatives. There is no data showing the accuracy of human judges. I would say 65% is higher than I thought, however, it would be great if it can be larger than 75%. 

# Question 7.a
The accuracy rate for African-Americans is 65%, and for Caucasians is 67%.
```{r}
african_data <- compas %>% 
  filter(race == "African-American")

african_matrix <- table(african_data$two_year_recid, african_data$high_risk)
african_matrix

african_acc = (873+1188)/3175
african_acc

white_data <- compas %>% 
  filter(race == "Caucasian")

white_matrix <- table(white_data$two_year_recid, white_data$high_risk)
white_matrix

white_acc = (999+414)/2103
white_acc

```
# Question 7.b
The false positive rate for African_Americans is 42%, and for Caucasians is 22%.
This means the prediction of the African_Americans to recidivate while they did not actually commit any crime in two years is 20% higher compared to white people.
```{r}
african_fpr = 641/(873+641)
african_fpr

white_fpr = 282/(999+282)
white_fpr
```

# Question 7.c
The false negative rate for African_Americans is 28%, and for Caucasians is 50%.
This means the prediction of the African_Americans that will not commit crime while they actually did in two years is 22% lower compared to white people.
```{r}
african_fnr = 473/(473+1188)
african_fnr

white_fnr = 408/(408+414)
white_fnr
```

# Question 8
I personally do not think COMPAS algorithm is fair. From the analysis, we know that the accuracy rates for black people and white people are really similar (65% for black people and 67% for white people). However, we can see huge differences from the false positives and false negatives number between these two races. Black people were predicted to be at a higher risk of recidivism than they actually were, and were 20% higher to be misclassified compared to white people. On the other hand, white people were predicted to be less risky than they were. We can see from the analysis that White people who committed crime within the next two years were misclassified as low risk almost twice as much as Black people (Black is 28% while White is 50%). Even though the accuracy rates for both Black and White people are very close, it is not ethical and not right to have bias because of the ethnicity or race. It would cause many wrong judgments on innocent people or people who will actually commit crime in the future.







