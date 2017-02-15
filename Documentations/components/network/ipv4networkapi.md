# IPv4网络 API

## 目的
存放IPv4网络信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段|
|description|CharField|字符数限制: 255字符，允许为空|
|gateway|CharField|字符数限制: 18字符，允许为空|

## 请求与响应格式

### 请求

```JSON
{
    "name": "",
    "description": "",
    "gateway": ""
}
```

### 响应
```JSON
{
    "url": "http://guhuajun:8000/api/cmdb/networks/ipv4networks/1",
    "name": "10.11.251.0/24",
    "description": null,
    "created_date": "2015-12-21T08:54:40Z",
    "modified_date": "2015-12-21T08:54:40Z",
    "gateway": "10.11.254.254"
}
```
