# 產出報告的工具(for Oracle)
省去手工交換資料的小工具

## 使用方式
1. 可使用 bash 呼叫 xmlgenerate.sh -> 引用 xmlgenerate.sql
2. 可直接呼叫 xmlgenerate.sql

## 自動產出報告工具(xmlgenerate.sh)
```bash
./xmlgenerate.sh [date_start date_end]
# date_start yyyymmdd, 默認7天前
# date_end yyyymmdd, 默認1天前
# 產出用以事故編號為名稱的工具報告
```

## 自動產出報告工具(xmlgenerate.sql)
- sqlplus ./this.sql &1 &2 &3
- return xml formated file
- &1 = date_start(yyyymmdd)
- &2 = date_end(yyyymmdd)
- &3 = some/where/spoolfile.name
```bash
./sqlplus xmlgenerate.sql 20170101 20171231 /reports/201801/exChange.xml
```
