logAnalyticsResourceID="/subscriptions/418cdf66-3b71-491f-b462-ad1f6658b7a3/resourceGroups/eShop-Alert-Automation/providers/Microsoft.OperationalInsights/workspaces/la-eshop"
logAnalyticsResourceGroupName="eShop-Alert-Automation"
resourceRegion="eastus2"

my_scheduled_query_rules = {
    sched_alert_1 = {
        resLocation = "eastus2",
        resName = "name1"
        alertDescription = "description1"
    },
    sched_alert_2 = {
        resLocation = "eastus2",
        resName = "name2"
        alertDescription = "description2"
    }
}