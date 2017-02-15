#  点火URL API

## 目的
存放点火URL的相关信息。

## 字段
|字段名|类型|备注|
|:-----|:-----|:-----|
|sequence_number|PositiveSmallIntegerField|在一组点火Url中的顺序值，默认值为1，排序字段|
|url|UrlField|点火地址，字符数限制: 512字符，唯一字段|
|expected_status|PositiveIntegerField|访问点火Url后的期待返回值，默认值为200|

## 请求与响应格式

### 请求

```JSON
{
    "warmup_url": "",
    "sequence_number": null,
    "expected_status": null
}
```

### 响应
```JSON
{
    "url": "http://cmdb.ops.ymatou.cn/api/cmdb/applications/warmupurl/1",
    "created_date": "2015-12-21T03:39:24Z",
    "modified_date": "2015-12-21T03:43:02.065000Z",
    "sequence_number": 1,
    "warmup_url": "http://www.ymatou.com/",
    "expected_status": 200
}
```
