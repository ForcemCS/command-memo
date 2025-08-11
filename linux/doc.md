使用curl下载内容到特定的目录
```
curl --silent -Lo /tmp/vault.zip  https://xxxx.zip
```
jq命令格式化输出
```
ault read -format=json sys/auth | jq '.data | map_values({type, default_lease_ttl: .config.default_lease_ttl})'
```
找出某个端口被占用的进程
```
ss -tnulp  |grep :53
```
生成32位的随机密钥并进行base64编码
```
head -c 32 /dev/urandom | base64
```
删除 /usr/local/bin 下指向 percona-xtrabackup-2.4/bin 的所有软链接
find /usr/local/bin -type l -lname '*percona-xtrabackup-2.4/bin/*' -delete
