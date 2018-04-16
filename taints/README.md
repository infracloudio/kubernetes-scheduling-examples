# Taints and Tolerations
Taints can be used for advanced scheduling in kubernetes. Tutorial below is a walk through of such usage.

## Concepts

### Taints
Taint is a property of node that allows you to repel a set of pods unless those pods explicitly tolerates the said taint.

Taint has three parts. A key, a value and an effect.

For example,
```
kubectl taint nodes node1.compute.infracloud.io thisnode=HatesPods:NoSchedule
```
The above taint has key=thisnode, value=HatesPods and effect as NoSchedule. These key value pairs are configurable. Any pod that doesn't have a matching toleration to this taint will not be scheduled on node1.

To remove the above taint, we can run the following command
```
kubectl taint nodes node1.compute.infracloud.io thisnode:NoSchedule-
```

What are some of the Taint effects?
* NoSchedule - Doesn't schedule a pod without matching tolerations
* PreferNoSchedule - Prefers that the pod without matching toleration be not scheduled on the node. It is a softer version of NoSchedule effect.
* NoExecute - Evicts the pods that don't have matching tolerations.

A node can have multiple taints.
For example, if any pod is to be scheduled on a node with multiple *NoExecute* effect taints, then that pod must tolerate all the taints. However, if the set of taints on a node is a combination of *NoExecute* and *PreferNoExecute* effects and the pod only tolerates *NoExecute* taints then kubernetes will prefer not to schedule the pod on that node, but will do it anyway if there's no alternative.

### Tolerations
Nodes are tainted for a simple reason, to avoid running of workload. The similar outcome can be achieved by PodAffinity/PodAnti-Affinity, however, to reject a large workload taints are more efficient (In a sense that they only require tolerations to be added to the small workload that does run on the tainted nodes as opposed to podAffinity which would require every pod template to carry that information)

Toleration is simply a way to overcome a taint.

For example,
In the above section, we have tainted thisnode.compute.infracloud.io

To schedule the pod on that node, we need a matching toleration. Below is the toleration that can be used to overcome the taint.

```
tolerations:
- key: "thisnode"
  operator: "Equal"
  value: "HatesPods"
  effect: "NoSchedule"
```

What we are telling kubernetes here is that, on any node if you find that there's a taint with key *node1* and its value is *HatesPods* then that particular taint should not stop you from scheduling this pod on that node.

Toleration generally has four parts. A key, a value, an operator and an effect.
Operator, if not specified, defaults to *Equal*

## Use cases
* Taints can be used to group together a set of Nodes that only run a certain set of workload, like network pods or pods with special resource requirement.
* Taints can also be used to evict a large set of pods from a node using taint with *NoExecute* effect.

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
kubectl taint nodes node1.compute.infracloud.io thisnode=HatesPods:NoSchedule
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
nginx-deployment-6c54bd5869-g9rtf   1/1       Running   0          18s       10.20.32.2   node3.compute.infracloud.io
nginx-deployment-6c54bd5869-v74m6   1/1       Running   0          18s       10.20.32.3   node3.compute.infracloud.io
nginx-deployment-6c54bd5869-w5jxj   1/1       Running   0          18s       10.20.61.2   node2.compute.infracloud.io
```

Now let's taint node3 with *NoExecute* effect, which will evict both the pods from node3 and schedule them on node2.
```
kubectl taint nodes node3.compute.infracloud.io thisnode=AlsoHatesPods:NoExecute
```

In a few seconds you'll see that the pods are terminated on node3 and spawned on node2
```
kubectl get pods -o wide

NAME                                READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-deployment-6c54bd5869-8vqvc   1/1       Running   0          33s       10.20.42.21   node2.compute.infracloud.io
nginx-deployment-6c54bd5869-hsjhj   1/1       Running   0          33s       10.20.42.20   node2.compute.infracloud.io
nginx-deployment-6c54bd5869-w5jxj   1/1       Running   0          2m        10.20.42.19   node2.compute.infracloud.io
```

The above example demonstrates taint based evictions.

Let's delete the deployment and create new one with tolerations for the above taints.
```
kubectl delete deployment nginx-deployment
```

```
kubectl create -f taints/deployment-toleration.yaml
```

You can check the output by running,
```
kubectl get pods -o wide
```

You should be able to see that some of the pods are scheduled on node1 and some on node2. However, no pod is scheduled on node3. This is because, in the new deployment spec, we are tolerating taint *NoSchedule* effect. node3 is tainted with *NoExecute* effect which we have not tolerated so no pods will be scheduled there.

```
NAME                                READY     STATUS    RESTARTS   AGE       IP            NODE
nginx-deployment-5699885bdb-4dz8z   1/1       Running   0          1m        10.20.34.3    node1.compute.infracloud.io
nginx-deployment-5699885bdb-cr7p7   1/1       Running   0          1m        10.20.34.4    node1.compute.infracloud.io
nginx-deployment-5699885bdb-kjxwv   1/1       Running   0          1m        10.20.34.5    node1.compute.infracloud.io
nginx-deployment-5699885bdb-kvfw6   1/1       Running   0          1m        10.20.34.7    node1.compute.infracloud.io
nginx-deployment-5699885bdb-lx2zv   1/1       Running   0          1m        10.20.34.6    node1.compute.infracloud.io
nginx-deployment-5699885bdb-m686q   1/1       Running   0          1m        10.20.42.30   node2.compute.infracloud.io
nginx-deployment-5699885bdb-x7c6z   1/1       Running   0          1m        10.20.42.31   node2.compute.infracloud.io
nginx-deployment-5699885bdb-z8cwl   1/1       Running   0          1m        10.20.34.9    node1.compute.infracloud.io
nginx-deployment-5699885bdb-z9c68   1/1       Running   0          1m        10.20.34.8    node1.compute.infracloud.io
nginx-deployment-5699885bdb-zshst   1/1       Running   0          1m        10.20.34.2    node1.compute.infracloud.io
```

To finish off, let's remove the taints from the nodes,
```
kubectl taint nodes node3.compute.infracloud.io thisnode:NoExecute-
```
```
kubectl taint nodes node1.compute.infracloud.io thisnode:NoSchedule-
```