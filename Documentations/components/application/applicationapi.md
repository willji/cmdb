#  应用程序 API

## 目的
存放关于应用程序的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|app|ForeignKey|应用程序名称
|owner|ForeignKey|应用程序所有者，允许为空|
|environment|ForeignKey|应用程序所管理环境|
|department|ForeignKey|应用程序所属部门|
|ipaddresses|ManyToManyField|应用所占用IP地址，允许为空|
|warmup_urls|ManyToManyField|应用所需的一组点火URL，允许为空|
|site_id|PositiveIntegerField|站点ID，允许为空|
|version|CharField|应用程序版本号，允许为空|


## 请求与响应格式

### 请求

```JSON
{
    "app": null,
    "owner": null,
    "environment": null,
    "ipaddresses": [],
    "warmup_urls": [],
    "site_id": null,
    "version": ""
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/applications/application/1",
    "app": "www.ymatou.com",
    "owner": "guhuajun",
    "environment": "PROD",
    "ipaddresses": [],
    "warmup_urls": [],
    "department": "ops",
    "type": "iis",
    "created_date": "2015-12-21T09:52:22Z",
    "modified_date": "2015-12-21T09:52:22Z",
    "site_id": null,
    "version": null
}
```

### 备注
响应中包含根据app信息计算得出的字段，environment及type