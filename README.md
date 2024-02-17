# Goal
1. Use confusion matrices to understand a recent controversy around racial equality and criminal justice system.
2. Use logistic regression skills to develop and validate a model, analogous to the proprietary COMPAS model that caused the above-mentioned controversy.

# Background
Correctional Offender Management Profiling for Alternative Sanctions (COMPAS) algorithm is a commercial risk assessment tool that attempts to estimate a criminal defendent’s recidivism (when a criminal reoffends, i.e. commits another crime). COMPAS is reportedly one of the most widely used tools of its kind in the US. It is often used in the US criminal justice system to inform sentencing guidelines by judges, although specific rules and regulations vary. 

In 2016, ProPublica published an investigative report (https://shorturl.at/clS34) arguing that racial bias was evident in the COMPAS algorithm. ProPublica had constructed a dataset from Florida public records, and used logistic regression and confusion matrix in its analysis. COMPAS’s owners disputed this analysis, and other academics (https://shorturl.at/vPYZ3) noted that for people with the same COMPAS score, but different races, the recidivism rates are effectively the same. 

The COMPAS algorithm is proprietary and not public. We know it includes 137 features, and deliberately excludes race. However, another study (https://www.science.org/doi/10.1126/sciadv.aao5580) showed that a logistic regression with only 7 of those features was equally accurate!

# Data Source
The dataset is based off ProPublica’s dataset (https://www.propublica.org/article/how-we-analyzed-the-compas-recidivism-algorithm), compiled from public records in Florida. However, it has been cleaned up for simplicity. 

#### Variables
```
c_charge_degree    Classifier for an individual’s crime–F for felony, M for misdemeanor
race               Classifier for the recorded race of each individual in this dataset.
                   We will only be looking at “Caucasian”, and “African-American” here
age_cat            Classifies individuals as under 25, between 25 and 45, and older than 45
sex                Classifier for the recorded sex of each individual in this dataset. Male or female.
priors_count       Numeric, the number of previous crimes the individual has committed.
decile_score       COMPAS classification of each individual’s risk of recidivism (1 = low . . . 10 = high).
                   This is one of the crucial variables in the data, the number that the proprietary COMPAS algorithm assigns to all defendants.
two_year_recid     Binary variable, 1 if the individual recidivated within 2 years, 0 otherwise.
```

# Data Exploration
### 0. Set up
Load library and import file.
```
library(tidyverse)
library(dplyr)
compas <- read.csv(file=".../compas-score-data.csv.bz2", sep = '\t')
```
### 1. Data cleaning
Making sure if there's any missing or unreasonable data, and clean those data. Filter the data to keep only only Caucasians and African-Americans
```
compas <- compas %>% 
  filter(race == "Caucasian" | race == "African-American")
```
### 2. Data exploration
#### (1) Dummy variables
Create a new dummy variable based on the COMPAS’ risk score (decile_score), which indicates if an individual was classified as low risk (score 1-4) or high risk (score 5-10).
```
compas <- compas %>% 
  mutate(high_risk = ifelse(decile_score <= 4,
                       0,
                       1))
```

#### (2) Analyze the offenders across this new risk category:
#### (a) What is the recidivism rate for low-risk and high-risk individuals?

The recidivism rate for low-risk individuals is 32%. The recidivism rate for high-risk individuals is 63%.
```
low_compas <- compas %>% 
  filter(high_risk == 1) %>% 
  summarize(recid_low = mean(two_year_recid))

high_compas <- compas %>%
  filter(high_risk == 0) %>% 
  summarize(recid_high = mean(two_year_recid))
```
```
low_compas
##   recid_low
## 1 0.6344554
```
```
high_compas
##   recid_high
## 1  0.3200145
```
#### (b) What are the recidivism rates for African-Americans and Caucasians?
The recidivism rate for African-Americans is 52%. The recidivism rate for Caucasians is 39%.
```
africans <- compas %>% 
  filter(race == "African-American") %>% 
  summarize(recid_african = mean(two_year_recid))

caucasian <- compas %>%
  filter(race == "Caucasian") %>% 
  summarize(recid_caucasian = mean(two_year_recid))
```
```
africans
##   recid_african
## 1     0.5231496
```
```
caucasian
##   recid_caucasian
## 1       0.3908702
```

#### (3) Confusion Matrix
Now create a confusion matrix comparing COMPAS predictions for recidivism (is/is not low risk) and the actual two-year recidivism and interpret the results. To keep things consistent, I'll call recidivists “positive”.

In the confusion matrix, TN = 1872, FN = 881, FP = 923, TP = 1602. The accuracy rate is 66%, which means the COMPAS correctly predicted 65% of all people in the dataset, no matter it’s true positives or true negatives. That also means that there are 34% of individuals in the dataset are classified wrong. The precision rate is 63%, which means the individuals who are predicted as positive, 63% of them are actually true positives, and the remaining 37% are false positives. There are 37% of the individuals who were classified as high risk while they did not actually recidivate in two years.
```
matrix <- table(compas$two_year_recid, compas$high_risk)
```
```
matrix
##    
##        0    1
##   0 1872  923
##   1  881 1602
```
```
accuracy = (1872+1602)/5278
accuracy
## [1] 0.6582039
```
```
precision = 1602/(923+1602)
precision
## [1] 0.6344554
```

#### (4) Accuracy calculation
Now we calculate the confusion matrix separately for African-Americans and for Caucasians:
#### (a) How accurate is the COMPAS classification for African-American individuals? For Caucasians?
The accuracy rate for African-Americans is 65%, and for Caucasians is 67%.
```
african_data <- compas %>% 
  filter(race == "African-American")

african_matrix <- table(african_data$two_year_recid, african_data$high_risk)
```
```
african_matrix
##    
##        0    1
##   0  873  641
##   1  473 1188
```
```
african_acc = (873+1188)/3175
african_acc
## [1] 0.6491339
```
```
white_data <- compas %>% 
  filter(race == "Caucasian")

white_matrix <- table(white_data$two_year_recid, white_data$high_risk)
```
```
white_matrix
##    
##       0   1
##   0 999 282
##   1 408 414
```
```
white_acc = (999+414)/2103
white_acc
## [1] 0.6718973
```
#### (b) What are the false positive rates FPR = FP/N = FP/(FP + TN)?
(TP: True Positive, FP: False Positive, TN: True Negative, FN: False Negative.)
The false positive rate for African_Americans is 42%, and for Caucasians is 22%. This means the prediction of the African_Americans to recidivate while they did not actually commit any crime in two years is 20% higher compared to white people.
```
african_fpr = 641/(873+641)
african_fpr
## [1] 0.4233818
```
```
white_fpr = 282/(999+282)
white_fpr
## [1] 0.2201405
```
#### (c) The false negative rates FNR = FN/P = FN/(FN + TP)?
The false negative rate for African_Americans is 28%, and for Caucasians is 50%. This means the prediction of the African_Americans that will not commit crime while they actually did in two years is 22% lower compared to white people.
```
african_fnr = 473/(473+1188)
african_fnr
## [1] 0.2847682
```
```
white_fnr = 408/(408+414)
white_fnr
## [1] 0.4963504
```

# Conclusion
From the result, we can find that COMPAS’s true negative and true positive percentages are similar for African-American and Caucasian individuals, but the false positive rates and false negative rates are different. 

From the analysis, we know that the accuracy rates for black people and white people are really similar (65% for black people and 67% for white people). However, we can see huge differences from the false positives and false negatives number between these two races. Black people were predicted to be at a higher risk of recidivism than they actually were, and were 20% higher to be misclassified compared to white people. On the other hand, white people were predicted to be less risky than they actually were. We can see from the analysis that White people who committed crime within the next two years were misclassified as low risk almost twice as much as Black people (Black is 28% while White is 50%). 

Even though the accuracy rates for both Black and White people are very close, it is not ethical and not right to have bias because of the ethnicity or race. It would cause many wrong judgments on innocent people or people who will actually commit crime in the future.

