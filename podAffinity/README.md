# Pod Affinity & AntiAffinity
Pod affinity can be used for advanced scheduling in kubernetes. Tutorial below is a walk through of such usage.

## Concepts

### Pod Affinity & AntiAffinity
* Node affinity allows you to schedule a pod on a set of nodes based on labels present on the nodes. However, in certain scenarios, we might want to schedule certain pods together or we might want to make sure that certain pods are never scheduled together. This can be achieved by *PodAffinity* and/or *PodAntiAffinity* respectively.

* Similar to node affinity, there are a couple of variants in pod affinity namely *requiredDuringSchedulingIgnoredDuringExecution* and *preferredDuringSchedulingIgnoredDuringExecution*.

## Use cases
* While scheduling workload, when we need to schedule a certain set of pods together, *PodAffinity* makes sense. Example, a web server and a cache.
* While scheduling workload, when we need to make sure that a certain set of pods are not scheduled together, *PodAntiAffinity* makes sense.

## Examples:
Follow through guide.

Let's begin with listing nodes.

```
kubectl get nodes
```
You should be able to see the list of nodes available in the cluster,
```
NAME                          STATUS    ROLES     AGE       VERSION
node1.compute.infracloud.io   Ready     <none>    25m       v1.9.4
node2.compute.infracloud.io   Ready     <none>    25m       v1.9.4
node3.compute.infracloud.io   Ready     <none>    28m       v1.9.4
```

#### Pod Affinity example

Let's deploy [deployment-Affinity.yaml](deployment-Affinity.yaml), which has pod affinity as,
```
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - nginx
      topologyKey: "kubernetes.io/hostname"
```

Here we are specifying that all nginx pods should be scheduled together.

```
kubectl apply -f deployment-Affinity.yaml
```

Check the pods using,
```
kubectl get pods -o wide -w
```

You should be able to see that all pods are scheduled on the same node.
```
NAME                                READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-deployment-6bc5bb7f45-49dtg   1/1       Running   0          36m       10.20.29.18   node2.compute.infracloud.io
nginx-deployment-6bc5bb7f45-4ngvr   1/1       Running   0          36m       10.20.29.20   node2.compute.infracloud.io
nginx-deployment-6bc5bb7f45-lppkn   1/1       Running   0          36m       10.20.29.19   node2.compute.infracloud.io
```

To clean up run,
```
kubectl delete -f deployment-Affinity.yaml
```

#### Pod Anti Affinity example
Let's deploy [deployment-AntiAffinity.yaml](deployment-AntiAffinity.yaml), which has pod affinity as,
```
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - nginx
      topologyKey: "kubernetes.io/hostname"
```

Here we are specifying that no two nginx pods should be scheduled together.

```
kubectl apply -f deployment-AntiAffinity.yaml
```

Check the pods using,
```
kubectl get pods -o wide -w
```

You should be able to see that pods are scheduled on different nodes.
```
NAME                                READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-deployment-85d87bccff-4w7tf   1/1       Running   0          27s       10.20.29.16   node3.compute.infracloud.io
nginx-deployment-85d87bccff-7fn47   1/1       Running   0          27s       10.20.42.32   node1.compute.infracloud.io
nginx-deployment-85d87bccff-sd4lp   1/1       Running   0          27s       10.20.13.17   node2.compute.infracloud.io

```

Note: In above example, if number of replicas are more than number of nodes then some pods will remain in pending state.

To clean up run,
```
kubectl delete -f deployment-AntiAffinity.yaml
```
