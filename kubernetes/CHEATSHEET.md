# KUBERNETES CHEATSHEET

## Contexts

Get context:

`kubectl config get-contexts`

Set context:

`kubectl config use-context <contextname>`

## Describe objects

`kubectl describe nodes/k8s-master1`

`kubectl -n <namespace> describe pods/nginx`

## Pods / Containers

### Show pods

Show all pods in a namespace
`kubectl get pods -n kube-system`

Show non running pods in the kube-system namespace (useful for troubleshooting)
`kubectl get pods -n kube-system --field-selector=status.phase!=Running`

### Show containers in a pod

`kubectl get pod podname -o 'jsonpath={.spec.containers[*].name}'`

### Filter using jsonpath expression

`kubectl get pod nginx -o 'jsonpath={.spec.containers[?(@.name=="nginx")].image}'`

### Other way to filter collections of objects

`kubectl get pods --field-selector=status.phase!=Running`

### Show logs (stdout) for a container in a pod

`kubectl logs podname -c containername`

### Show logs (stdout) for a container in a pod matching label "app=nginx"

`kubectl logs podname -c containername -l app=nginx`

### Follow logs for a container in a pod

`kubectl logs -f podname -c containername`

### Exec into a container running in a pod

`kubectl -n namespace exec -it podname -c containername -- bash`

`kubectl -n namespace exec -it podname -c containername -- sh`

`kubectl -n namespace exec -it podname -c containername -- ps -aux`

## Waiting

Waiting is based on object's conditions. You can quickly see which conditions an object type offers by:

`kubectl get <objectype> -o jsonpath='{.items[].status.conditions}' | jq .`

`kubectl get <objecttype> -o json | jq '.items[].status.conditions`

Currently `service` objects don't have `conditions` so we can't use wait on them. An alternative is:

`until kubectl -n <namespace> get service/<svcname> -ojsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done`

### Wait for deployment to be available (note: "ready" is for pods and nodes)

`kubectl wait deployment <deploymentname> --for condition=available --all --timeout 120s`

### Wait for nodes

`kubectl wait node <nodename> --for condition=ready --all --timeout 5m`

### Wait for namespace to be deleted

`kubectl wait ns <namespacename> --for=delete --timeout 5m`

### Wait for pod(s)

`kubectl -n <namespace> wait pod <podname> --for condition=ready --timeout 5m`

`kubectl -n <namespace> wait pods --for condition=ready -l app=nginx,env=dev --timeout 5m`

Trick to select all pods by using a non existing label

`kubectl -n <namespace> wait pods --for condition=ready --selector '!dummy' --timeout 5m`

Wait for pod not to be ready

`kubectl -n <namespace> wait pod <podname> --for condition=ready=false --timeout 5m`

### Wait for job to be complete

`kubectl -n <namespace> wait job <jobname> --for condition=complete --timeout=5m`

## Cluster wide info

### Info

`kubectl cluster-info`

### Component statuses

`kubectl get --raw='/readyz?verbose'`

NOTE: The form below has been deprecated

`kubectl get cs`

### Show all events across namespaces sorted by time

`kubectl get events --all-namespaces --sort-by='.metadata.creationTimestamp'`

### Keep watching events across all namespaces

`kubectl get events -A -w`

## RBAC testing

`kubectl --as=system:serviceaccount:<namespace>:<serviceaccount> auth can-i get configmap/<configmap>`

## Cluster performace (requires metrics server)

`kubectl top nodes`

`kubectl top pods`

`kubectl -n <namespace> top pods`

`kubectl -n <namespace> top pods <podname>`

## Port forwarding

`kubectl port-forward svc/longhorn-frontend <localport>:<remoteport> &`

`kubectl port-forward pod/podname <localport>:<remoteport> &`

## Modify objects

### Manual

`kubectl get deployment nginx -o yaml > nginx.yml`

`vim nginx.yml`

`kubect replace -f nginx.yml`

### Semi manual

`kubectl edit deployment nginx`

### Automatic

`kubectl patch deployment nginx -p '{"spec": {"replicas": 3}}'`

### Automatic (only applicable to certain objects and fields)

`kubectl set image deployment/nginx nginx=nginx:1.9.1`

## Labeling

Set label

`kubectl label node k8s-node1 node-role.kubernetes.io/worker=[value]`

Update label

`kubectl label deployment nginx --overwrite app=frontend`

Remove label

`kubectl label node k8s-node1 node-role.kubernetes.io/worker-`

## Declarative creation/destruction of resources

### Apply

`kubectl apply -f manifest.yml`

`kubectl apply -f <directory>`

`kubectl apply -f <directory> -R` # Will recurse subdirectories

### Kustomize

`kubectl apply -k <directory>`

### Delete

`kubectl delete -f manifest.yml`

`kubectl delete -f <directory>`

`kubectl delete -f <directory> -R` # Will recurse subdirectories

## Imperative commands

`kubectl run debug --image=busybox -- sleep infinity`

### Generate manifest skeleton

`kubectl create deployment nginx --image=nginx --replicas=2 --port=80 -o yaml --dry-run=client > deployment.yml`

`kubectl create secret generic nginx -type opaqe --from-literal pass=123 --from-literal user=hector -oyaml --dry-run=client`

## Managing deployments

`kubectl rollout status deployment myapp`

`kubectl rollout undo statefulset myapp`

`kubectl rollout history deployment myapp`

`kubectl scale --replicas=N deployment myapp`

Alternative way to 'scale':

`kubectl patch deployment myapp -p '{"spec": {"replicas": N}}'`
`kubectl edit deployment myapp`

## Miscellaneous

`kubectl api-versions`

`kubectl api-resources`

`kubectl get crd`

## Pull secrets

```shell
$ aws ecr get-login-password | docker login -u AWS --password-stdin ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
```

```shell
$ kubectl create secret generic SECRETNAME \
--from-file=.dockerconfigjson=$HOME/.docker/config.json \
--type=kubernetes.io/dockerconfigjson
```
