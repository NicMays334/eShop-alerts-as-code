variable "AZ_SUBSCRIPTION_ID" {
    type        = string
    description = "Subscription ID"
}

variable "AZ_CLIENT_ID" {
    type        = string
    description = "Client ID"
}

variable "AZ_CLIENT_SECRET" {
    type        = string
    description = "Client Secret"
}

variable "AZ_TENANT_ID" {
    type        = string
    description = "Tenant ID"
}

variable "logAnalyticsResourceID" {
    type        = string
    description = "Resource ID of the Log Analytics workspace."
}

variable "logAnalyticsResourceGroupName"{
    type        = string
    description = "Name of Resource Group containing Log Analytics workspace"
}

variable "resourceRegion" {
    type        = string
    default     = "eastus2"
    description = "Location for the resource(s)."
}

variable "alertActionGroups" {
    type        = list(string)
    default     = []
    description = "Action group(s) for the alerts"
}

variable "webHookPayLoad" {
    type        = string
    default     = "{}"
    description = "Custom payload to be sent with the alert"
}

variable "SLOs" {
    type = map(object({
        userJourneyCategory = string, 
        sloCategory         = string,
        sloPercentile       = string,
        sloDescription      = string,
        signalQuery         = string,
        signalSeverity      = string,
        frequency           = number, 
        time_window         = number,
        triggerOperator     = string,
        triggerThreshold    = number
    }))
}