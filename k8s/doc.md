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
### 找出pod中容器的pid
```
kubectl  -n hdh5  get pods center-ro3-micro-cb7f7d6c5-pqql9 
NAME                               READY   STATUS    RESTARTS   AGE
center-ro3-micro-cb7f7d6c5-pqql9   1/1     Running   0          12d

crictl ps -a --name ro3-micro
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD
4fb695ff65b23       3e886b3382302       12 days ago         Running             ro3-micro           0                   34812fa365329       center-ro3-micro-cb7f7d6c5-n4cvv
91116cff5b254       3e886b3382302       12 days ago         Running             ro3-micro           0                   5424f0c08e1bc       center-ro3-micro-cb7f7d6c5-pqql9

crictl inspect 91116cff5b254  | grep -i pid
    "pid": 1313492,
            "pid": 1
            "type": "pid"
```
