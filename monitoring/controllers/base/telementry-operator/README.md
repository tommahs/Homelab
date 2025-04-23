# Deploy with helm

# Add the OpenTelemetry Helm repository if you haven't already
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

# Update the Helm repository
helm repo update

# Install the OpenTelemetry Operator with CRDs in the observability namespace
helm install opentelemetry-operator open-telemetry/opentelemetry-operator \
  --namespace opentelemetry-operator \
  --create-namespace \
  --set admissionWebhooks.enabled=true \
  --set customResourceDefinitions.createCRD=true