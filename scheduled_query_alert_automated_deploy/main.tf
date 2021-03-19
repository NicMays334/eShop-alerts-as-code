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
    subscription_id = var.SUBSCRIPTION_ID_ONE
    client_id       = var.TENANT_ID_CLIENT_ID_ONE
    client_secret   = var.ARM_CLIENT_SECRET
    tenant_id       = var.ARM_TENANT_ID
    features {}
}

#Deploy a sample log query alert
resource "azurerm_monitor_scheduled_query_rules_alert" "SLO_ALERT" {
    for_each            = var.SLOs
    name                = format("%s-%s%s", each.value["userJourneyCategory"], each.value["sloCategory"], 
                            each.value["sloPercentile"])
    location            = var.resourceRegion
    resource_group_name = var.logAnalyticsResourceGroupName

    action {
        action_group           = var.alertActionGroups
        email_subject          = format("Alert - SLO Breach: %s-%s%s", each.value["userJourneyCategory"], 
                                    each.value["sloCategory"], each.value["sloPercentile"])
        custom_webhook_payload = var.webHookPayLoad
    }

    data_source_id = var.logAnalyticsResourceID
    description    = each.value["sloDescription"]
    enabled        = true
    query          = <<-QUERY
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
