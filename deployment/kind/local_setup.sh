# Get the project root directory (3 levels up from deployment/kind/setup.sh)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"


CLUSTER="gthulhu-api-local"
NS="gthulhu-api-local"

echo "Project root directory: $PROJECT_ROOT"

echo "Setting up local kind cluster..."
# Verify if 'kind' is available
if command -v kind >/dev/null 2>&1; then
    echo "kind found: $(kind version)"
else
    echo "kind not found; will install via 'go install' next"
    go install sigs.k8s.io/kind@v0.30.0
fi

if ! kind get clusters | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' does not exist. Creating..."
  kind create cluster --name "$CLUSTER"
else
  echo "Cluster '$CLUSTER' already exists."
fi

docker build -f  $PROJECT_ROOT/Dockerfile.amd64 -t gthulhu-api:local .

docker pull mongo:8.2.2
kind load docker-image mongo:8.2.2 --name "$CLUSTER"
kind load docker-image gthulhu-api:local --name "$CLUSTER"

kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS"

kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/mongo/secret.yaml" 
kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/mongo/service.yaml" 
kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/mongo/statefulset.yaml"

kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/decisonmaker/service.yaml" 
kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/decisonmaker/daemonset.yaml"

kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/pod/busybox.yaml"

kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/manager/service.yaml"
kubectl apply -n "$NS" -f "$PROJECT_ROOT/deployment/kind/manager/deployment.yaml"

kubectl port-forward -n "gthulhu-api-local" svc/manager 8080:8080 &