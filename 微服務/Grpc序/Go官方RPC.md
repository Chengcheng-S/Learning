# Go官方的RPC

Go官方提供了一个RPC的库：`net/rpc`

> 提供了通过网络访问一个对象的输出方法的能力，服务器需要**注册对象**，通过对象的类型名**暴露服务**。注册后这个对象的输出方法就可以**远程调用**，
>
> 这个库封装了底层传输的细节，包括序列化(默认GOB序列化器)
>
> 服务器可以注册**多个不同类型**的对象，但是注册**相同类型**的多个对象时会**出错**



如果对象的方法要能远程访问，它们必须满足一定的条件

- 方法类型时可输出的，
- 方法本身也是可输出的
- 方法必须由两个参数，必须是**输出类型**或者是**内建类型**
- 方法的第二个参数必须是指针类型
- 方法的返回类型为error

```go
func (t *T)Name(type T1,type *T2)error{}
```

服务器通过调用`ServeConn`在一个连接上处理请求， 它可以创建一个network listener然后accept请求。
对于HTTP listener来说，可以调用 `HandleHTTP` 和 `http.Serve`

客户端调用`Dail`和`DailHTTP`建立连接，使用`Call`或`Go`可以同步或者异步的调用服务，异步方法调用`Go` 通过 `Done` channel通知调用结果返回。

注:除非显式设置`codec`否则这个库默认使用包`encoding/gob`作为序列化框架

### 例：

两个数相乘和相除的方法：

第一步定义传入参数和返回参数的数据结构

```go
package server
type Args struct{
    A,B int
}
type Quotient struct{
    Quo,Rem int
}
```

第二步定义一个服务对象

```go
type Airth int
```

第三步实现方法

```go
func (t *Airth)Multiply(arg *Args,reply *int)error{
	*reply=args.A*args.B
    return nil
}


func (t *Arith) Divide(args *Args, quo *Quotient) error {
    if args.B == 0 {
        return errors.New("divide by zero")
    }
    quo.Quo = args.A / args.B
    quo.Rem = args.A % args.B
    return nil
}
```

第四步实现RPC服务器：

```go
arith:=new(Airth)
rpc.Register(airth)
rpc.HandleHTTP()
l,e=net.listen("tcp",":1234")
if e!=nil{
    log.Fatal("listen error",e)
}
go http.Serve(l,nil)
select{}
```

以HTTP的形式暴露服务，客户端即可对定义的方法进行调用

```go
client,err:=rpc.DiaHTTP("tcp",serverAddress+":1234")
if err!=nil{
    log,=.Fatal("dialing",err)
}
```

对客户端进行远程调用(同步)

```go
args:=&server.Args{5,6}
var reply int
err=client.Call("Airth.Multiply",args.&reply)
if err!=nil{
    log.Fatal("airth error",err)
}
fmt.Println("%d,%d,%d",arg.A,args.B,reply)
```

异步：

```go
quotient := new(Quotient)
divCall := client.Go("Arith.Divide", args, quotient, nil)
replyCall := <-divCall.Done  
```

## 服务器程序分析

`net/rpc`定义了一个缺省的Server,所以Server的很多方法可以直接调用，这对于一个简单的Server的实现更方便，但是如果需要配置不同的Server，

```go
var DefaultServer = NewServer()
```

server有多种Socket监听方式

```go
    func (server *Server) Accept(lis net.Listener)
    func (server *Server) HandleHTTP(rpcPath, debugPath string)
    func (server *Server) ServeCodec(codec ServerCodec)
    func (server *Server) ServeConn(conn io.ReadWriteCloser)
    func (server *Server) ServeHTTP(w http.ResponseWriter, req *http.Request)
    func (server *Server) ServeRequest(codec ServerCodec) error
```

`ServeHTTP` 实现了处理 http请求的业务逻辑， 它首先处理http的 `CONNECT`请求， 接收后就Hijacker这个连接conn， 然后调用`ServeConn`在这个连接上　处理这个客户端的请求。

> `Server.HandleHTTP`设置rpc的上下文路径，`rpc.HandleHTTP`使用默认的上下文路径｀DefaultRPCPath｀、 `DefaultDebugPath`。
> 这样，当你启动一个http server的时候 ｀http.ListenAndServe｀，上面设置的上下文将用作RPC传输，这个上下文的请求会教给`ServeHTTP`来处理。

`Accrpt`处理一个监听器，一致监听客户端的连接，一旦监听器接受了一个连接，则交给`ServeConn`在另一个goroutine中处理

```go
func (server *Server) Accept(lis net.Listener) {
    for {
        conn, err := lis.Accept()
        if err != nil {
            log.Print("rpc.Serve: accept:", err.Error())
            return
        }
        go server.ServeConn(conn)
    }
}
```

`ServeConn`的实现

```go
func (server *Server) ServeConn(conn io.ReadWriteCloser) {
    buf := bufio.NewWriter(conn)
    srv := &gobServerCodec{
        rwc:    conn,
        dec:    gob.NewDecoder(conn),
        enc:    gob.NewEncoder(buf),
        encBuf: buf,
    }
    server.ServeCodec(srv)
}
```

连接交给ServeCodec处理，此处默认使用gobServerCodec去处理(一个未输出默认的编解码器)

```go
func (server *Server) ServeCodec(codec ServerCodec) {
    sending := new(sync.Mutex)
    for {
        service, mtype, req, argv, replyv, keepReading, err := server.readRequest(codec)
        if err != nil {
            if debugLog && err != io.EOF {
                log.Println("rpc:", err)
            }
            if !keepReading {
                break
            }
            // send a response if we actually managed to read a header.
            if req != nil {
                server.sendResponse(sending, req, invalidRequest, codec, err.Error())
                server.freeRequest(req)
            }
            continue
        }
        go service.call(server, sending, mtype, req, argv, replyv, codec)
    }
    codec.Close()
}
```

其在连接中读取请求，然后调用`go service.call`在另外的goroutine中处理服务调用

- 对象重用，Request和Resonse都是可重用的，同构Lock处理竞争，
- 使用了大量的goroutine。
- 业务处理是异步的, 服务的执行不会阻塞其它消息的读取。

server提供的注册方法

```go
    func (server *Server) Register(rcvr interface{}) error
    func (server *Server) RegisterName(name string, rcvr interface{}) error
```

第二个方法为服务起一个别名，否则服务名已它的类型命名,它们俩底层调用`register`进行服务的注册。

## 客户端程序分析

客户端和服务器建立连接

```go
    func Dial(network, address string) (*Client, error)
    func DialHTTP(network, address string) (*Client, error)
    func DialHTTPPath(network, address, path string) (*Client, error)
    func NewClient(conn io.ReadWriteCloser) *Client
    func NewClientWithCodec(codec ClientCodec) *Client
```

`DialHTTP` 和 `DialHTTPPath`是通过HTTP的方式和服务器建立连接，他俩的区别之在于**是否设置上下文路径**:

而`Dial`则通过TCP直接连接服务器

`NewClient`则创建一个缺省codec为glob序列化库的客户端:

客户端的调用方法`Call`,`Go`.`Go`方法是异步的，它返回一个 Call指针对象， 它的Done是一个channel，如果服务返回，

Done就可以得到返回的对象(实际是Call对象，包含Reply和error信息)。 `Call`是同步的方式调用，它实际是调用`Go`实现的，















