# 设备状态 API

## 目的
存放设备状态的相关信息，比如在线，待维修，下线。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段|
|description|CharField|字符数限制: 255字符，允许为空|

## 请求与响应格式

### 请求

```JSON
{
    "name": "",
    "description": ""
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou,cn/api/cmdb/devices/devicestatus/1",
    "name": "Online",
    "description": null,
    "created_date": "2015-12-21T05:42:57Z",
    "modified_date": "2015-12-21T05:42:58Z"
}
```
