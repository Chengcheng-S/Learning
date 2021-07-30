# Gateway

Gateway为rpcx提供了http网关服务，

## 部署模型

使用网关程序有两种部署模型: **Gateway** 和 **Agent**。

### Gateway

可以部署为网关模式。网关程序运行在独立的机器上，所有的**client都将http请求发送给gateway, gateway负责将请求转换成rpcx的请求**，并调用相应的rpcx 服务， 它将**rpcx 的返回结果转换成http的response**, 返回给client。

可以部署多台gateway程序，并且利用nginx进行负载均衡

### Agent

agent作为一个后台服务部署在 client机器上。 如果你的机器有多个client, 你只需部署一个agent。

> Client发送 http 请求到本地的agent, 本地的agent将请求转为 rpcx请求，然后转发到相应的 rpcx服务上， 然后将 rpcx的response转换为 http response返回给 client。

## http协议

可以使用任意的编程语言来发送http请求，按照需求额外设置一些header

- X-RPCX-Version: rpcx 版本
- X-RPCX-MesssageType: 设置为0,代表请求
- X-RPCX-Heartbeat: 是否是heartbeat请求, 缺省false
- X-RPCX-Oneway: 是否是单向请求, 缺省false.
- X-RPCX-SerializeType: 0 as raw bytes, 1 as JSON, 2 as protobuf, 3 as msgpack
- X-RPCX-MessageID: 消息id, uint64 类型
- X-RPCX-ServicePath: service path
- X-RPCX-ServiceMethod: service method
- X-RPCX-Meta: 额外的元数据

http response，可能包含的header：

- X-RPCX-Version: rpcx 版本
- X-RPCX-MesssageType: 1 ,代表response
- X-RPCX-Heartbeat: 是否是heartbeat请求
- X-RPCX-MessageStatusType: Error 还是正常返回结果
- X-RPCX-SerializeType: 0 as raw bytes, 1 as JSON, 2 as protobuf, 3 as msgpack
- X-RPCX-MessageID: 消息id, uint64 类型
- X-RPCX-ServicePath: service path
- X-RPCX-ServiceMethod: service method
- X-RPCX-Meta: extra metadata
- X-RPCX-ErrorMessage: 错误信息

