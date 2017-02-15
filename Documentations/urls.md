# API访问地址

## Swagger UI

|访问地址|子应用|备注|
|:-----|:-----|:-----|
|/api/cmdb|	Django REST Swagger	Swagger API |文档生成工具，用于生成API文档

## Django后台管理

|访问地址|子应用|备注|
|:-----|:-----|:-----|
|/api/cmdb/admin|后台管理|Django后台管理页面

## REST API 验证

|访问地址|子应用|备注|
|:-----|:-----|:-----|
|/api/cmdb/api-auth/login|API 验证|访问图形化API界面时需经过身份验证|
|/api/cmdb/api-auth/logout|API 验证|访问图形化API界面结束时需要登出系统|
|/api/cmdb/token|API验证|访问API时需获得令牌|

## CMDB组件

|访问地址|子应用|备注|
|:-----|:-----|:-----|
|/api/cmdb/applications/warmupurls|应用管理|点火地址列表
|/api/cmdb/applications/applicationname|应用管理|应用名称列表
|/api/cmdb/applications/application|应用管理|应用列表
|/api/cmdb/assets/asset|资产管理|资产列表
|/api/cmdb/assets/assettype|资产管理|资产类型列表
|/api/cmdb/assets/assetstatus|资产管理|资产状态列表
|/api/cmdb/assets/assetspecification|资产管理|资产规格列表
|/api/cmdb/devices/ostype|设备管理|操作系统列表
|/api/cmdb/devices/devicestatus|设备管理|设备状态列表
|/api/cmdb/devices/device|设备管理|设备列表
|/api/cmdb/devices/physicalserver|设备管理|硬件服务器列表
|/api/cmdb/devices/switch|设备管理|交换机列表
|/api/cmdb/devices/virtualmachine|设备管理|虚拟机列表
|/api/cmdb/networks/ipv4addresses|网络管理|IPv4地址列表
|/api/cmdb/networks/ipv4networks|网络管理|IPv4网段列表
|/api/cmdb/resourcepools/resourcepool|资源池管理|资源池列表
|/api/cmdb/vmware/vcenterserver|虚拟化层管理|VCenter服务器列表
|/api/cmdb/vmware/vmtemplate|虚拟化层管理|虚拟机模板名称列表

## 组织相关信息

|访问地址|子应用|备注|
|:-----|:-----|:-----|
|/api/cmdb/contacts/contact|人员管理|人员列表
|/api/cmdb/departments/department|部门管理|部门列表
|/api/cmdb/environments/environment|环境管理|环境列表
|/api/cmdb/environments/location|环境管理|地理位置列表