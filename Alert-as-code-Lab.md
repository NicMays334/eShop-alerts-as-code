#### Automated Alert Deployment

Customer-Focused SLOs are generally comprised of the same components for the same SLO type regardless of the user journey it's describing. If we were to look at an SLO for Availability or Success-Rate the components would be:

- Target, or level of reliability 
- User journey category
- Time window
- Success Criteria 

Consider the eShop on Containers SLO for success-rate for "View Catalog":

` 99.9% of "/catalog" requests in the last 60 mins were successful (HTTP Response Code: 200) as measured at the API Gateway`

We can map different pieces of the SLO to the components listed above:

- Target, or level of reliability &rarr; `99.9%`
- User journey category &rarr; `"/catalog" requests`
- Time window &rarr; `in the last 60 minutes`
- Success Criteria &rarr; `were successful (HTTP Response Code: 200) as measured at the API Gateway`

For another user journey we could reuse the same structure and components for another availability SLO, adjusting the values to reflect the SLOs requirements for the respective user journey. Given this convenience we're presented with the opportunity to not only maintain our SLOs as code, but to deploy the alerts for these SLOs with technology like Terraform or Azure Resource Manager (ARM) Templates.

These next steps explain how to deploy SLO alerts to Azure utilizing terraform. Terraform is an open-source software tool to manage infrastructure as code. 

Get started with Terraform with Azure [here](https://learn.hashicorp.com/collections/terraform/azure-get-started). 

To create alerts for SLOs we want to deploy a collection of `scheduled query rules alert` resources to Azure. Terraform's documentation for this resource can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert). However this is the basic structure of the resource.

```json
# example scheduled query rules alert
resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = <alert rule name>
  location            = <resource location>
  resource_group_name = <resource group name>

  action {
    action_group           = [] 
    email_subject          = "Email Header"
    custom_webhook_payload = "{}"
  }
  data_source_id = <Log analytics resource id>
  description    = "<description of the alert>"
  enabled        = true
  query       = <<-QUERY
  	<KQL query describing your alert>
  QUERY
  severity    = 1
  frequency   = 5
  time_window = <time window>
  trigger {
    operator  = "GreaterThan"
    threshold = 3
  }
}
```



In `variables.tf` we have parameterized any fields that will be reused throughout the deployment of these SLOs. This file declares the structure of variables which we provide values for later.

```json
# variables.tf
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
```



The `SLOs` variable is a `map` of type `object` which will later allow you to declare a collection of objects to represent your SLOs as code. Each component of the SLO object is used to create the scheduled query alert. You can see how many of these components of the object map back to the example of the scheduled query alert rule resource. Other components are used to create naming conventions and to fully describe the SLO as code. 

In `sched_query_rules_alert.auto.tfvars` we supply values to the variables declared in `variables.tf`. These will be picked up automatically by the Terraform commands in the main deployment file because we supplied the extension `.auto.tfvars`. 

```json
# sched_query_rules_alert.auto.tfvars
logAnalyticsResourceID="" #Your Log Analytics Resource ID
logAnalyticsResourceGroupName="" #Resource Group Name where you've created your Log Analytics Resource 
resourceRegion="eastus2"

# SLOs as Code Example 
SLOs = {
    "View Catalog-SuccessRate" = {
        userJourneyCategory = "View Catalog",
        sloCategory         = "SuccessRate",
        sloPercentile       = ""
        sloDescription      = "99.9% of \"/catalog\" request in the last 60 mins were successful (HTTP Response Code: 200) as measured at API Gateway",
        signalQuery         = <<-EOT
            AppRequests
                | where Url !contains "localhost" and Url !contains "/hc"
                | extend httpMethod = tostring(split(Name, ' ')[0])
                | where Name contains "Catalog"
                | summarize succeed = count(Success == true), failed = count(Success == false), total=count() by bin(TimeGenerated, 60m)
                | extend AggregatedValue = todouble(succeed) * 10000 / todouble(total)
        EOT
        signalSeverity      = 4,
        frequency           = 60,
        time_window         = 60,
        triggerOperator     = "LessThan",
        triggerThreshold    = 9990
    },

    "Login-SuccessRate" = {
        userJourneyCategory = "Login",
        sloCategory         = "SuccessRate",
        sloPercentile       = ""
        sloDescription      = "99.9% of \"login\" request in the last 60 mins were successful (HTTP Response Code: 200) as measured at API Gateway ",
        signalQuery         = <<-EOT
            AppRequests
                | where Url !contains "localhost" and Url !contains "/hc"
                | extend httpMethod = tostring(split(Name, ' ')[0])
                | where Name contains "login"
                | summarize succeed = count(Success == true), failed = count(Success == false), total=count() by bin(TimeGenerated, 60m)
                | extend AggregatedValue = todouble(succeed) * 10000 / todouble(total)
        EOT
        signalSeverity      = 4,
        frequency           = 60,
        time_window         = 60,
        triggerOperator     = "LessThan",
        triggerThreshold    = 9990
    }
}
```

The values for `logAnalyticsResourceID` and `logAnalyticsResourceGroupName` are specific your resources in your Azure subscription. After your deploy a `Log Analytics workspace` to your Azure subscription, navigate to the resource and the `Overview` tab in the blade menu. In the top left select `JSON View` and it will let you copy the resource ID to your clipboard and supply it to this file.

Refer to the SLOs object, which is similar to a JSON Object, instead of using the `:` operator to represent key value pairings, in terraform we use the `=` operator to represent key value parings. We map each component declared in `variables.tf` to describe the respective SLOs. The queries are delimited using Heredoc syntax starting with `<<-EOT` and ending with `EOT` so we do not need to escape characters within our query. 

This collection of SLOs in the `SLOs` variable will become our SLOs as code and gives us a maintainable way to deploy SLOs. 

Lastly in `main.tf` we take the orchestration of the variable files and finally implement them for deployment.

```json
# main.tf

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
```



The first line in the resource declaration is `for_each = var.SLOs` which accesses the `SLOs` variable declared in `sched_query_rules_alert.auto.tfvars`. This will iterate over each object declared in the `SLOs` variable. Since we declared 2 SLO objects in the `SLOs` variables, 2 resources will be deployed. Each component of the SLO objects can be accessed respectively via `each.value["<variable name>"]`. Normal variables are accessed via `var.<variable name>`. This iteration over the objects contained in the variable lets us deploy many alerts for SLOs in one deployment and can be utilized in our CI/CD pipelines. 



 

















