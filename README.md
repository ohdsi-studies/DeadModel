Identifying the DEAD: Development and Validation of a Patient-Level Model to Predict Death Status in Population-Level Claims Data
=============

<img src="https://img.shields.io/badge/Study%20Status-Complete-orange.svg" alt="Study Status: Complete"> 

- Analytics use case(s): **Patient-Level Prediction**
- Study type: **Clinical Application**
- Tags: **-**
- Study lead: **Jenna Reps**
- Study lead forums tag: **[jreps](https://forums.ohdsi.org/u/jreps)**
- Study start date: **Jan 1, 2018**
- Study end date: **April 1, 2018**
- Protocol: **-**
- Publications: **[Paper](https://link.springer.com/article/10.1007/s40264-019-00827-0)**
- Results explorer: **[Shiny App](http://data.ohdsi.org/DeadImputation/)**

This package contains the DEAD risk model - using the last 365 days what is the risk that the patient with an end of observation is dead?


Features
========
  - code to validate the death model on data with death status recorded
  - code to create a death risk covariate
  - code to predict the current alive or dead status

Technology
==========
  DeadModel is an R package.

System Requirements
===================
  Requires R (version 3.3.0 or higher).

Dependencies
============
  * PatientLevelPrediction

Getting Started
===============
  1. In R, use the following commands to download and install:

  ```r
install.packages("devtools")
# If you dont have PatientLevelPrediction installed uncomment the 2 lines below and run:
#devtools::install_github("OHDSI/FeatureExtraction")
#devtools::install_github("OHDSI/PatientLevelPrediction")

# When you have PatientLevelPrediction installed run:
devtools::install_github("ohdsi-studies/DeadModel")

library(DeadModel)

#==============
# EXPLORE
#==============
# To view the model coefficients:
viewDeadCoefficients()

#==============
# APPLY
#==============
# INPUTS:
dbms <- "pdw"
user <- NULL
pw <- NULL
server <- Sys.getenv('server')
port <- Sys.getenv('port')

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)
outputLocation <- file.path(getwd(),'Death Risk')
cdmDatabaseSchema <- 'CDM database schema'
cohortDatabaseSchema <- 'cohort database schema'
cohortTable <- 'cohortTable containing people who you want to predict risk of being dead'
cohortId <- 'cohortDefinitionId for target cohort people in cohortTable'

outcomeId <- '(if externally validating model) cohortDefinitionId for dead people in cohortTable'

# code to do prediction for each patient in the cohortTable with cohort_definition_id 1
prediction <- applyDeadModel(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                cohortDatabaseSchema = cohortDatabaseSchema,
                                oracleTempSchema = NULL,
                                cohortTable = cohortTable,
                                cohortId=cohortId)

# code to externall validate the model
validation <- validateDeadModel(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     oracleTempSchema = NULL,
                     cohortTable = cohortTable,
                     targetId = cohortId,
                     outcomeId = outcomeId)
                     

```

License
=======
  DeadModel is licensed under Apache License 2.0

Development
===========
  DeadModel is being developed in R Studio.

