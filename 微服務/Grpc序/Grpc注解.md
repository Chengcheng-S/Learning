# Grpc

远程过程调用(Remote Procedure Call) 是一个计算机通信协议，该协议允许运行一台计算机的程序调用另一台计算机的子程序。

> 远程过程调用是一个分布式计算的客户端-服务器（Client/Server）的例子，它简单而又广受欢迎。
> 远程过程调用总是由客户端对服务器发出一个执行若干过程请求，并用客户端提供的参数。执行结果将返回给客户端。
> 由于存在各式各样的变体和细节差异，对应地派生了各式远程过程调用协议，而且它们并不互相兼容。

## RPC  vs RESTful

RPC的消息传输可以通过TCP，UDP，HTTP等协议，(有时候我们称之为 RPC over TCP、 RPC over HTTP)

RPC 通过 HTTP 传输消息的时候和 RESTful的架构是类似的，但是也有不同。

### 第一、

RPC 的**客户端和服务器端是紧耦合**的，客户端需要知道调用的过程的名字，过程的参数以及它们的类型、顺序等。一旦服务器更改了过程的实现，客户端的实现很容易出问题。

RESTful基于 http的语义操作资源，参数的顺序一般没有关系，也很容易的通过代理转换链接和资源位置，从这一点上来说，RESTful 更灵活。

### 第二、

它们**操作的对象**不一样。 RPC 操作的是方法和过程，它要操作的是方法对象。 RESTful 操作的是资源(resource)，而不是方法。

### 第三、

RESTful执行的是对资源的操作，增加、查找、修改和删除等,主要是CURD，



RPC over TCP可以通过长连接减少连接的建立所产生的花费，在调用次数非常巨大的时候，这个花费影响是非常巨大的。

当然 RESTful 也可以通过 keep-alive 实现长连接， 但是它最大的一个问题是它的request-response模型是阻塞的 (http1.0和 http1.1, http 2.0没这个问题)，发送一个请求后只有等到response返回才能发送第二个请求 (有些http server实现了pipeling的功能，但不是标配)， **RPC的实现没有这个限制**。

## 起步

#### 安装

```
go get -u -v githug.com/smallnest/rpcx/...
```

这一步只会安装 rpcx 的基础功能。如果要使用 etcd 作为注册中心，需要加上`etcd`这个标签

```
go get -u -v -tags "etcd" github.com/smallnest/rpcx/...
```

tags：

- quic 支持quic协议
- kcp  支持kcp协议
- zookeeper 支持zookeeper协议
- etcd 支持etcd注册中心
- consul 支持consul 注册中心
- ping 支持网络质量负载均衡
- reuseport 支持reuseport

### 实现Service

实现一个service

```go
import "context"

type Args struct{
    A int
    B int
}
type Reply struct{
    C int
}
type Arith int
func(t *Arith)Mul(ctx context.Context,args:*Args,reply,*Reply)error{
    reply.C=arg.A*arg.B
    return nil
}
```

### 实现server

注册服务

```go
s:=server.NewServer()
s.RegisterName("Airth",new(Airth),"")
s.Serve("tcp",":8972")
```

命名了一个Airth的服务

注册服务

```go
s.Register(new(exmple.Airth),"")
```

使用服务的 类型名称 作为 服务名。

### 实现Client

```go
    // #1
    d := client.NewPeer2PeerDiscovery("tcp@"+*addr, "")
    // #2
    xclient := client.NewXClient("Arith", client.Failtry, client.RandomSelect, d, client.DefaultOption)
    defer xclient.Close()
    // #3
    args := &example.Args{
        A: 10,
        B: 20,
    }
    // #4
    reply := &example.Reply{}
    // #5
    err := xclient.Call(context.Background(), "Mul", args, reply)
    if err != nil {
        log.Fatalf("failed to call: %v", err)
    }
    log.Printf("%d * %d = %d", args.A, args.B, reply.C)
```

#1 使用点对点(Peer2peerDiscovery)实现服务发现。客户端直接连服务器来获取服务地址。

#2 创建了XClient，并且`FailMode`、 `SelectMode` 和默认选项。

- FailMode 告知客户端如何吃力调用失败：重试，快速返回，或者尝试另一台服务器
- SelectMode 告诉了客户端如何再多台服务提供了同一服务的情况下选择服务器。

#3 定义了请求

#4定义了响应对象，默认值为0，事实上 rpcx 会通过它来知晓返回结果的类型，然后把结果反序列化到这个对象。

#5 调用了远程服务并且同步获取结果

### 异步调用Server

```go
    d := client.NewPeer2PeerDiscovery("tcp@"+*addr2, "")
    xclient := client.NewXClient("Arith", client.Failtry, client.RandomSelect, d, client.DefaultOption)
    defer xclient.Close()
    args := &example.Args{
        A: 10,
        B: 20,
    }
    reply := &example.Reply{}
    call, err := xclient.Go(context.Background(), "Mul", args, reply, nil)
    if err != nil {
        log.Fatalf("failed to call: %v", err)
    }
    replyCall := <-call.Done
    if replyCall.Error != nil {
        log.Fatalf("failed to call: %v", replyCall.Error)
    } else {
        log.Printf("%d * %d = %d", args.A, args.B, reply.C)
    }
```

## 服务端实例

在服务端实现Server，Service的类型并不重要。可以使用自定义类型来保持状态，或者直接使用 `struct{}`、 `int`。

需要启动一个TCP 或者UDP服务来暴露Service。

可以添加一些plugin来为服务添加新特性

### Service

作为服务的提供者，首先需要**定义服务**。当前rpcx仅支持 可导出的 `methods` 作为服务的函数。

导出方法的要求

- 必须是可导出类型
- 接收三个参数 第一个参数为context.Context 其余的均为内置的类型
- 第三个参数是一个指针
- 有一个error类型的返回值

对于**服务的注册** 使用`RegeisterName`，名字叫做name

若使用Regeister，生成的服务的名字就是rcvr的类型别名。

```go
func (s *Server) Register(rcvr interface{}, metadata string) error
```

```go
func (s *Server) RegisterName(name string, rcvr interface{}, metadata string) error
```

例：

```go
import "context"

type Args struct{
    A int
    B int
}
type Reply struct{
    C int
}
type Arith int

func(t *Airth)Mul(ctx context.Context,args *Args,reply *Reply)error{
    reply.C=args.A*args.B
    return nil
}
```

### server

服务定义完成之后，需要将其暴露，启动一个TCP或者UDP的服务进行监听

服务器支持以下的方式启动、监听和关闭

```go
func NewServer(option ..Option)*Server
```

```go
func (s* Server) Close() error

func(s *Server) RegisterOnShutdown(f func())

func(s *Server)Serve(network,address string)(err error)

func(s *Server)ServerHttp(w http.ResponseWriter,req *http.Request)
```

使用`NewSever`创建一个服务器实例，调用Server或者ServerHTTp进行监听

可以设置读写超时和tls证书

ServerHTTP将HTTP服务暴露

Serve 通过TCP和UDP协议与客户端通信

Serve包含的字段

```go
type Server struct {
    Plugins PluginContainer
    // AuthFunc 可以用来鉴权
    AuthFunc func(ctx context.Context, req *protocol.Message, token string) error
    // 包含过滤后或者不可导出的字段
}
```

Plugins 服务器上的插件

AuthFunc可以检查客户端是否被授权了的鉴权函数

rpcx 支持如下的网络类型：

- tcp: 推荐使用
- http: 通过劫持http连接实现
- unix: unix domain sockets
- reuseport: 要求 `SO_REUSEPORT` socket 选项, 仅支持 Linux kernel 3.9+
- quic: support [quic protocol](https://en.wikipedia.org/wiki/QUIC)
- kcp: sopport [kcp protocol](https://github.com/skywind3000/kcp)

服务器实例：

```go
package main
import (
    "flag"
    example "github.com/rpcx-ecosystem/rpcx-examples3"
    "github.com/smallnest/rpcx/server"
)
var (
    addr = flag.String("addr", "localhost:8972", "server address")
)
func main(){
    flag.Parse()
    s:=server.NewServer()
    s.RegisterName("Arith",new(example.Arith),"")
    // s.Register(new(example.Arith),"")
    s.Serve("tcp",*addr)
}
```

## 客户端示例

客户端使用和服务同样的通信协议来发送请求和获取响应。

```go
type Client struct{
    Conn net.Conn
    plugins PluginsContainer
}
```

Conn 代表客户端和服务端之间的连接，pulgins表示插件

### 方法

```go
    func (client *Client) Call(ctx context.Context, servicePath, serviceMethod string, args interface{}, reply interface{}) error
    func (client *Client) Close() error
    func (c *Client) Connect(network, address string) error
    func (client *Client) Go(ctx context.Context, servicePath, serviceMethod string, args interface{}, reply interface{}, done chan *Call) *Call
    func (client *Client) IsClosing() bool
    func (client *Client) IsShutdown() bool
```

`Call` 代表对服务的同步调用，客户端在接收到响应或错误前一直是**阻塞的**。然而`Go`是异步调用的，它返回一个指向Call的指针， 可以检查*Call的值来获取返回的结果或错误。

`Close` 会关闭所有与服务的连接，立刻关闭，不会等待未完成的请求结束

`IsClosing` 表示客户端是关闭的并且不会接收新的调用

`IsShutdown`表示客户端不会接受服务返回的响应。

`Client`使用默认的 [CircuitBreaker]来处理错误，这是rpc处理错误的普遍做法。当出错率达到阈值， 这个服务就会在接下来的10秒内被标记为不可用。也可以实现自定义的CircuitBreaker。

### 例

```go
client=&client{
	option:DefaultOption
}
err:=clietn.Connect("tcp",addr)
if err!=nil{
    t.Fatalf("failed to connect:%v",err)
}
dafer client.Close()
args:=&Args{
    A:12,
    B:20,
}

replt=&Reply
err=client.Call(context.Barkground(),"Arith","Mul",args,reply)
if err!=nil{
    t.Fatalf("failed to call:%v",err)
}
if replc.C!=240{
    t.Fatalf("expect 240 bug got %v",replc.C)
}
```

### Xclient

xclient是对客户端的封装，增加了一些服务发线和服务治理的特性

```go
type XClient interface {
    SetPlugins(plugins PluginContainer)
    ConfigGeoSelector(latitude, longitude float64)
    Auth(auth string)
    Go(ctx context.Context, serviceMethod string, args interface{}, reply interface{}, done chan *Call) (*Call, error)
    Call(ctx context.Context, serviceMethod string, args interface{}, reply interface{}) error
    Broadcast(ctx context.Context, serviceMethod string, args interface{}, reply interface{}) error
    Fork(ctx context.Context, serviceMethod string, args interface{}, reply interface{}) error
    Close() error
}
```

SetPlugins 设置Plugin容器，Auth设置鉴权token

`ConfigGeoSelector` 是一个可以通过地址位置选择器来设置客户端的经纬度的特别方法。

一个xclient只对一个服务负责，可以通过serverMethod参数来调用这个服务的所有方法，若要调用多个服务，必须为每个服务创建一个xclient

一个应用中，一个**服务**只需要一个**共享的XClient**。它可以被通过goroutine共享，并且是协程安全的。

Go代表异步调用，Call代表同步调用

*Xclient对于一个服务节点使用单一的连接，并且他会缓存这个连接直到失效或者异常。*

### 服务发现

rpcx 支持许多服务发现机制，也可以实现自己的服务发现。

- - [Peer to Peer](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#peer2peer): 客户端直连每个服务节点。 the client connects the single service directly. It acts like the `client` type.
  - [Peer to Multiple](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#multiple): 客户端可以连接多个服务。服务可以被编程式配置。
  - [Zookeeper](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#zookeeper): 通过 zookeeper 寻找服务。
  - [Etcd](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#etcd): 通过 etcd 寻找服务。
  - [Consul](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#consul): 通过 consul 寻找服务。
  - [mDNS](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#mdns): 通过 mDNS 寻找服务（支持本地服务发现）。
  - [In process](https://www.bookstack.cn/read/go-rpc-programming-guide-latest/part2-registry.md#inprocess): 在同一进程寻找服务。客户端通过进程调用服务，不走TCP或UDP，方便调试使用。

### 服务治理

rpcx支持故障模式：

- Failfast:如果调用失败，立即返回错误
- Failover：选择其他节点，直到达到最大的重试次数
- Failtry：选择相同节点并重试，直到达到最大的重试次数

负载均衡，rpcx提供了很多选择器：

- Random：随机选择节点
  - Roundrobin：使用roundrobin算法选择节点
  - Consistent hashing：如果服务路径、方法和参数一致，就选择同一个节点，使用了非常快的 jump consistent hash算法
  - Weighted: 根据元数据里配置好的权重(weight=xxx)来选择节点
  - Network quality 根据ping的结果来选择节点，网络越好被选择的几率越大
  - Grography 若由多个数据中心，客户端趋向于连接同一个数据机房的节点
  - Customized Seledtor 自定义选择器

### 广播和群发

特殊情况下使用XClient中的`Boradcast`和`Fork`方法

```go
    Broadcast(ctx context.Context, serviceMethod string, args interface{}, reply interface{}) error
    Fork(ctx context.Context, serviceMethod string, args interface{}, reply interface{}) error
```

Broadcast **表示向所有服务器发送请求，只有所有服务器正确返回时才会成功**，**此时FailMode 和 SelectMode的设置是无效的。请设置超时来避免阻塞。**

Fork  表示向所有服务器发送请求，只要**任意一台服务器正确返回就成功**。此时FailMode 和 SelectMode的设置是无效的。

使用NewClient获取一个XClient

```go
func NewXClient(servicePath string, failMode FailMode, selectMode SelectMode, discovery ServiceDiscovery, option Option) XClient
```

必须使用服务名称作为第一参数，然后是其他选项。

### 例：

```go
package main
import (
    "context"
    "flag"
    "log"
    example "github.com/rpcx-ecosystem/rpcx-examples3"
    "github.com/smallnest/rpcx/client"
)
var (
    addr2 = flag.String("addr", "localhost:8972", "server address")
)
func main() {
    flag.Parse()
    d := client.NewPeer2PeerDiscovery("tcp@"+*addr2, "")
    xclient := client.NewXClient("Arith", client.Failtry, client.RandomSelect, d, client.DefaultOption)
    defer xclient.Close()
    args := &example.Args{
        A: 10,
        B: 20,
    }
    reply := &example.Reply{}
    call, err := xclient.Go(context.Background(), "Mul", args, reply, nil)
    if err != nil {
        log.Fatalf("failed to call: %v", err)
    }
    replyCall := <-call.Done
    if replyCall.Error != nil {
        log.Fatalf("failed to call: %v", replyCall.Error)
    } else {
        log.Printf("%d * %d = %d", args.A, args.B, reply.C)
    }
}
```

## 传输transport

rpcx通过 TCP、HTTP、UnixDomain、QUIC和KCP通信，也可以使用http客户端通过网关或者http调用来访问rpcx服务。

### TCP

最常用的通信方式。高性能易上手,可以使用TLS加密TCP流量。

服务端使用 `tcp` 做为网络名并且在注册中心注册了名为 `serviceName/tcp@ipaddress:port` 的服务。

```go
d := client.NewPeer2PeerDiscovery("tcp@"+*addr, "")
xclient := client.NewXClient("Arith", client.Failtry, client.RandomSelect, d, client.DefaultOption)
defer xclient.Close()
```

### HTTP Connect

发送 `HTTP CONNECT` 方法给 rpcx 服务器。 Rpcx 服务器会劫持这个连接然后将它作为TCP连接来使用。

注：**客户端和服务端并不使用http请求/响应模型来通信，他们仍然使用二进制协议。**

网络名称是 `http`， 它注册的格式是 `serviceName/http@ipaddress:port`。

### TLS

在服务端配置TLS

```go
func main() {
    flag.Parse()
    cert, err := tls.LoadX509KeyPair("server.pem", "server.key")
    if err != nil {
        log.Print(err)
        return
    }
    config := &tls.Config{Certificates: []tls.Certificate{cert}}
    s := server.NewServer(server.WithTLSConfig(config))
    s.RegisterName("Arith", new(example.Arith), "")
    s.Serve("tcp", *addr)
}
```

在客户端设置TLS

```go
func main() {
    flag.Parse()
    d := client.NewPeer2PeerDiscovery("tcp@"+*addr, "")
    option := client.DefaultOption
    conf := &tls.Config{
        InsecureSkipVerify: true,
    }
    option.TLSConfig = conf
    xclient := client.NewXClient("Arith", client.Failtry, client.RandomSelect, d, option)
    defer xclient.Close()
    args := &example.Args{
        A: 10,
        B: 20,
    }
    reply := &example.Reply{}
    err := xclient.Call(context.Background(), "Mul", args, reply)
    if err != nil {
        log.Fatalf("failed to call: %v", err)
    }
    log.Printf("%d * %d = %d", args.A, args.B, reply.C)
}
```

## 函数

将方法注册为服务

- 必须是可导出类型的方法
- 接受3个参数，第一个是 `context.Context`类型，其他2个都是可导出（或内置）的类型。
- 第3个参数是一个指针
- 有一个 error 类型的返回值

rpcx将纯函数注册为服务，满足以下条件

- 函数可以是可导出的或者不可导出的
- 接受3个参数，第一个是 `context.Context`类型，其他2个都是可导出（或内置）的类型。
- 第3个参数是一个指针
- 有一个 error 类型的返回值

服务端必须使用ReginterFunction来注册一个函数并且提供一个服务名

```go
type Args struct {
A int
B int
}

type Reply struct {
C int
}

func mul(ctx context.Context, args Args, reply Reply) error {
reply.C = args.A * args.B
return nil
}

func main() {
	flag.Parse()
    s := server.NewServer()
	s.RegisterFunction("a.fake.service", mul, "")
	s.Serve("tcp", *addr)
}    
```



客户端通过服务命和函数名来调用服务

```go
 d := client.NewPeer2PeerDiscovery("tcp@"+*addr, "")
    xclient := client.NewXClient("a.fake.service", client.Failtry, client.RandomSelect, d, client.DefaultOption)
    defer xclient.Close()
    args := &example.Args{
        A: 10,
        B: 20,
    }
    reply := &example.Reply{}
    err := xclient.Call(context.Background(), "mul", args, reply)
    if err != nil {
        log.Fatalf("failed to call: %v", err)
    }
    log.Printf("%d * %d = %d", args.A, args.B, reply.C)
```
