# Effects_of_Law_on_Vehicle_Fatalities

>This project was undertaken as academic study to understand and apply the concepts of **BUAN 6312-Applied Econometrics and Time Series Analysis for Business Analytics**. The data set chosen by the course instructor and the analysis done as part of this project is not representative of the overall statistics.

## Introduction:
Do laws like Tax on Case of Beer ($), Mandatory Jail Sentence, Mandatory Community Service,  Minimum Legal Drinking Age  affect Number of Vehicle Fatalities in the United States of America? Various hypothesis are tested and found some surprising results.


## Dataset: 
The Dataset consists of data on 48 states over 7 years, 1982-1988. This is panel data where State and Year are considered as indices, however the regressions models are developed on **Pooled, Fixed and Random methods**. Multiple methods are developed in this project but only the final models (1-pooled & 1-fixed) are detailed below(verify the code for other models). 
The explanatory variables in models are choosen on general economic terms where we usually think there would be a relationship between the # vehicle fatalities and explanatory variables. 

The complete description of the dataset is available [**here**](https://github.com/rajadevineni/Effects_of_Law_on_Vehicle_Fatalities/blob/master/CarFatality_Dataset_Description.docx)

## Basic Findings: 

**Top 6 states with highest average State Unemployement rate(UNR)**

State | Unemployement rate 
----- | ------------------ 
WV |    13.20
LA | 	11.37
MI | 	10.77
MS | 	10.71
AL | 	10.41
KY | 	09.58

**Top 6 states with highest average Mortality rate**

State | Mortality rate 
----- | -------------- 
NM | 0.0003653197
WY | 0.0003217534
MT | 0.0002903021
SC | 0.0002821669
MS | 0.0002761846
NV | 0.0002745260

* **Mississipi** is the only state that has both highest **UNR and Moratality rate**
* **21037** Vehicle fatalities involve **15-17 year olds** during 1982-1988
* **35838** Vehicle fatalities involve **18-20 year olds** during 1982-1988
* **42629** Vehicle fatalities involve **21-24 year olds** during 1982-1988
* **98560** Vehicle fatalities involve **alcohol** during 1982-1988

## Relationships among variables:

### Correlation Matrix of all variables:

![Correlation matrix of all the variables](/Plots%26Graphs/Corr_matrix_all.png)

## Pooled-OLS Regression: 

~~~
model_ols <- lm(allmort ~ dry +beertax + jaild + aidall + mlda + unrate + perinc + allnite + comserd,
                data = total_data_frame)

model_ols_1 <- lm(allmort ~  dry + unrate + allnite + beertax + comserd ,
                  data = total_data_frame)

model_ols_2 <- lm(allmort ~  dry + unrate + allnite + beertax + comserd + pop1517 + pop1820 ,
                  data = total_data_frame)
~~~
**model_ols_1** model is created based on the correlation matrix and economical significance of the variable.

**model_ols_1** model is created by dropping statistically insignificant variables from **model_ols** model based on **p-value & t-vaue**

**model_ols_2** model has 2 more variables pop1517 and pop1820 compared to **model_ols_1**, surprisingly the AIC and BIC values of **model_ols_2** has gone down despite adding two more variables into the model. 

### Summary of model_ols_2:
~~~
lm(formula = allmort ~ dry + unrate + allnite + beertax + comserd + 
    pop1517 + pop1820, data = total_data_frame)

Residuals:
    Min      1Q  Median      3Q     Max 
-504.17  -69.25   -2.91   74.92  888.25 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)    
(Intercept)  4.468e+01  2.765e+01   1.616 0.107017    
dry          3.606e+00  9.217e-01   3.913 0.000111 ***
unrate      -1.472e+01  3.373e+00  -4.363 1.72e-05 ***
allnite      3.762e+00  1.319e-01  28.518  < 2e-16 ***
beertax      1.156e+02  1.789e+01   6.460 3.79e-10 ***
comserd      9.157e+01  2.212e+01   4.140 4.42e-05 ***
pop1517     -1.664e-03  5.012e-04  -3.321 0.000999 ***
pop1820      2.390e-03  4.745e-04   5.036 7.86e-07 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 149.5 on 327 degrees of freedom
  (1 observation deleted due to missingness)
Multiple R-squared:  0.9732,	Adjusted R-squared:  0.9726 
F-statistic:  1693 on 7 and 327 DF,  p-value: < 2.2e-16
~~~

* *Despite having very good R-squared value and other metrics, a model may have heteroskedasticity. Such models Std.Error are not reliable hence we need to find heteroskedastisity in the model and remove if exists.* 

### Handling Heteroskedasticity: 

The plot below shows that there a greater degree of variance in the fitted values when going towards right, hence proving the existence of heteroskedasticity.

![OLS residuals plot](/Plots%26Graphs/ols_residual.png)

#### Summary of model_ols_2 after removing heteroskedasticity:

![OLS Robust Standard Errors](/Plots%26Graphs/OLS_Robust_Errors.png)

#### OLS Models - AIC & BIC:

![AIC-BIC values](/Plots%26Graphs/OLS%20AIC_BIC.png)

## Correlation graphs of key variables:

The correlation graphs below are between key variables which are part of regression models.

![corr of key variables](/Plots%26Graphs/imp_variables.png)

![Correlogram of Variables from Pooled OLS-Model](/Plots%26Graphs/Correlogram%20of%20Variables%20from%20Pooled%20OLS-Model.png)


## Panel Data Models:

The dataset is a **panel data**,but in the first phase we have seen the data as pooled and made OLS regressions. Now, the data is considered as panel data with **"State" & "Year"** as indices.

### Fixed Effects Model:

Fixed model regression are developed with considering the same variables and hypothesis from the OLS models. **We observed that the variables which are 
statistically significant in the OLS models are not neccessarily be the same in Panel-data models.**

~~~
model_fixed <- plm(allmort ~ spircons + dry + jaild + aidall + mlda + unrate + perinc + allnite + comserd,
                   model='within',data = total_data_frame, effect = "twoways" )

model_fixed_1 <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517 + pop1820,
                     model='within',data = total_data_frame, effect = "twoways" )


Balanced Panel: n = 48, T = 7, N = 336

Residuals:
      Min.    1st Qu.     Median    3rd Qu.       Max. 
-346.76919  -26.74337   -0.99852   30.64066  221.86132 

Coefficients:
           Estimate  Std. Error t-value  Pr(>|t|)    
beertax -1.3279e+02  6.2683e+01 -2.1185   0.03503 *  
aidall   3.0352e-01  7.1268e-02  4.2589 2.823e-05 ***
unrate  -1.0002e+01  4.2569e+00 -2.3497   0.01950 *  
perinc   4.6412e-02  8.4342e-03  5.5029 8.558e-08 ***
allnite  1.8014e+00  1.9583e-01  9.1986 < 2.2e-16 ***
pop1517  2.0046e-03  3.9858e-04  5.0293 8.893e-07 ***
pop1820 -3.4886e-03  4.4599e-04 -7.8221 1.119e-13 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Total Sum of Squares:    2644200
Residual Sum of Squares: 952290
R-Squared:      0.63986
Adj. R-Squared: 0.56128
F-statistic: 69.7985 on 7 and 275 DF, p-value: < 2.22e-16
~~~

* Variables in the first model **model_fixed** have some common variables considered in OLS-models. But the variable **"comserd - Mandatory Community Service"** which was considered as statistically significant is no longer in the fixed effects model, **model_fixed**. 

* In general we think that jail sentenses would reduce the vehicle fatalities but cosidering the model, **model_fixed. "jaild - Mandatory Jail Sentence"** is not statistically significant which is unusual.

* Although for panel data, fixed effects model has better co-efficients and standatrd error than the OLS model. Their standard errors are not very reliable. IN this case we go with Random effects model for better Std.Errs. 

### Random Effects Model:

Random effects model are also built considering the same variables as the fixed effects models. 

~~~
model_random_1 <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517+ pop1820,
                      model='random',data = total_data_frame)


Balanced Panel: n = 48, T = 7, N = 336

Effects:
                   var  std.dev share
idiosyncratic  3759.96    61.32  0.22
individual    13313.58   115.38  0.78
theta: 0.8031

Residuals:
      Min.    1st Qu.     Median    3rd Qu.       Max. 
-311.41641  -40.15302   -0.85205   40.18391  383.06229 

Coefficients:
               Estimate  Std. Error z-value  Pr(>|z|)    
(Intercept) -1.1189e+02  1.3697e+02 -0.8168  0.414014    
beertax      1.1165e+02  4.0961e+01  2.7257  0.006416 ** 
aidall       2.4543e-01  8.9807e-02  2.7329  0.006278 ** 
unrate      -2.5205e+01  4.1560e+00 -6.0649 1.321e-09 ***
perinc       2.1827e-02  7.7302e-03  2.8236  0.004749 ** 
allnite      2.3945e+00  2.2974e-01 10.4225 < 2.2e-16 ***
pop1517      2.0203e-03  4.1460e-04  4.8729 1.100e-06 ***
pop1820     -4.4177e-04  3.8676e-04 -1.1422  0.253354    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Total Sum of Squares:    14211000
Residual Sum of Squares: 1940000
R-Squared:      0.86349
Adj. R-Squared: 0.86058
Chisq: 2074.76 on 7 DF, p-value: < 2.22e-16
~~~

The variables from fixed effects mode and random effects model are the same but their coefficients differ. 

## Fixed vs Random:

In order to determine which model is better suited for our panel data, we build a hypothesis test to determine the best model.

**Let us consider:**

	Null Hypothesis H0       : Random effects model is better than Fixed effects model.
	Alternative Hypothesis H1: Fixed effects model is better than Random effects model.

* We perform a **Hausman test** to validate our hypothesis. 

![Hausman Test](/Plots%26Graphs/Hausman%20test.png)


>**From Hausman test we can reject the null hypothesis that Random effects model is better and consider to go with Fixed effects model**


## Conclusion: 

*The data we have is only for 7 years which is far less when compared to the history of evolution of transportation. Some policies might have changed before or after the given years in the data set. This may be a reason why we couldn't find a significance dependency of Vehicle Fatalities on very strong policies like "Beer tax (beertax)". Some states may have more hilly areas which would have accident prone areas resulting in increase of Vehicle Fatalities. Some states may have bad road conditions which may also lead to accidents involving heavy vehicles. We can explain the data more robustly and accurately by including more years of data or some variables like "Road conditions", "Number of Dangerous routes", “Busy roads”.*

