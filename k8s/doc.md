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
### qps
```
ab -n 1000 -c 50  http://example:80/

Concurrency Level:      50               #并发数
Time taken for tests:   31.538 seconds
Complete requests:      1000
Failed requests:        0                #失败请求数
Total transferred:      478000 bytes
HTML transferred:       105000 bytes
Requests per second:    31.71 [#/sec] (mean)      #31.71 次/秒（这是你服务的当前吞吐能力）
Time per request:       1576.924 [ms] (mean)      #每个请求平均耗时 1576ms（也就是 1.5 秒左右响应时间）
Time per request:       31.538 [ms] (mean, across all concurrent requests)
Transfer rate:          14.80 [Kbytes/sec] received
```
### net-tools
```
kubectl run -n consul --rm -it --image=wbitt/network-multitool net-tools
```
### 删除terminating的pv
```
kubectl patch pv pvc-df903dc1-2553-445c-8c92-2e468e762e19 -p '{"metadata":{"finalizers":null}}' --type=merge

```
### 获取节点信息
```
kubectl get nodes -o go-template='{{range .items}}{{range .status.addresses}}{{if eq .type "ExternalIP"}}{{.address}}{{"\n"}}{{end}}{{end}}{{end}}'
kubectl get nodes -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
```
### 查看证书详细信息
```
kubectl get secret xbot-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text
```
### 更新secret
```
kubectl -n workflow create secret generic datacenter-secret-token \
  --from-literal=token='你的新TOKEN明文' \
  --dry-run=client -o yaml | kubectl apply -f -
```
### secret
```
kubectl create secret generic registry-secret \
  --from-file=.dockerconfigjson=/root/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  -n game
```
### 查看日志
```
kubectl -n envoy-gateway-system logs -l 'k1=v1,k2=v2' -c envoy -f --prefix --tail=100 --max-log-requests=10
```
### 从 Kubernetes 网络测试 Pod IP 的 TCP 连通性
```
kubectl -n roh5 run port-check --image=busybox:1.36 --restart=Never -- sleep 3600

kubectl -n roh5 get pods -o custom-columns='NAME:.metadata.name,IP:.status.podIP' --no-headers | while read -r name ip; do
    [[ "$name" == game-roh5-server-* ]] || continue

    if kubectl -n roh5 exec port-check -- nc -z -w 2 "$ip" 10010 >/dev/null 2>&1; then
        echo "✅ $name ($ip) : 10010 TCP连接成功"
    else
        echo "❌ $name ($ip) : 10010 TCP连接失败"
    fi
done
```
