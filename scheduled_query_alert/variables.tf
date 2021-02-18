variable "logAnalyticsResourceID" {
    type = string
    description = "Resource ID of the Log Analytics workspace."
}

variable "logAnalyticsResourceGroupName"{
    type = string
    description = "Name of Resource Group containg Log Analytics workspace"
}

variable "resourceRegion"{
    type = string
    default = "eastus2"
    description = "Location for the resource(s)."
}