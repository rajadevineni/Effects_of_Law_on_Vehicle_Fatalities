# Effects_of_Law_on_Vehicle_Fatalities

>This project was undertaken as academic study to understand and apply the concepts of **BUAN 6312-Applied Econometrics and Time Series Analysis for Business Analytics**. The data set chosen by the course instructor and the analysis done as part of this project is not representative of the overall statistics.

## Introduction:
Do laws like Tax on Case of Beer ($), Mandatory Jail Sentence, Mandatory Community Service,  Minimum Legal Drinking Age  affect Number of Vehicle Fatalities in the United States of America? Various hypothesis are tested and found some surprising results.


## Dataset: 
The Dataset consists of data on 48 states over 7 years, 1982-1988. This is panel data where State and Year are considered as indices, however the regressions models are developed on Pooled, Fixed and Random methods. Multiple methods are developed in this project but only the final models (1-pooled & 1-fixed) are detailed below(verify the code for other models). 
The explanatory variables in models are choosen on general economic terms where we usually think there would be a relationship between the # vehicle fatalities and explanatory variables. 

The complete description of the dataset is available [**here**](https://github.com/rajadevineni/Effects_of_Law_on_Vehicle_Fatalities/blob/master/CarFatality_Dataset_Description.docx)

## Basic Findings: 

**Top 6 states with highest average State Unemployement rate(UNR)**

	State | Unemployement rate 
	----- | ------------------ 
	   WV | 13.20
	   LA | 11.37
	   MI | 10.77
	   MS | 10.71
	   AL | 10.41
	   KY | 09.58

**Top 6 states with highest average Mortality rate**

	State | Mortality rate 
	----- | -------------- 
	  NM  | 0.0003653197
	  WY  | 0.0003217534
	  MT  | 0.0002903021
	  SC  | 0.0002821669
	  MS  | 0.0002761846
	  NV  | 0.0002745260

>***Mississipi is the only state that has both highest UNR and Moratality rate***

* 21037 Vehicle fatalities involve 15-17 year olds during 1982-1988
* 35838 Vehicle fatalities involve 18-20 year olds during 1982-1988
* 42629 Vehicle fatalities involve 21-24 year olds during 1982-1988
* 98560 Vehicle fatalities involve **alcohol** during 1982-1988

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
![model_ols_2 summary](/Plots%26Graphs/OLS_Model.png)

* *Despite having very good R-squared value and other metrics, a model may have heteroskedasticity. Such models Std.Error are not reliable hence we need to find heteroskedastisity in the model and remove if exists.* 

### Handling heteroskedasticity: 

The plot below shows that there a greater degree of variance in the fitted values when going towards right, hence proving the existence of heteroskedasticity.

![OLS residuals plot](/Plots%26Graphs/ols_residual.png)

#### Summary of model_ols_2 after removing heteroskedasticity:

![OLS Robust Standard Errors](/Plots%26Graphs/OLS_Robust_Errors.png)

#### OLS Models - AIC & BIC:

![AIC-BIC values](/Plots%26Graphs/OLS%20AIC_BIC.png)

## Correlation graphs of key variable:

The correlation graphs below are between key variables which are part of regression models.

![BTvsVF](/Plots%26Graphs/BT_VS_VF.png)
![UNR vs VF](/Plots%26Graphs/UNR%20vs%20VF.png)
![AlcvsVF](/Plots%26Graphs/AlcvsVF.png)
![1820vsVF](/Plots%26Graphs/1820vsVF.png)

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
~~~

* Variables in the first model **model_fixed** have some common variables considered in OLS-models. But the variable **"comserd - Mandatory Community Service"** which was considered as statistically significant is no longer in the fixed effects model, **model_fixed**. 

* In general we think that jail sentenses would reduce the vehicle fatalities but cosidering the model, **model_fixed. "jaild - Mandatory Jail Sentence"** is not statistically significant which is unusual.

* Although for panel data, fixed effects model has better co-efficients and standatrd error than the OLS model. Their standard errors are not very reliable. IN this case we go with Random effects model for better Std.Errs. 

### Random Effects Model:

Random effects model are also built considering the same variables as the fixed effects models. 

~~~
model_random_1 <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517+ pop1820,
                      model='random',data = total_data_frame)
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

