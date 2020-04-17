$deployments = ("apigwmm", "apigwms", "apigwwm", "apigwws", "basket-api", "basket-data", "catalog-api", "identity-api", "keystore-data", "locations-api", "marketing-api", "mobileshoppingagg", "nosql-data", "ordering-api", "payment-api", "rabbitmq", "sql-data", "webhooks-api", "webhooks-web", "webmvc", "webshoppingagg", "webspa", "webstatus")
$targetCPU = Read-Host -prompt "Select target CPU percent"
$minPods = Read-Host -prompt "Select minimum number of pods"
$maxPods = Read-Host -prompt "Select maximum number of pods"

foreach ($deployment in $deployments) {
    kubectl autoscale deployment eshop-$deployment --cpu-percent=$targetCPU --min=$minPods --max=$maxPods
}