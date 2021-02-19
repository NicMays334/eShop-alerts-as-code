variable "logAnalyticsResourceID" {
    type = string
    description = "Resource ID of the Log Analytics workspace."
}

variable "logAnalyticsResourceGroupName"{
    type = string
    description = "Name of Resource Group containing Log Analytics workspace"
}

variable "resourceRegion"{
    type = string
    default = "eastus2"
    description = "Location for the resource(s)."
}

variable "SLOs" {
    type=map(object({
        userJourneyCategory = string,
        sloCategory = string,
        sloPercentile = string,
        sloDescription = string,
        signalQuery = string,
        signalSeverity = string,
        frequency = number,
        time_window = number,
        triggerOperator = string,
        triggerThreshold = number
    }))
    
}