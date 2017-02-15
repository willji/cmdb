# 环境信息 API

## 目的
存放环境有关的信息，一般指测试环境和生产环境的具体名称。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符, 排序字段
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
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/environments/environment/1",
    "name": "PROD",
    "description": null,
    "created_date": "2015-12-15T07:50:33Z",
    "modified_date": "2015-12-15T07:50:33Z"
}
```
