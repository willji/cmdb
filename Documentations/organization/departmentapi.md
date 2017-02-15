# 部门信息 API

## 目的
存放部门有关的信息，一般指洋码头研发团队的部门名称，比如M2C。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符， 排序字段
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
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/departments/department/1",
    "name": "m2c",
    "description": null,
    "created_date": "2015-12-15T07:50:33Z",
    "modified_date": "2015-12-15T07:50:33Z"
}
```
