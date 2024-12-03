# Copyright 2018 Observational Health Data Sciences and Informatics
#
# This file is part of Dead Risk Model
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#==========================
#  Validate death model in plpData with death outcome
#==========================
#' Validate death plp prediction model
#'
#' @details
#' This will run and evaluate an exisitng death plpModel
#'
#' @param connectioDetails The connections details for connecting to the CDM
#' @param cdmDatabaseSchema  The schema holding the CDM data
#' @param cdmDatabaseName  A friendly name for the database
#' @param cohortDatabaseschema The schema holding the cohort table
#' @param tempEmulationSchema  The temp schema for oracle (default is NULL)
#' @param cohortTable         The name of the cohort table
#' @param targetId          The cohort definition id of the target population
#' @param outcomeId         The cohort definition id of the outcome
#'
#' @return
#' A list with the performance and plots
#'
#' @export
validateDeadModel <- function(connectionDetails,
                                   cdmDatabaseSchema,
                                   cdmDatabaseName = cdmDatabaseSchema,
                                   cohortDatabaseSchema,
                              tempEmulationSchema = NULL,
                                   cohortTable,
                                   targetId,
                                   outcomeId,
                                   packageName='DeadModel'){

  plpModel <- PatientLevelPrediction::loadPlpModel(system.file('model', package=packageName))
  writeLines('Implementing DEAD model...')
  result <- PatientLevelPrediction::externalValidateDbPlp(
    plpModel = plpModel,
   validationDatabaseDetails = PatientLevelPrediction::createDatabaseDetails(
     connectionDetails=connectionDetails,
     cdmDatabaseSchema = cdmDatabaseSchema,
     cdmDatabaseName = cdmDatabaseName,
     tempEmulationSchema =  tempEmulationSchema,
     cohortDatabaseSchema = cohortDatabaseSchema,
     cohortTable = cohortTable,
     outcomeDatabaseSchema = cohortDatabaseSchema,
     outcomeTable = cohortTable,
     targetId = targetId,
     outcomeIds = outcomeId
   ),
   validationRestrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings()
     )

  return(result)
}


#==========================
#  Predict risk of death in new population
#==========================

#' Applies death risk model to new cohort
#'
#' @details
#' This will return a predicted risk of being dead at the cohort_start_date for each subject_id in the cohort
#'
#' @param connectionDetails The connection details to connect to a database
#' @param cdmDatabaseSchema  The common data model schema
#' @param cdmDatabaseName  A friendly name for the database
#' @param cohortDatabaseSchema  The database schema containing the cohort you wish to apply the death risk prediction to
#' @param tempEmulationSchema  The temp schema for oracle (default is NULL)
#' @param cohortTable   The table containing the cohort you want to apply the death risk model to
#' @param cohortId   The cohort_definition_id defining the cohort you wish to apply the death risk model to
#'
#' @return
#' A dataframe with each subjectId and cohortStartDate in the cohort with the predicted death risk as the column 'value'
#'
#' @export
applyDeadModel <- function(connectionDetails,
                              cdmDatabaseSchema,
                           cdmDatabaseName,
                              cohortDatabaseSchema,
                           tempEmulationSchema = NULL,
                              cohortTable,
                              cohortId){

  plpModel <- PatientLevelPrediction::loadPlpModel(system.file('model', package='DeadModel'))

  checkIsClass(plpModel, 'plpModel')

  validationDatabaseDetails <- PatientLevelPrediction::createDatabaseDetails(
    connectionDetails= connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cdmDatabaseName = cdmDatabaseName,
    tempEmulationSchema =  tempEmulationSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTable,
    outcomeDatabaseSchema = cohortDatabaseSchema,
    outcomeTable = cohortTable,
    targetId = cohortId,
    outcomeIds = -999
  )

    ParallelLogger::logInfo(paste('Validating model on', cdmDatabaseName))

    # Step 1: get data
    #=======

    getPlpDataSettings <- list(databaseDetails = validationDatabaseDetails,
                               restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings())

    getPlpDataSettings$covariateSettings <-
      plpModel$modelDesign$covariateSettings

    plpData <- tryCatch({
      do.call(getPlpData, getPlpDataSettings)
    },
    error = function(e) {
      ParallelLogger::logError(e)
      return(NULL)
    })


    # Step 2: Apply model to plpData and population
    #=======

    result <- PatientLevelPrediction::predictPlp(
      plpModel = plpModel,
      plpData = plpData,
      population = plpData$cohort
      )

    return(result)
}


#' View DEAD prediction model coefficients
#'
#' @details
#' This will show a table with the covaraite name and coefficient value
#'
#'
#' @return
#' NULL
#'
#' @export
viewDeadCoefficients <- function(packageName='DeadModel'){

  plpModel <- PatientLevelPrediction::loadPlpModel(system.file('model', package=packageName))

  covs <- plpModel$covariateImportance[!is.na(plpModel$covariateImportance$covariateValue),]
  covs <- covs[covs$covariateValue!=0,]
  covs <- covs[order(-abs(covs$covariateValue)),]

  result <- covs[,c('covariateName','covariateValue')]
  View(result)
}
