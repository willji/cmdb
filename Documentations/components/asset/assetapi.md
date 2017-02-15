# 资产 API

## 目的
存放资产相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段|
|description|CharField|字符数限制: 255字符，允许为空|
|status|ForeignKey|资产状态|
|type|ForeignKey|资产类型|
|specification|ForeignKey|资产规格|
|dc_contact|ManyToManyField|数据中心联系人，允许为空|
|vendor_contact|ManyToManyField|厂商联系人，允许为空|
|owner|ManyToManyField|资产所有者，允许为空|
|department|ForeignKey|部门|
|asset_tag|CharField|资产标签，字符数限制: 40字符|
|serial_number|CharField|序列号，字符数限制: 255字符，允许为空|
|purpose|CharField|使用目的，字符数限制: 255字符，允许为空|
|value|PositiveIntegerField|资产价值，允许为空|
|hw_warranty_end|DateTimeField|硬件维保结束时间，允许为空|
|sc_warranty_end|DateTimeField|支持合同结束时间，允许为空|
|stock_date|DateTimeField|入库时间，允许为空|

## 请求与响应格式

### 请求

```JSON
{
    "status": null,
    "type": null,
    "specification": null,
    "dc_contact": [],
    "vendor_contact": [],
    "owner": null,
    "department": null,
    "name": "",
    "description": "",
    "asset_tag": "",
    "serial_number": "",
    "purpose": "",
    "value": null,
    "hw_warranty_end": null,
    "sc_warranty_end": null,
    "stock_date": null
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/assets/asset/1",
    "status": "已部署",
    "type": "机架式服务器",
    "specification": "HP Proliant DL380 G5",
    "dc_contact": [
        "guhuajun"
    ],
    "vendor_contact": [
        "guhuajun"
    ],
    "owner": "guhuajun",
    "department": "m2c",
    "name": "SERVER001",
    "description": null,
    "created_date": "2015-12-21T05:42:55Z",
    "modified_date": "2015-12-21T05:42:55Z",
    "asset_tag": "SERVER001",
    "serial_number": null,
    "purpose": null,
    "value": null,
    "hw_warranty_end": null,
    "sc_warranty_end": null,
    "stock_date": null
}
```
