# context

goroutine 的上下文，包含goroutine的运行状态，环境，现场信息。

主要用于goroutine之间传递上下文信息，包括：取消信号，超时时间，截止时间，K-v等。

context用于解决goroutine之间**退出通知**，**元数据传递**的功能。

> context定义了上下文类型，该类型在**API边界**之间和进程之间携带截止日期，**取消信号**和其**他请求范围**的值。

每一个Context都从顶层的Goroutine向下层层传递，这也是拱廊上下文中常用的传递方式，若没有Context，当上层执行出错时，下层其实不会收到错误而是会继续执行下去。

当最上层的goroutine因为某些原因执行失败时，下两层的goroutine由于没有接收到错误信息，所以会继续工作，当使用了context之后，就会避免此类情况的出现，减少额外的资源消耗

golang中的上下文：在不同goroutine之间对信号进行同步避免计算资源消耗，于此同时，context还能携带以请求为作用域的键值对信息。

## 官文介紹：

向服務器的**傳入**請求**應創**建一個**context**，對服務器的**傳出**調用應**接受**一個**context**。之間的**函數調用鏈**必須傳播**Context**。或者可以選擇將其替換爲WithCancel，WithDeadline, WithTimeout， WithValue創建的派生Context， **取消context之後，所有的派生context也將被取消**。

## 隸屬方法：

### withCancel

可以在`Context`中创建出一个**新的子上下文**，同时还会返回用于**取消上下文的函数**

> 返回具有**新的具有完成通道得父级副本**，当调用返回的取消函数或关闭父上下文的Done通道时（以先发生的为准），关闭返回的上下文的Done通道。取消此上下文会释放与之关联的资源，因此代码**应在此上下文中运行的操作完成后立即调用cancel**。

```go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
	c := newCancel Ctx(parent)
	propagateCancel(parent, &c)
	return &c, func() { c.cancel(true, Canceled) }
}
```



### WithDeadline

```go
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc)
```

返回父context得副本，如果父项的截止日期早于d，则WithDeadline（parent，d）在语义上等效于父项。当截止日期到期，调用返回的取消函数或关闭父上下文的Done通道时，以先到者为准，关闭返回的上下文的Done通道。取消此上下文会释放与之关联的资源，因此代码应在此上下文中运行的**操作完成后**立即调用**cancel**。

### WithTimeout

```go
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc) {
	return WithDeadline(parent, time.Now().Add(timeout))
}
```

WithTimeout返回WithDeadline，取消此上下文会释放与其关联得资源，因此代码应在次上下文运行得操作完成后立即调用cancel

### withValue(传值方法)

WithValue返回父项的副本，其中与键关联的值为val。仅将上下文值用于传递过程和API的请求范围数据，而不用于将可选参数传递给函数。提供的**键**必须具有**可比性**，并且**不能为字符串类型或任何其他内置类型**，以**避免使用**上下文包之间发生**冲突**。

>  WithValue的用户应定义自己的 密钥类型。为了避免在分配给 接口{}时进行分配，上下文键通常具有具体的类型 struct {}。或者，导出的上下文键变量的静态类型应为指针或接口。

```go
func WithValue(parent Context, key, val interface{}) Context {
	if key == nil {
		panic("nil key")
	}
	if !reflectlite.TypeOf(key).Comparable() {
		panic("key is not comparable")
	}
	return &valueCtx{parent, key, val}
}

```

WithCancel： 调用cancel时关闭Done

WithDeadline： 截止日期到期时关闭

WithTimeout： 超时/结束时关闭

函数采用 Context（父级）并**返回**派生的**Context**（子级）和 **CancelFunc**。

調用**cancelFunc**取消子項以及子項，**刪除父級以及對該子項的引用**，并且**停止任何關聯計時器**。無法调用cancelFunc会泄漏，直到**父级被取消或计时器触发为止**。 审查工具**检查**所有**控制路径上是否都使用了cancelfuncs**。

### 守则：

需遵循以下的守则，以便于保持接口在包之间保持一致，并使用静态工具可以检查context： 

- **不**要将context**存储与struct**中，而是将其显示的传递与函数之间
- 在**函数中**常为**第一个**参数，命名为**ctx**。

```go
func DoSomething(ctx context.Context, arg Arg) error {
// 		// ... use ctx ...
}
```

- **不**要向函数传入一个**nil**的context，(万能的todo)
- 相同的context可以传递给不同额goroutine中运行的函数
- context 可以安全的被多个goroutine所使用
- 仅将context值用于传递过程和API请求范围数据，而不能用于将可选参数传递给函数

## 接口

`Context`是一个接口，下属4个方法

- Done 返回一个channel，可以表示context被取消的信号；
  - 当这个channel被关闭时，说明context被取消了。注：这只是一个**只读**的channel。（这是一个只读的通道，因此在子协程里读取这个channel，除非被关闭，否则读不出东西，否则读不出任何东西），子协程从channel里读出了值，可以做一些收尾工作，尽快退出。连续调用Done将返回相同的值。
  - 这个channel会在当前工作完成或者上下文被取消之后关闭。
- Err() 返回一个错误，表示channel被关闭的原因，未完成关闭则nil，
  - Done**已关闭**则返回一个**非nil的错误**（如果context被取消则取消，
  - 如果超时则`DeadlineExceeded`,）Err返回非nil的错误后，对其连续调用则返回相同的错误。
- Deadline() 返回context截至的时间(工作完成时间)，通过此时间函数可以决定是否进行接下来的操作，
  - 如果未设置截止日期，则截止日期返回ok == false。连续调用Deadline会返回相同的结果，或者可以用这个时间设置一个i/o操作的超时时间
- Value()   返回与此键的上下文关联的值；
  - 如果没有值与键关联，则返回nil 。
  - 相同的键连续调用Value将返回相同的结果，
  - （仅context将用于**跨进程和API边界的请求范围数据**，而**不用**于将可选参数**传递给函数**，）可以表示context中的特定值。

`canceler` 接口类型，下属两个方法

```go
type canceler interface {
    cancel(removeFromParent bool, err error)
    Done() <-chan struct{}
}
```

实现了cnacel的context 表明context是**可取消**的。

如此设计的原因：

- `取消`操作应该是建议性的而非强制,*caller 不应该去关心、干涉 callee 的情况，决定如何以及何时 return 是 callee 的责任。caller 只需发送“取消”信息，callee 根据收到的信息来做进一步的决策，因此接口并没有定义 cancel 方法*
- “取消“操作是可传递的。*“取消”某个函数时，和它相关联的其他函数也应该“取消”。因此，`Done()` 方法返回一个只读的 channel，所有相关函数监听此 channel。一旦 channel 关闭，通过 channel 的“广播机制”，所有监听者都能收到。*

### 默认上下文

context包中，经常使用`context.Background`和`context.TODO`,这两个方法最终会返回一个预先初始化好的私有变量，`background`和`todo`

Background和TODO某种意义上互为别名，二者没有太大的区别，

不过`Background`是上下文中最顶层的默认值，所有其他的上下文都应从其演化而来。

> 在不确定时使用 context.TODO() ，在多数情况下如果函数没有上下文作为入参，往往都会使用 context.Background() 作为起始的 Context 向下传递



这两个变量是在包初始化时就被创建好的，它们都是通过 new(emptyCtx) 表达式初始化的指向私有结构体 emptyCtx 的指针.

## 结构体

### emptyCtx

emptyCtx永远不会取消，没有值（无论合适调用都会返回`nil`或者空值，并灭有任何的特殊功能），也没有截止日期。它不是struct {}，因为此类型的var必须具有不同的地址。

```go
type emptyCtx int
func (*emptyCtx) Deadline() (deadline time.Time, ok bool) {
    return
}
func (*emptyCtx) Done() <-chan struct{} {
    return nil
}
func (*emptyCtx) Err() error {
    return nil
}
func (*emptyCtx) Value(key interface{}) interface{} {
    return nil
}
```

其被包装成了：

```go
var (
	background =new(emptyCtx)
	todo = new(emptyCtx)
)
```

然后经过两个函数对外公开

```go
func Background() Context {
    return background
}
func TODO() Context {
    return todo
}
```

`background`常用于main函数中，作为context的**根**节点.

> Background返回一个非空的Context。它永远不会被取消，没有值，也没有截止日期。它通常由主要功能，初始化和测试使用，并且用作传入请求的顶级上下文。

`todo`常用于并不知道传递什么context的情形。

> TODO返回一个非空的context，
>
> 调用一个需要传递 context 参数的函数，你手头并没有其他 context 可以传递，这时就可以传递 todo。这常常发生在重构进行中，给一些函数添加了一个 Context 参数，但不知道要传什么，就用 todo “占个位子”，最终要换成其他 context。

### cancelCtx

```go
type cancelCtx struct {
    Context
    // 保护之后的字段
    mu       sync.Mutex
    done     chan struct{}
    children map[canceler]struct{}
    err      error
}
```

`cancle()`的功能就是**关闭channel**，c.done：递归取消它所有的子节点 ，父结点从删除自己，达到效果是通过关闭channel，将取消信号传递给了它所有的子节点，goroutine接收到取消信号的方式就是select语句中的`c.done`被选中。

### TimerCtx

timerCtx 基于 cancelCtx，只是多了一个 time.Timer 和一个 deadline。Timer 会在 deadline 到来时，自动取消 context。



```go
type timerCtx struct {
    cancelCtx
    timer *time.Timer // Under cancelCtx.mu.
    deadline time.Time
}
```

timerCtx 首先是一个 cancelCtx，所以它能取消。



### 应用

创建：

```go
func Background() Context
```

background是一个空的context，不能被取消，没有值，也没有超时时间。

context会在函数间传递，只需要在适当的时间调用cancel函数向goroutine发出取消信号或者调用value函数取出context中的值。

- background 通产用于main函数之中，作为所有context的**根节点**
- todo 通常用在并不知道传递什么 context的情形。  用todo占位，最终转换成其他的context



### 传递共享的数据

```go
package main
import (
	"context"
    "fmt"
)

func main(){
    ctx:=context.Background()
    process(ctx)
    
    ctx=context.WithValue(ctx,"traceId")
    process(ctx)
}

func process(ctx context.Context){
    traceId,ok:=ctx.Value("traceId").(string)
    if ok{
        fmt.Printf("process over trace_id=%s \n",traceId)
    }else{
        fmt.Printf("process over no trace_id \n")
    }   
}
```

结果为：

```
process over. no trace_id
process over. trace_id=qcrao-2019
```

第一次调用process时，ctx是一个空的context，自然取不出数据来，第二次 通过`WithValue`函数创建了一个context，并附上了`traceId`这个key，自然就能取出传来的value。



### 取消goroutine

> 某个场景： 打开外卖的订单页，地图上显示外卖小哥的位置，而且是每秒更新 1 次。app 端向后台发起 websocket 连接（现实中可能是轮询）请求后，后台启动一个协程，每隔 1 秒计算 1 次小哥的位置，并发送给端。如果用户退出此页面，则后台需要“取消”此过程，退出 goroutine，系统回收资源。

```go
func perform(ctx context.Context){
    for{
        calculatePos()
        sendResult()
        select{
            case <-ctx.Done()
            	//  被取消则直接返回
            	return
            case <-time.After(time.Second)
        }
    }
}
```

主流程：

```go
ctx, cancel := context.WithTimeout(context.Background(), time.Hour)
go Perform(ctx)
// ……
// app 端返回页面，调用cancel 函数
cancel()
```

注：WithTimeOut函数返回的context和cancalFun是分开的。**context**本身没有**取消函数**，(取消函数只能由外层函数调用,防止子节点context调用取消函数,从而严格控制信息的流向：由父节点流向子节点。)

### 防止goroutine泄漏

```go
func gen(ctx context.Context) <-chan int {
    ch := make(chan int)
    go func() {
        var n int
        for {
            select {
            case <-ctx.Done():
                return
            case ch <- n:
                n++
                time.Sleep(time.Second)
            }
        }
    }()
    return ch
}
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel() // 避免其他地方忘记 cancel，且重复调用不影响
    for n := range gen(ctx) {
        fmt.Println(n)
        if n == 5 {
            cancel()
            break
        }
    }
    // ……
}
```

增加一个 context，在 break 前调用 cancel 函数，取消 goroutine。gen 函数在接收到取消信号后，直接退出，系统回收资源。

