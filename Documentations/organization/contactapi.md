# 联系人 API

## 目的
存放联系人的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段
|email|CharField|字符数限制: 80字符
|mobile|CharField|字符数限制: 30字符

## 请求与响应格式

### 请求

```JSON
{
    "name": "",
    "email": "",
    "mobile": ""
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/contacts/contact/1",
    "name": "guhuajun",
    "email": "guhuajun@ymatou.com",
    "mobile": "11111111111",
    "created_date": "2015-12-15T07:50:33Z",
    "modified_date": "2015-12-15T07:50:33Z"
}
```
