# 资源池 API

## 目的
存放资源池信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段|
|description|CharField|字符数限制: 255字符，允许为空|
|department|ForeignKey|部门，允许为空|
|virtual_machines|ManyToManyField|虚拟机列表，允许为空|

## 请求与响应格式

### 请求

```JSON
{
    "virtual_machines": [],
    "department": null,
    "name": "",
    "description": ""
}
```

### 响应
```JSON
{
    "url": "http://guhuajun:8000/api/cmdb/resourcepools/resourcepool/1",
    "virtual_machines": [
        "WEB-101125110"
    ],
    "department": "ops",
    "total_virtual_cpu": 2,
    "total_virtual_memory": 17179869184,
    "total_virtual_storage": 128849018880,
    "name": "OPS Pool",
    "description": null,
    "created_date": "2015-12-21T09:11:46Z",
    "modified_date": "2015-12-21T09:11:46Z"
}
```

## 备注

响应中包含已total*开始的，根据虚拟机信息计算得出的字段。