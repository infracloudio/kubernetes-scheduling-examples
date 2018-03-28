# Working with Pod Affinity
Pod affinity can be used for advanced scheduling in kubernetes. Tutorial below is a walk through of such usage.

## Concepts

### Pod Affinity







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