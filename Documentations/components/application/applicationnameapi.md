#  应用程序名 API

## 目的
存放关于应用程序名称的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|应用程序名称，字符数限制: 80字符，唯一字段，排序字段|
|description|CharField|描述，字符数限制: 255字符，允许为空|
|alias|CharField|应用程序别名，字符数限制: 80字符，允许为空|
|department|ForeignKey|应用程序所属部门|
|type|CharField|应用类型，字符数限制：20字符|

## 请求与响应格式

### 请求

```JSON
{
    "department": null,
    "name": "",
    "description": "",
    "alias": "",
    "type": ""
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/applications/applicationname/1",
    "department": "m2c",
    "name": "www.ymatou.com",
    "description": null,
    "created_date": "2015-12-21T05:42:57Z",
    "modified_date": "2015-12-21T05:42:57Z",
    "alias": null,
    "type": null
}
```
