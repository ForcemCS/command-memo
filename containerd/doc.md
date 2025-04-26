### 导入/出 镜像
```
ctr -n k8s.io images export authelia_4.39.1.tar ghcr.io/authelia/authelia:4.39.1 
ctr -n k8s.io images import authelia_4.39.1.tar 
```
