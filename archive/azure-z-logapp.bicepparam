using './azure-z-logapp.bicep'

param subscriptionId = ''
param name = ''
param location = ''
param use32BitWorkerProcess = false
param ftpsState = ''
param storageAccountName = ''
param netFrameworkVersion = ''
param sku = ''
param skuCode = ''
param workerSize = ''
param workerSizeId = ''
param numberOfWorkers = ''
param hostingPlanName = ''
param serverFarmResourceGroup = ''
param alwaysOn = false
param vnetPrivatePortsCount = 0

