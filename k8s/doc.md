### 查看sa关联的token详情
```
jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson'  <<< xxxxx
```
### 污点和容忍度
```
kubectl taint nodes node-name key=value:taint-effect 

taint-effect包括：NoSchedule PreferNoSchedule NoExecute

apiVersion:  
kind: Pod  
metadata:  
  name: myapp-pod  
spec:  
  containers:  
  - name: nginx-container  
    image: nginx  

tolerations:  
- key: "app"  
  operator: "Equal"  
  value: "blue"  
  effect: "NoSchedule"  
```
###  Node Selector
```
kubectl label   nodes <node-name>  <k>=<v>
```
