# Working with Node Affinity
Node affinity can be used for advanced scheduling in kubernetes. Tutorial below is a walk through of such usage.

## Concepts

### Node Affinity
Node affinity is a way to set rules based on which the scheduler can select the nodes for scheduling workload. Node affinity can be thought of as opposite of taints. Taints repel a certain set of nodes where as node affinity attract a certain set of nodes.

NodeAffinity is a generalization of *nodeSelector*. In *nodeSelector*, we specifically mention which node the pod should go to, using node affinity we specify certain rules to select nodes on which pod can be scheduled.

These rules are defined by labelling the nodes and having pod spec specify the selectors to match those labels. There are 2 types of affinity rules. Preferred rules and Required rules.

In *Preferred rule*, a pod will be assigned on a non matching node if and only if no other node in the cluster matches the specified labels. *preferredDuringSchedulingIgnoredDuringExecution* is a preferred rule affinity.

In *Required rules*, if there are no matching nodes, then the pod won't be scheduled. There are a couple of require rule affinities namely *requiredDuringSchedulingIgnoredDuringExecution* and *requiredDuringSchedulingRequiredDuringExecution*.

In *requiredDuringSchedulingIgnoredDuringExecution* affinity, a pod will be scheduled only if the node labels specified in the pod spec matches with the labels on the node. However, once the pod is scheduled, labels are ignored meaning even if the node lables change, the pod will continue to run on that node.

In *requiredDuringSchedulingRequiredDuringExecution* affinity, a pod will be scheduled only if the node labels specified in the pod spec matches with the labels on the node and if the labels on the node change in future, the pod will be evicted. This effect is similar to *NoExecute* taint with one significant difference. When *NoExecute* taint is applied on a node, every pod not having a toleration will be evicted, where as, removing/changing a label will remove only the pods that do specify a different label. 

## Use cases
* While scheduling workload, when we need to schedule a certain set of pods on a certain set of nodes but do not want to reject everything else, using node affinity makes sense.

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
