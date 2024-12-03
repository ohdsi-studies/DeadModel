install.packages("devtools")
# If you dont have PatientLevelPrediction installed uncomment the 2 lines below and run:
#devtools::install_github("OHDSI/FeatureExtraction")
#devtools::install_github("OHDSI/PatientLevelPrediction")

# When you have PatientLevelPrediction installed run:
devtools::install_github("ohdsi-studies/DeadModel")

# Example using Eunomia
connectionDetails <- Eunomia::getEunomiaConnectionDetails()
con <- DatabaseConnector::connect(connectionDetails)
Eunomia::createCohorts(
  connectionDetails = connectionDetails
  )

cohortTableView <- DatabaseConnector::querySql(con, 'select * from main.cohort where cohort_definition_id = 4')

# create demo cohort2 table in my scratch schema 
DatabaseConnector::insertTable(
  connection = con, 
  databaseSchema = 'main', 
  tableName = 'cohort2', 
  data = cohortTableView[1:10,], 
  createTable = T,
  dropTableIfExists = F
  )


# now apply the Dead model:
pred <- DeadModel::applyDeadModel(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = 'main', 
  cdmDatabaseName = 'Eunomia', 
  cohortDatabaseSchema = 'main', 
  cohortTable = 'cohort', 
  cohortId = 4 # NSAID
  )

# now using the cohort table I created on lines 19-26
# that only contains 10 patients
pred2 <- DeadModel::applyDeadModel(
  connectionDetails = connectionDetails, 
  cdmDatabaseSchema = 'main', 
  cdmDatabaseName = 'Eunomia', 
  cohortDatabaseSchema = 'main', 
  cohortTable = 'cohort2', 
  cohortId = 4 # NSAID
)

