使用curl下载内容到特定的目录
```
curl --silent -Lo /tmp/vault.zip  https://xxxx.zip
```
jq命令格式化输出
```
ault read -format=json sys/auth | jq '.data | map_values({type, default_lease_ttl: .config.default_lease_ttl})'
```
