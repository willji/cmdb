# 资产规格 API

## 目的
存放资产规格的相关信息，比如HP Proliant DL380 G5。

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
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/assets/assetspcification/1",
    "name": "HP Proliant DL380 G5",
    "description": null,
    "created_date": "2015-12-21T05:42:54Z",
    "modified_date": "2015-12-21T05:42:54Z"
}
```
