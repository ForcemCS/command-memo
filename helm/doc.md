## helm template的使用
```
helm template my-release-name ./hdh5 -n hdh5 --show-only templates/configmap-pause-generated.yaml --debug 
```
### hasKey的使用

```
#判断 $global.Values.pause 这个 map 中是否存在 key 为 $counts.id 的条目。如果存在则取出key
{{- if and $global.Values.pause (hasKey $global.Values.pause ($counts.id | toString )) }}
#取出其值
{{- $shouldPause :=  index $global.Values.pause ($counts.id | toString) }}

```
