# Configure the Azure provider
terraform {
    required_providers {
        azurerm = {
                source = "hashicorp/azurerm"
                version = ">= 2.26"
        }
    }
}

provider "azurerm" {
    features {}
}

#Deploy a sample log query alert
resource "azurerm_monitor_scheduled_query_rules_alert" "Samplelogqueryalert" {
    name                = "sample-qa-1"
    location            = var.resourceRegion
    resource_group_name = var.logAnalyticsResourceGroupName

    action {
        action_group           = []
        email_subject          = "Email Header"
        custom_webhook_payload = "{}"
    }

    data_source_id = var.logAnalyticsResourceID
    description    = "<SLO Description> "
    enabled        = true
    query       = <<-QUERY
    Event 
        | where EventLevelName == "Error" | summarize count() by Computer
    QUERY
    
    severity    = 4
    frequency   = 15
    time_window = 60
    
    trigger {
        operator  = "GreaterThan"
        threshold = 1
    }
}
