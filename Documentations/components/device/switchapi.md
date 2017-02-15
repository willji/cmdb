# 交换机 API

## 目的
存放交换机的相关信息。

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


## 请求与响应格式

### 请求

```JSON
{
    "asset": null,
    "status": null,
    "location": null,
    "ipaddresses": [],
    "name": "",
    "description": "",
    "rack": "",
    "unit_position": "",
    "unit_height": "",
    "visible_label": ""
}
```

### 响应
```JSON
{
	"url": "http://cmdb.ops.ymatou.cn/api/cmdb/devices/device/1.json",
	"asset": "SWICTH001",
	"location": "SHA_PD_WGJ",
	"ipaddresses": [],
	"status": "Online",
	"name": "SWICTH001",
	"description": null,
	"created_date": "2015-12-21T05:42:58Z",
	"modified_date": "2015-12-21T05:42:58Z",
	"rack": "D12",
	"unit_position": "U12",
	"unit_height": "2"
    "visible_label": ""
}
```
