# Shiny in Production Application

## Stage One: POC

[Shiny in Prod App Design - Google Doc](https://docs.google.com/presentation/d/1Z9vHQz0l33KDr2ofAcy1z7uZIDGgLVcTF7lwtK02WrM/edit?usp=sharing)

### TODOS / Application Improvements:

- Create Plot Cache Plot
- Create Data Description / Drill Down

### TODOS / Data Improvements:

- Join application data back to the original to get orig. survey values
- Create actual student ID numbers
- Mix up the ID numbers so that high and low risk aren’t sorted
- Generate sep. Test data

#### Fake ML Dataset Creation Process

Two populations: high risk, low risk created with two lookup tables:
- `high-risk-lookup-rules.csv`
- `low-risk-lookup-rules.csv`

```
.
├── README.md
├── app.R
├── app1.Rproj
├── data
│   ├── appData.R
│   ├── application_data.RDS
│   └── lime_prediction_results.RDS
├── data-prep
│   ├── fake-data-gen-steps.R
│   ├── high-risk-lookup-rules.csv
│   ├── low-risk-lookup-rules.csv
│   ├── model-build-steps.R
│   └── rstudio-student-data.csv
└── www
    └── rstudio.png
```
