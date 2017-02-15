# 虚拟机 API

## 目的
存放虚拟机的相关信息。

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
|visible_label|CharField|可视标签，字符数限制: 40字符|
|vcenter_server|ForeignKey|VCenter服务器，允许为空|
|vm_template|ForeignKey|虚拟机模板，允许为空|
|host|ForeignKey|宿主机|
|os_type|ForeignKey|操作系统类型|
|virtual_cpu|PositiveIntegerField|虚拟机CPU数量|
|virtual_memory|BigIntegerField|虚拟机内存数量|
|virtual_storage|BigIntegerField|虚拟机存储数量|
|apps|ManyToManyField|应用程序列表|


## 请求与响应格式

### 请求

```JSON
{
    "vcenter_server": null,
    "vm_template": null,
    "host": null,
    "os": null,
    "ipaddresses": [],
    "apps": [],
    "status": null,
    "name": "",
    "description": "",
    "visible_label": "",
    "virtual_cpu": null,
    "virtual_memory": null,
    "virtual_storage": null
}
```

### 响应
```JSON
{
    "url": "http://guhuajun:8000/api/cmdb/devices/virtualmachine/2",
    "vcenter_server": "172.16.100.83",
    "vm_template": "Windows Server 2008 R2 (201512)",
    "host": "SERVER001",
    "os": "Windows Server 2008 R2",
    "ipaddresses": [],
    "apps": [
        "www.ymatou.com"
    ],
    "status": "Online",
    "asset": "SERVER001_WEB-101125110",
    "location": "SHA_PD_WGJ",
    "rack": "D12",
    "unit_position": "U12",
    "unit_height": 0,
    "name": "WEB-101125110",
    "description": null,
    "created_date": "2015-12-21T08:33:27Z",
    "modified_date": "2015-12-21T08:33:27Z",
    "visible_label": "",
    "virtual_cpu": 2,
    "virtual_memory": 17179869184,
    "virtual_storage": 128849018880
}
```
