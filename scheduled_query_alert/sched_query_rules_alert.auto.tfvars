logAnalyticsResourceID="/subscriptions/418cdf66-3b71-491f-b462-ad1f6658b7a3/resourceGroups/eShop-Alert-Automation/providers/Microsoft.OperationalInsights/workspaces/la-eshop"
logAnalyticsResourceGroupName="eShop-Alert-Automation"
resourceRegion="eastus2"

SLOs = {
    "Catalog-SuccessRate" = {
        userJourneyCategory = "Catalog",
        sloCategory = "SuccessRate",
        sloPercentile = ""
        sloDescription = "99.99% of Catalog requests in the last 5 minutes were successful",
        signalQuery = <<-EOT
            AppRequests
                | where Url !contains "localhost" and Url !contains "/hc"
                | extend httpMethod = tostring(split(Name, ' ')[0])
                | where Name contains "Catalog"
                | summarize succeed = count(Success == true), failed = count(Success == false), total=count() by bin(TimeGenerated, 60m)
                | extend AggregatedValue = todouble(succeed) * 10000 / todouble(total)
        EOT
        signalSeverity = 4,
        frequency = 5,
        time_window = 60,
        triggerOperator = "GreaterThan",
        triggerThreshold = 1
    },
    
    "Basket-SuccessRate" = {
        userJourneyCategory = "Basket",
        sloCategory = "SuccessRate",
        sloPercentile = ""
        sloDescription = "99.99% of Basket requests in the last 5 minutes were successful",
        signalQuery = <<-EOT
            AppRequests
                | where Url !contains "localhost" and Url !contains "/hc"
                | extend httpMethod = tostring(split(Name, ' ')[0])
                | where Name contains "Basket"
                | summarize succeed = count(Success == true), failed = count(Success == false), total=count() by bin(TimeGenerated, 60m)
                | extend AggregatedValue = todouble(succeed) * 10000 / todouble(total)
        EOT
        signalSeverity = 4,
        frequency = 5,
        time_window = 60,
        triggerOperator = "GreaterThan",
        triggerThreshold = 1
    }
}