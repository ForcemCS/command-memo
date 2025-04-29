### 查看sa关联的token详情
```
jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson'  <<< xxxxx
```
