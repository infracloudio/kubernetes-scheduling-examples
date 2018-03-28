set -x

kubectl apply -f guestbook/redis-master-deployment.yaml
sleep 15
kubectl apply -f guestbook/redis-master-service.yaml

kubectl apply -f guestbook/redis-slave-deployment.yaml
sleep 30
kubectl apply -f guestbook/redis-slave-service.yaml

kubectl apply -f guestbook/frontend-deployment.yaml
sleep 45
kubectl apply -f guestbook/frontend-service.yaml

kubectl get pods -o wide

kubectl describe service frontend | grep "LoadBalancer Ingress"