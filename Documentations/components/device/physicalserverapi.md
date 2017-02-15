# 物理服务器 API

## 目的
存放物理服务器的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|name|CharField|字符数限制: 40字符，排序字段|
|description|CharField|字符数限制: 255字符，允许为空|
|asset|ForeignKey|资产|
|location|ForeignKey|资产位置|
|rack|CharField|机架位置，字符数限制: 20字符|
|unit_position|CharField|U位，字符数限制: 20字符|
|unit_height|CharField|设备高度（1U/2U/4U），字符数限制: 20字符|
|ipaddresses|ManyToManyField|IP地址|
|status|ForeignKey|设备状态|
|cpu|PositiveIntegerField|逻辑处理器数量|
|memory|BigIntegerField|内存数量|
|storage_capacity|BigIntegerField|存储数量|
|server_specification|ForeignKey|服务器规格|
|os_type|ForeignKey|操作系统类型|
|raid_type|ForeignKey|RAID类型|


## 请求与响应格式

### 请求

```JSON
{
    "asset": null,
    "status": null,
    "location": null,
    "ipaddresses": [],
    "os_type": null,
    "server_specification": null,
    "name": "",
    "description": "",
    "rack": "",
    "unit_position": "",
    "unit_height": "",
    "cpu": null,
    "memory": null,
    "storage_capacity": null,
    "visible_label": "",
    "raid_type": null
}
```

### 响应
```JSON
{
    "url": "http://guhuajun:8000/api/cmdb/devices/physicalserver/1",
    "asset": "SERVER001",
    "status": "Online",
    "location": "SHA_PD_WGJ",
    "ipaddresses": [],
    "os_type": "Windows Server 2008 R2",
    "server_specification": "HP Proliant DL380 G5",
    "virtual_machines": [
        "WEB-101125110"
    ],
    "name": "SERVER001",
    "description": null,
    "created_date": "2015-12-21T09:52:22Z",
    "modified_date": "2015-12-21T09:52:22Z",
    "rack": "D12",
    "unit_position": "U12",
    "unit_height": "2",
    "visible_label": "SERVER001",
    "cpu": 24,
    "memory": 17179869184,
    "storage_capacity": 1099511627776,
    "raid_type": "RAID01"
}
```

### 备注
响应中包含位于该物理机上的虚拟机。该字段由SerializerMethodField生成，为只读字段，不可修改。