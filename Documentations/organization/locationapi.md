# 地理位置 API

## 目的
存放地理位置的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段
|description|CharField|字符数限制: 255字符，允许为空

## 请求与响应格式

### 请求

```JSON
{
    "name": "",
    "description": "",
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/environments/location/1",
    "name": "SHA_PD_WGJ",
    "description": null,
    "created_date": "2015-12-15T07:50:34Z",
    "modified_date": "2015-12-15T07:50:34Z"
}
```
