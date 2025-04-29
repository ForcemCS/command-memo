### 导入/出 镜像
```
ctr -n k8s.io images export authelia_4.39.1.tar ghcr.io/authelia/authelia:4.39.1 
ctr -n k8s.io images import authelia_4.39.1.tar 
```
### Dockerfile
```
ENTRYPOINT ["sleep"]
CMD ["5"]

#当在命令行执行 docker run xxx:v1 10 会覆盖默认参数5,在Pod中是通过args: ["10"]
#同时还可以覆盖默认的entrypoint  docker run --entrypoint sleep2.0 xxx:v1 20 ,在pod中的结构如下
command: ["sleep2.0"]
args: ["10"]
```
### 容器安全
```
docker run --user=1001 ubuntu sleep 3600  

docker run --cap-add MAC_ADMIN ubuntu  

apiVersion: v1  
kind: Pod  
metadata:  
  name: web-pod  
spec:  
  containers:  
    - name: ubuntu  
      image: ubuntu  
      command: ["sleep", "3600"]  
      securityContext:  
        runAsUser: 1000
        #只发生在容器级别  
        capabilities:  
          add: ["MAC_ADMIN"]  
```
