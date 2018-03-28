set x

kubectl delete -f guestbook/redis-master-deployment.yaml
kubectl delete -f guestbook/redis-master-service.yaml

kubectl delete -f guestbook/redis-slave-deployment.yaml
kubectl delete -f guestbook/redis-slave-service.yaml

kubectl delete -f guestbook/frontend-deployment.yaml
kubectl delete -f guestbook/frontend-service.yaml
