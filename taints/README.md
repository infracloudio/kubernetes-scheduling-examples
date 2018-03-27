# Working with taints and tolerations
Taints can be used for advanced scheduling in kubernetes. Tutorial below is a walk through of such usage.

## Concepts

### Taints
Taint is a property of node that allows you to repel a set of pods unless those pods explicitely tolerates the said taint.

Taint has three parts. A key, a value and an effect.

For example,
```
kubectl taint nodes node1.compute.infracloud.io node1=HatesPods:NoSchedule
```
The above taint has key=node1, value=HatesPods and effect as NoSchedule. These key value pairs are configurable. Any pod that doesn't have a matching toleration to this taint will not be scheduled on node1.

To remove the above taint, we can run the following command
```
kubectl taint nodes node1.compute.infracloud.io node1:NoSchedule-
```

What are some of the Taint effects?
* NoSchedule - Doesn't schedule a pod without matching tolerations
* PreferNoSchedule - Prefers that the pod without matching toleration be not scheduled on the node. It is a softer version of NoSchedule effect.
* NoExecute - Evicts the pods that don't have matching tolerations.

A node can have multiple taints.
For example, if any pod is to be scheduled on a node with multiple *NoExecute* effect taints, then that pod must tolerate all the taints. However, if the set of taints on a node is a combination of *NoExecute* and *PreferNoExecute* effects and the pod only tolerates *NoExecute* taints then kubernetes will prefer not to schedule the pod on that node, but will do it anyway if there's no alternative.

### Tolerations
Nodes are tainted for a simple reason, to avoid running of workload. The similar outcome can be achived by PodAffinity/PodAnti-Affinity, however, to reject a large workload taints are more efficient (In a sense that they only require tolerations to be added to the small workload that does run on the tainted nodes as opposed to podAffinity which would require every pod template to carry that information)

Toleration is simply a way to overcome a taint.

For example,
In the above section, we have tainted node1.compute.infracloud.io

To schedule the pod on that node, we need a matching toleration. Below is the toleration that can be used to overcome the taint.

```
tolerations:
- key: "node1"
  operator: "Equal"
  value: "HatesPods"
  effect: "NoSchedule"
```

What we are telling kubernetes here is that, on any node if you find that there's a taint with key *node1* and its value is *HatesPods* then that particular taint should not stop you from scheduling this pod on that node.

Toleration generally has four parts. A key, a value, an operator and an effect.
Operator, if not specified, defaults to *Equal*

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

Now, let's taint node1 with *NoSchedule* effect.
```
kubectl taint nodes node1.compute.infracloud.io node1=HatesPods:NoSchedule
```

You should be able to see that node1 is now tainted.
```
node "node1.compute.infracloud.io" tainted
```

Let's run the deployment to see where pods are deployed.
```
kubectl create -f deployment.yaml
```

Check the output using,
```
kubectl get pods -o wide
```

You should be able that the pods aren't scheduled on node1
```
NAME                                READY     STATUS    RESTARTS   AGE       IP           NODE
nginx-deployment-6c54bd5869-r7mt8   1/1       Running   0          18s       10.20.32.2   node3.compute.infracloud.io
nginx-deployment-6c54bd5869-t2hqr   1/1       Running   0          18s       10.20.32.3   node3.compute.infracloud.io
nginx-deployment-6c54bd5869-xwr5b   1/1       Running   0          18s       10.20.61.2   node2.compute.infracloud.io
```
