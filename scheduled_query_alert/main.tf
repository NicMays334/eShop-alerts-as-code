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
    for_each            = var.SLOs
    name                = join("", [each.value["userJourneyCategory"], "-", each.value["sloCategory"], each.value["sloPercentile"]])
    location            = var.resourceRegion
    resource_group_name = var.logAnalyticsResourceGroupName

    action {
        action_group           = []
        email_subject          = "Email Header"
        custom_webhook_payload = "{}"
    }

    data_source_id = var.logAnalyticsResourceID
    description    = each.value["sloDescription"]
    enabled        = true
    query       = <<-QUERY
        ${each.value["signalQuery"]}
    QUERY
    
    severity    = each.value["signalSeverity"]
    frequency   = each.value["frequency"]
    time_window = each.value["time_window"]
    
    trigger {
        operator  = each.value["triggerOperator"]
        threshold = each.value["triggerThreshold"]
    }
}
