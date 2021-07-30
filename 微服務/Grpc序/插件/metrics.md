# metrics

metrics 插件使用go-metrics来计算服务的指标

包含多个统计指标

- serviceCounter
- clientMeter
- “service_”+servicePath+”.”+serviceMethod+”_Read_Qps”
- “service_”+servicePath+”.”+serviceMethod+”_Write_Qps”
- “service_”+servicePath+”.”+serviceMethod+”_CallTime”

将metrics输出到graphite中，通过grafana来监控。

