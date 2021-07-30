# Goroutines和Channels

## GO中的并发程序

goroutine和channel，其支持"顺序通信进程"简称为GSP(线代的并发编程模型)，在这种模型中值会在不同的运行实例(goroutine)中传递。

Go 语言不但有着独特的并发编程模型，以及用户级线程 goroutine，还拥 有强大的用于调度 goroutine、对接系统级线程的调度器。这个调度器是 Go 语言运行时系统的重要组成部分，它主要负责统筹调配 Go 并发编程模型 中的三个主要元素，即：G（goroutine 的缩写）、P（processor 的缩写）和 M（machine 的缩写）。

M指代的是系統及綫程，而p指的則是一種可以承載若干個G,且能夠使這些G適時的與M進行對接，并得到真正運行的中介。(p是context，保存goroutine运行所需要的上席文，维护了可运行runnable和goroutine列表)，**M和P是G运行的基础**。

宏觀上來看，G和M由於p的存在可以呈現出多對多的關係，當一個正在與某個M對接並運行著的G，需要因某個時間而暫停運行的時候，調度器總會及時出現，并把這個G和M分開，以釋放计算资源供那些等待运行的 G 使用。

而当一个 G 需要恢复运行的时候，调度器又会尽快地为它寻找空闲的计算资源（包括 M） 并安排运行。另外，当 M 不够用时，调度器会帮我们向操作系统申请新的系统级线程，而 当某个 M 已无用时，调度器又会负责把它及时地销毁掉。

![img](https://static.bookstack.cn/projects/qcrao-Go-Questions/b91ec343def3d9a87d4c645b88ba415c.png)

## Goroutine

在GO语言中，每一个并发的执行单元叫做goroutine(類似於協程)，当一个程序启动时，其主函数即在一个单独的goroutine中运行(可以称为mian goroutine)，而新的goroutine将通过关键字`go`来创建，在语法上go程序是一个普通函数或者方法调用前加上关键字`go`，go语句会使其语句中的函数在一个新创建的gorutine中运行，而go语句本身会迅速完成。

```go
func  f()  //   crate a function name`s f
f()       // call f()  wait for it to return
go f()    // crate a new goroutine that calls function f don`t wait
```

主函数结束时，所有的goroutine都会被直接打断，程序退出。简单来说除了主函数退出或者程序终止，没有其他的编程方法让一个goroutine来打断另一个执行。

調度器不能保證多個goroutine執行次序，且進程退出時不會等待它們結束。默認情況下，進程啓動後僅允許一個系統綫程服務于`goroutine`可使用環境變量或標準庫函數`runtime.GOMAXPROCS`修改，讓調度器用多個綫程實現多核并行，而不僅僅是并發。

## channels

goroutine是Go程序的并发体的话，channels它们之间的通信机制。让一个goroutine通过它给另一个goroutine发送值信息。每个channel都有一个特殊的类型，也就是channels可发送数据的类型。一个可以发送int类型数据的channel一般写为chan int。

### 底层

> 1. ` // chan 里元素数量`
> 2. `    qcount   uint`
> 3. `    // chan 底层循环数组的长度`
> 4. `    dataqsiz uint`
> 5. `    // 指向底层循环数组的指针`
> 6. `    // 只针对有缓冲的 channel`
> 7. `    buf      unsafe.Pointer`
> 8. `    // chan 中元素大小`
> 9. `    elemsize uint16`
> 10. `    // chan 是否被关闭的标志`
> 11. `    closed   uint32`
> 12. `    // chan 中元素类型`
> 13. `    elemtype *_type // element type`
> 14. `    // 已发送元素在循环数组中的索引`
> 15. `    sendx    uint   // send index`
> 16. `    // 已接收元素在循环数组中的索引`
> 17. `    recvx    uint   // receive index`
> 18. `    // 等待接收的 goroutine 队列`
> 19. `    recvq    waitq  // list of recv waiters`
> 20. `    // 等待发送的 goroutine 队列`
> 21. `    sendq    waitq  // list of send waiters`
> 22. ``
> 23. `    // 保护 hchan 中所有字段`
> 24. `    lock mutex`    

`buf` 指向底层循环数组，只有缓冲型的channel才有

`sendx`,`recvx`均指向底层循环数组，当前可以发送和接收的元素位置的索引值(相对于底层数组)

`sendq`,`recvq`分别表示被阻塞的goroutine，这些goroutine由于 尝试读取channel或者channel发送数据而被阻塞。

`waitq` 是 `sudog` 的一个双向链表，而 `sudog` 实际上是对 goroutine 的一个封装

`lock` 用来保证每个读 channel 或写 channel 的操作都是原子的

### 创建

```go
chn :=make(chan int)   //  此为创建普通的channel

ch:=make(chan string ,3) // arg2 不为零表明这个channel是一个带有缓冲的通道，这个通道读写不同步。缓冲区填满后，向其发送数据时才会阻塞。当缓冲区为空时，接受方会阻塞。
```

与map类似，channel也是对应的make创建的底层数据结构的引用。当赋值一个channel或用于函数参数传递时，只是拷贝了一个channel的引用，因此调用者和被调用者引用同一个channel对象, 和其他的引用类型一样，channel零值也为`nil`

channel间的比较可以使用`==`运算符，如果两个chnnel`引用的是相同的对象`，结果将为`true`,channel也可以和`nil`做比较

**创建的 chan 是一个指针。所以我们能在函数间直接传递 channel，而不用传递 channel 的指针。**

### 接收发送

一个channel有`发送和接收`两个主要的操作，二者都是通信行为。

**发送=接收**：将一个值从一个goroutine通过channel发送给另一个需要操作(接收)goroutine，本质上是**值得拷贝**。

**非缓冲型的，直接从发送者的栈拷贝到接收者的栈**。

缓冲型的channel，而buf满的情形（发送游标和接收游标重合了，因此需要先找到接收游标），将该处的**元素拷贝**到**接收地址**。然后将发送游标和接受游标向前进一，如果发生了环绕，再从0开始。

发送和接收两个操作都是用`<-`运算符。在发送语句中，`<-`运算符分割channel和要发送的值。在接收语句中，`<-`运算符写在channel对象之前。(`<-`右侧是需要数据的发出者，而左侧则是数据的接收者)

```go
ch <- x  // a send statement  发送数据到通道
x = <-ch // a receive expression in an assignment statement
<-ch     // a receive statement; result is discarded
```

接受操作有两中写法：一种是带`ok`，反映channel是否关闭，另一种不带`ok`（当接收相应类型的零值时无法在知道时真实的发送者发送的数据，还是channel关闭后，返回给**接收者的默认类型的零值**）。

- 如果channel 是一个空值(nil)，在**非阻塞模式**下，会**直接返回**。 在**阻塞模式**下则会**挂起goroutine**，这个会一直阻塞下去，因为channel是nil的，解决直阻塞的方法则是关闭channel，但是**关闭**一个nil的channel又会引起**panic**，所以没救了。
- 和发送函数一样，在非阻塞模式下，不用获取锁，快速检测到失败并且返回的操作。

> 一个内核线程可以管理多个 goroutine，当其中一个 goroutine 阻塞时，内核线程可以调度其他的 goroutine 来运行，内核线程本身不会阻塞。这就是通常我们说的 `M:N` 模型。

channel支持close操作，用于关闭通道。对于一个已经被关闭的通道，接受操作依然可以接导直到已经成功发送的数据，如果channel中已经没有数据的话会产生一个零值的错误

```go
close(ch)
```

注：只有发送者才能关闭信道，而接收者不能。向一个已经**关闭**的信道**发送数据**会引发程序**panic**，信道与文件不同，通常情况下无需关闭它们。只有在必须告诉接收者不再有需要发送的值时才有必要关闭，例如终止一个 `range` 循环。

channel **可能会**引起goroutine**泄漏**。

> 原因是：goroutine操作channel后，处于发送或接收阻塞状态，而channel处于满或空的状态，一直得不到改变，同时**GC也不会回收此类资源**，进而导致goroutine一直处于等待队列中，
>
> 此外，运行时，对于一个channel，如果**没有任何的goroutine引用**，gc会对其进行回收，不会引起内存泄漏。

### channel应用

#### 任务定时

与timer结合：  1）实现超时控制；2）实现定期执行某个任务

```go
select{
    case<-time.After(100*time.Millisecond):
    case <-s.stopc:
		return false
}
```

程序再等待100ms后，如果没有再s.stopc中读取到数据或者被关闭，直接结束

```go
func worker(){
    ticker:=time.Tick(1*time.Second)
    for{
        select{
            case<-ticker:
            fmt.Println("执行1s定时任务")
        }
    }
}
```

执行定时任务

#### 解耦生产方和消费方

服务启动时，启动n个worker，作为工作协程池，这些协程工作在一个`for{}`的loop中，从某个channel消费工作任务并执行：

```go
func worker(taskch <-chan int){
	const N=5
    for i:=0;i<N;i++{
        go func(id int){
            for {
                task:=<-tasskch
                fmt.Printf("finish task %d  worker id %d",task,id )
                time.sleep(3*time.Second)
            }
        }(i)
    }
}

func main(){
    taskch:=make(chan int)
    go worker(taskCh)

    //  加塞任务
    for i:=0;i<10;i++{
        taskch<-i
    }
     // 等待 1 小时
    select {
    case <-time.After(time.Hour):
    }

}
```

#### 控制并发数

```go
var limit=make(chan int,3)
func main(){
    for _,w:=range work{
        go func(){
            limit<-1
            w()
            <-limit
        }()
    }
}
```

>  构建一个缓冲型的 channel，容量为 3。接着遍历任务列表，每个任务启动一个 goroutine 去完成。真正执行任务，访问第三方的动作在 w() 中完成，在执行 w() 之前，先要从 limit 中拿“许可证”，拿到许可证之后，才能执行 w()，并且在执行完任务，要将“许可证”归还。这样就可以控制同时运行的 goroutine 数。

limit<-1在func 内部的原因： 在外层就是控制系统goroutine数量可能会阻塞for循环

注：如果w() 发生在panic，那“许可证”可能就还不回去了，因此需要使用 defer 来保证。

### happended-before

事件a和事件b存在happend-before的关系，即a->b 那么a,b完成后的结果一定要体现这种关系。

关于channel的send,send finish,receive,recevie finished的happend-before如下

- 第n个send一定happend before 第n个receive finished(不区分缓冲和非缓冲)
- 对于容量为m的缓冲型channel，第n个recive 一定happend before 第n+m个send finished
- 对于非缓冲型的 channel，第 n 个 `receive` 一定 `happened before` 第 n 个 `send finished`。
- channel close 一定 `happened before` receiver 得到通知。

第一条：send 不一定`happend before`receive，有时会先receive，然后goroutine会被挂起，之后sender唤醒，`send after receive`, 但是不论如何，想要完成**接收**，**一定要先有发送。**

第二条：缓冲型的 channel，当第 n+m 个 send 发生后，有下面两种情况：

-  若第n个receive没有发生，这时，channel被填满，send就会被阻塞。当第n个receive发生时，sender goroutine 会被唤醒，之后再继续发送过程。这样，第 n 个 `receive` 一定 `happened before` 第 n+m 个 `send finished`。
- 若第n个receive已经发生过了，直接符合要求。

第三条:第 n 个 send 如果被阻塞，sender goroutine 挂起，第 n 个 receive 这时到来，先于第 n 个 send finished。如果第 n 个 send 未被阻塞，说明第 n 个 receive 早就在那等着了，它不仅 happened before send finished，它还 happened before send。

第四条： 先设置完 closed = 1，再唤醒等待的 receiver，并将零值拷贝给 receiver。

### 关闭

关闭某个channel 会执行函数`closechan`

```go
// 关闭一个 nil channel，panic
    if c == nil {
        panic(plainError("close of nil channel"))
    }
```



```go
// 上锁
    lock(&c.lock)
    // 如果 channel 已经关闭
    if c.closed != 0 {
        unlock(&c.lock)
        // panic
        panic(plainError("close of closed channel"))
    }

```

对于一个 channel，recvq 和 sendq 中分别保存了阻塞的发送者和接收者。关闭 channel 后，对于**等待接收者**而言，会收到一个相应**类型的零值**。对于等待**发送者**，会直接 **panic**。

close 函数先上一把大锁，接着把所有挂在这个 channel 上的 sender 和 receiver 全都连成一个 sudog 链表，再解锁。最后，再将所有的 sudog 全都唤醒。

### channel 发送数据的过程

发送操作最终转化为`chansend`函数

```go
 // 如果 channel 是 nil
    if c == nil {
        // 不能阻塞，直接返回 false，表示未发送成功
        if !block {
            return false
        }
        // 当前 goroutine 被挂起
        gopark(nil, nil, "chan send (nil chan)", traceEvGoStop, 2)
        throw("unreachable")
    }
```

- 如果检测channel是空的，当前goroutine被挂起，
- 对于不阻塞的发送操作，如果channel为关闭且没有多余的缓冲空间  说明：
  - channel是非缓冲的，且等待接收队列里没有goroutine
  - channel是缓冲的，但循环数组已经装满的元素

> 向一个非缓冲型的 channel 发送数据、从一个无元素的（非缓冲型或缓冲型但空）的 channel接收数据，都会导致一个 goroutine 直接操作另一个 goroutine 的栈。
>
> 由于 GC 假设对栈的写操作只能发生在 goroutine 正在运行中并且由当前 goroutine 来写，可能会造成一些问题，所以需要用到写屏障来规避
>
> 不同 goroutine 的栈是各自独有的。而这也违反了 GC 的一些假设。为了不出问题，写的过程中增加了写屏障，保证正确地完成写操作。这样做的好处是减少了一次内存 copy：不用先拷贝到 channel 的 buf，直接由发送者到接收者。



1. 在不改变channel自身状态的情况下，无法获知一个channel是否关闭
2. 关闭一个closed channel会导致**panic**，所以如果关闭channel的一方在不知道channel是否处于关闭状态时就取贸然关闭channel是十分危险
3. 向一个closed channel发送数据会导致panic，如果向channel发送数据的一方不知道channel是否处于相关闭得状态就去贸然访问channel发送数据



channel操作：

| 操作  | nil channel | closed channel   | not nil not closed channel                                   |
| :---: | ----------- | ---------------- | ------------------------------------------------------------ |
| close | panic       | panic            | sueccess                                                     |
| <-ch  | 阻塞        | 读取到对应得零值 | 阻塞或正常读取数据，缓冲型channel为空或非缓冲型channel没有等待发送时会阻塞 |
| ch<-  | 阻塞        | panic            | 阻塞或正常写入数据，非缓冲型channel没有等待接收者或缓冲型channel buf满时会被阻塞 |

发生panic得情况：向一个关闭的通道写入数据；关闭一个nil的通道；重复关闭一个通道。





递增的计数器，在每一个goroutine启动时加一，在goroutine退出时减一。这需要一种特殊的计数器，这个计数器需要在多个goroutine操作时做到安全并且提供提供在其减为零之前一直等待的一种方法。这种计数类型被称为sync.WaitGroup，

WaitGroup 同步等待组

```go
var wg sync.WaitGroup //  创建同步等待组的对象
Add(counter) 设置等待组中要执行的子goroutine的数量
Wait() 让主goroutine处于等待
Done() 让等待组中的counter-1  类似于Add(-1)
```

注：add和done，add是为计数器加1，必须在goroutine开始之前调用，而不再goroutine之中，done等价于add(-1)

## 基于select的多路复用

```go
select {
case <-ch1:
    // ...
case x := <-ch2:
    // ...use x...
case ch3 <- y:
    // ...
default:
    // ...
}
```

每一个case代表一个通信操作(在某个channel上进行发送或者接收)并且会包含一些语句组成的一个语句块。一个接收表达式可能只包含接收表达式自身（不把接收到的值赋值给变量什么的）就像上面的第一个case，或者包含在一个简短的变量声明中，像第二个case里一样；第二种形式让你能够引用接收到的值。

select会等待case中有能够执行的case时去执行。当条件满足时，select才会去通信并执行case之后的语句；这时候其它通信是不会执行的。**一个没有任何case的select语句写作`select{}`，会阻塞当前的goroutine，导致goroutine进入休眠状态。** 

```go
func main() {
	ch:=make(chan int,1)
	for i:=0;i<11;i++{
		select {
		case ch<-i:
			fmt.Println("通道中写入数据",i)
		case x:=<-ch:
			fmt.Printf("从通道中读取的数据%d \n",x)
		}
	}
}
```

多个case同时就绪时，select会**随机**选择一个执行，保证每个channel都有平等的被select的机会，增加前一个例子的buffer大小会使其输出变得不确定，因为当buffer既不为满也不为空时，select语句的执行情况就像是抛硬币的行为一样是随机的。select会有一个default来设置当其它的操作都不能够马上被处理时程序需要执行哪些逻辑。

**单一channel** ，在处理单操作select语句时，会根据channel的收发情况生成不同的语句。当`case` 中的channel是空指针时，就会之前挂起当前goroutine并永久休眠。

```
select{
	case <-ch:
	
}
```



## time中通道相关的函数

```go
func main() {
    // ...create abort channel...

    fmt.Println("Commencing countdown.  Press return to abort.")
    tick := time.Tick(1 * time.Second)
    for countdown := 10; countdown > 0; countdown-- {
        fmt.Println(countdown)
        select {
        case <-tick:
            // Do nothing.
        case <-abort:
            fmt.Println("Launch aborted!")
            return
        }
    }
    launch()
}
```

  timer是一次性得时间出发时间， 与Ticker不同，Ticker是按照一定时间间隔持续触发的事件

time.Tick函数返回一个channel，程序会周期性地像一个节拍器一样向这个channel发送事件。每一个事件的值是一个时间戳

1. timer常见的创建方式：
         t:=time.NewTimer(d)NewTimer创建一个新的计时器，将至少持续时间d后发送当前时间的通道上。
         t:=time.AfterFunc(d,f) AfterFunc等待时间流逝，然后调用f在自己的goroutine。 它返回一个可用于取消使用其停止方法调用一个计时器。
         t:=time.After(d)之后等待的持续时间经过，然后发送返回频道上的当前时间。 它等同于NewTimer（d）.C。 底层定时器不被垃圾收集器，直到计时器触发恢复。 如果效率是一个问题，使用NewTimer代替，并呼吁Timer.Stop如果不再需要定时器。
2.    timer3要素：
             定时时间：d
             触发动作: f
             事件channel：t.C
3. time.After() 返回一个通道，chan 存储的时d时间间隔之后的当前时间，相当于NewTimer(d).C

nil的channel有时候也是有一些用处的。因为对一个nil的channel发送和接收操作会永远阻塞，在select语句中操作nil的channel永远都不会被select到。这使得我们可以用nil来激活或者禁用case，来达成处理其它输入或输出事件时超时和取消的逻辑。

## 竞争条件

竞争条件指的是程序在多个goroutine交叉执行操作时，没有给出正确的结果

数据竞争：在两个以上的goroutine并发访问相同的变量且至少其中一个为写操作时发生。

避免数据竞争的方式。

1. 避免从多个goroutine访问变量由于其它的goroutine不能够直接访问变量，它们只能使用一个channel来发送给指定的goroutine请求来查询更新变量。`不要使用共享数据来通信；使用通信来共享数据`

```go
// Package bank provides a concurrency-safe bank with one account.
package bank

var deposits = make(chan int) // send amount to deposit
var balances = make(chan int) // receive balance

func Deposit(amount int) { deposits <- amount }
func Balance() int       { return <-balances }

func teller() {
    var balance int // balance is confined to teller goroutine
    for {
        select {
        case amount := <-deposits:
            balance += amount
        case balances <- balance:
        }
    }
}

func init() {
    go teller() // start the monitor goroutine
}
```

> 即使当一个变量无法在其整个生命周期内被绑定到一个独立的goroutine，绑定依然是并发问题的一个解决方案。例如在一条流水线上的goroutine之间共享变量是很普遍的行为，在这两者间会通过channel来传输地址信息。如果流水线的每一个阶段都能够避免在将变量传送到下一阶段时再去访问它，那么对这个变量的所有访问就是线性的。其效果是变量会被绑定到流水线的一个阶段，传送完之后被绑定到下一个，以此类推。这种规则有时被称为串行绑定。

第二种避免数据竞争的方法是允许很多goroutine去访问变量，但是在同一个时刻最多只有一个goroutine在访问。这种方式被称为“互斥”，

第三种方法是不要去写变量。

## sync.Mutex 互斥锁

这种互斥很实用，而且被sync包里的Mutex类型直接支持。它的Lock方法能够获取到token(这里叫锁)，并且Unlock方法会释放这个token：

```go
import "sync"

var (
    mu      sync.Mutex // guards balance
    balance int
)

func Deposit(amount int) {
    mu.Lock()
    balance = balance + amount
    mu.Unlock()
}

func Balance() int {
    mu.Lock()
    b := balance
    mu.Unlock()
    return b
}
```

每次一个goroutine访问bank变量时(这里只有balance余额变量)，它都会调用mutex的Lock方法来获取一个互斥锁。如果其它的goroutine已经获得了这个锁的话，这个操作会被阻塞直到其它goroutine调用了Unlock使该锁变回可用状态。mutex会保护共享变量。被mutex所保护的变量是在mutex变量声明之后立刻声明的。

在Lock和Unlock之间的代码段中的内容goroutine可以随便读取或者修改，这个代码段叫做临界区。goroutine在结束后释放锁是必要的，无论以哪条路径通过函数都需要释放，即使是在错误路径中，也要记得释放。

一系列的导出函数封装了一个或多个变量，那么访问这些变量唯一的方式就是通过这些函数来做(或者方法，对于一个对象的变量来说)。每一个函数在一开始就获取互斥锁并在最后释放锁，从而保证共享变量不会被并发访问。这种函数、互斥锁和变量的编排叫作监控monitor

封装用限制一个程序中的意外交互的方式，可以使我们获得数据结构的不变性。因为某种原因，封装还帮我们获得了并发的不变性。当你使用mutex时，确保mutex和其保护的变量没有被导出(在go里也就是小写，且不要被大写字母开头的函数访问啦)，无论这些变量是包级的变量还是一个struct的字段。

```go
func Withdraw(amount int) bool {
    mu.Lock()
    defer mu.Unlock()
    deposit(-amount)
    if balance < 0 {
        deposit(amount)
        return false // insufficient funds
    }
    return true
}

func Deposit(amount int) {
    mu.Lock()
    defer mu.Unlock()
    deposit(amount)
}

func Balance() int {
    mu.Lock()
    defer mu.Unlock()
    return balance
}

// This function requires that the lock be held.
func deposit(amount int) { balance += amount }
```

## sync.RWMutex读写锁

```go
var mu sync.RWMutex
var balance int
func Balance() int {
    mu.RLock() // readers lock
    defer mu.RUnlock()
    return balance
}
```

允许多个只读操作并行执行，但写操作会完全互斥。这种锁叫作“多读单写”锁

> RWMutex只有当获得锁的大部分goroutine都是读操作，而锁在竞争条件下，也就是说，goroutine们必须等待才能获取到锁的时候，RWMutex才是最能带来好处的。RWMutex需要更复杂的内部记录，所以会让它比一般的无竞争锁的mutex慢一些。
>
> ​                                                      ----《Go language Bible》

## WaitGroup

- Add 不能在和 Wait 方法在 Goroutine 中并发调用，一旦出现就会造成程序崩溃；
- WaitGroup 必须在 Wait 方法返回之后才能被重新使用；
- Done 只是对 Add 方法的简单封装，可以向 Add 方法传入任意负数（需要保证计数器非负）快速将 计数器归零以唤醒其他等待的 Goroutine；
- 可以同时有多个 Goroutine 等待当前 WaitGroup 计数器的归零，这些 Goroutine 也会被『同时』唤 醒；

## 内存同步

```go
var x, y int
go func() {
    x = 1 // A1
    fmt.Print("y:", y, " ") // A2
}()
go func() {
    y = 1                   // B1
    fmt.Print("x:", x, " ") // B2
}()
```

在一个独立的goroutine中，每一个语句的执行顺序是可以被保证的；也就是说goroutine是顺序连贯的。但是在不使用channel且不使用mutex这样的显式同步操作时，我们就没法保证事件在不同的goroutine中看到的执行顺序是一致的了。尽管goroutine A中一定需要观察到x=1执行成功之后才会去读取y，但它没法确保自己观察得到goroutine B中对y的写入，所以A还可能会打印出y的一个旧版的值。

所有并发的问题都可以用一致的、简单的既定的模式来规避。所以可能的话，将变量限定在goroutine内部；如果是多个goroutine都需要访问的变量，使用互斥条件来访问。因为缺少显式的同步，编译器和CPU是可以随意地去更改访问内存的指令顺序，以任意方式，只要保证每一个goroutine自己的执行顺序一致。

## sync.Once

sync中提供的Once：保证在go程序运行期间Once对应的某段程序只会执行一次，

```go
var mu sync.RWMutex // guards icons
var icons map[string]image.Image
// Concurrency-safe.
func Icon(name string) image.Image {
    mu.RLock()
    if icons != nil {
        icon := icons[name]
        mu.RUnlock()
        return icon
    }
    mu.RUnlock()

    // acquire an exclusive lock
    mu.Lock()
    if icons == nil { // NOTE: must recheck for nil
        loadIcons()
    }
    icon := icons[name]
    mu.Unlock()
    return icon
}
```

上面的代码有两个临界区。goroutine首先会获取一个写锁，查询map，然后释放锁。如果条目被找到了(一般情况下)，那么会直接返回。如果没有找到，那goroutine会获取一个写锁。不释放共享锁的话，也没有任何办法来将一个共享锁升级为一个互斥锁，所以我们必须重新检查icons变量是否为nil，以防止在执行这一段代码的时候，icons变量已经被其它gorouine初始化过了

sync.Once。概念上来讲，一次性的初始化需要一个互斥量mutex和一个boolean变量来记录初始化是不是已经完成了；互斥量用来保护boolean变量和客户端数据结构。Do这个唯一的方法需要接收初始化函数作为其参数。

```go
var loadIconsOnce sync.Once
var icons map[string]image.Image
// Concurrency-safe.
func Icon(name string) image.Image {
    loadIconsOnce.Do(loadIcons)
    return icons[name]
}
```

每一次对Do(loadIcons)的调用都会锁定mutex，并会检查boolean变量。在第一次调用时，变量的值是false，Do会调用loadIcons并会将boolean设置为true。随后的调用什么都不会做，但是mutex同步会保证loadIcons对内存(这里其实就是指icons变量啦)产生的效果能够对所有goroutine可见。用这种方式来使用sync.Once的话，我们能够避免在变量被构建完成之前和其它goroutine共享该变量。

> 做调用函数f当且仅当做的是被称为首次为一旦这个实例。 换句话说，由于
>  var once Once
> 如果once.Do（f）中被多次调用，仅在第一次调用会调用女，即使f有在每次调用一个不同的值。 一旦新实例为每个函数执行是必需的。
> 做的是用于那些必须严格运行一次初始化。 因为f是译注，可能需要使用函数文本捕捉参数由千万要调用的函数：
>  config.once.Do(func() { config.init(filename) })
> 因为这样做的回报，直到一个call到f的回报，如果f导致待办事项没有呼叫被调用，它就会死锁。
> 若f恐慌，难道认为它已经返回; 做未来的调用返回，而不调用F。

```go
o:=sync.Once()
for i:=0;i<10;i++{
    o.Do(func(){fmt.Println("only once")})
}
```

**Do方法中传如的函数只会被执行一次**。

## Cond

通过Cond可以让一系列的goroutine都在触发某个事件或条件时才会被唤醒，每一个Cond结构体都包含一个互斥锁L

```go
package main

import (
	"fmt"
	"os"
	"os/signal"
	"sync"
	"time"
)

func main() {
	c := sync.NewCond(&sync.Mutex{})
	for i := 0; i < 10; i++ {
		go listen(c)
	}
	time.Sleep(1*time.Second)
	go boradcast(c)

	ch:=make(chan os.Signal,1) // os.Singal 操作系统信号
	signal.Notify(ch,os.Interrupt) //通知使包裹信号将传入信号中继到c
	<-ch
}

func listen(c *sync.Cond){
	c.L.Lock()
	c.Wait()
	fmt.Println("the method listen")
	c.L.Unlock()
}

func boradcast(c *sync.Cond){
	c.L.Lock()
	c.Broadcast()  // 广播唤醒goroutine
	c.L.Unlock()
}
```

result:

```
the method listen
the method listen
the method listen
the method listen
the method listen
the method listen
the method listen
the method listen
the method listen
the method listen
```

> 在上述代码中我们同时运行了 11 个 Goroutine，其中的 10 个 Goroutine 会通过 Wait 等待期望的信号 或者事件，而剩下的一个 Goroutine 会调用 Broadcast 方法通知所有陷入等待的 Goroutine，当调用 Boardcast 方法之后，就会打印出 10 次 "listen" 并结束调用。

Cond 结构体中包含 noCopy和copyChecker两个字段，

- noCopy 保证Cond不会再编译期间拷贝
- copyChecker保证再运行期间发生拷贝会直接panic

持有的另一个锁L其实是一个接口Locker，任意实现Lock和Unlock的方法结构体都可以作为NewCond的参数

```go
type Cond struct {
 noCopy noCopy

 L Locker

 notify notifyList
 checker copyChecker
 }
```

notifyList 实现了Cond的同步机制，该结构体实际上就是一个Goroutine链表。

Cond的wait方法将当前的Goroutine陷入休眠状态，，等待其他的goroutine唤醒。

`singal`和`Broadcast`唤醒`Wait`现如陷入的goroutine

与 Mutex 相比， Cond 还是一个不被所有人都清楚和理解的同步机制，它提供了类似队列的 FIFO 的等待机 制，同时也提供了 Signal 和 Broadcast 两种不同的唤醒方法，相比于使用 for {} 忙碌等待，使用 Cond 能够在遇到长时间条件无法满足时将当前处理器让出的功能，

注意：

-  Wait 方法在调用之前一定要使用 L.Lock 持有该资源，否则会发生 panic 导致程序崩溃；
- Signal 方法唤醒的 Goroutine 都是队列最前面、等待最久的 Goroutine；
- Broadcast 虽然是广播通知全部等待的 Goroutine，但是真正被唤醒时也是按照一定顺序的；

## ErrGroup

x/sync 中的errgroup为一组goroutine提供了同步，错误传播，上下文取消的功能。

使用errgroup 请求网页

```go
package main

import (
	"fmt"
	"google.golang.org/x/sync/errgroup"
	"net/http"
)

var g errgroup.Group

var urls=[]string{
	"https:www.baidu.com",
	"https:www.douban.com",
}
func main(){
	for i:=range urls{
		url :=urls[i]
		g.Go(func()error{
			resp,err:=http.Get(url)
			if err==nil{
				resp.Body.Close()
			}
			return  err
		})
	}
	if err:=g.Wait();err==nil{
		fmt.Println("successful request urls")
	}
}
```

Go方法可以创建一个goroutine，并在其中执行传入的函数，而`Wait`方法等待Go方法创建的goroutine全部返回第一个非空的错误，若没错，则返回nil

errgroup包中的`Group`结构体同时由三个部分组成：

- 创建Context 时 返回的cancel函数，主要用于通知使用context的goroutine由于某些子任务出错，可以停止工作让出资源了；

- 用于等待一组goroutine完成子任务的waitgroup

- 用于接收子任务返回错误的err和保证err只会被赋值一次的errOnce

- ```go
  type Group strcut{
      cancel func()
      wg sync.WaitGroup
      errOnce sync.Once
      err    error
  }
  ```

  此字段共同组成了Group结构体并提供同步、错误传播以及上下文取消等功能。

外部可调用的errGroup的唯一构造器就是`withContext`方法，只能从一个`Context`中创建一个新的`Group`变量，`withCancel`返回的取消函数也仅在`Group`结构体内使用。

使用`Go`方法创建新的并行子任务，该方法内部会对`WaitGroup`加一并创建一个新的goroutine，再goroutine内部运行子任务并在返回错误及时调用`cancel`并对`err`赋值，只有再最早返回的错误才会被上游感知到，后续的错误都会被舍弃。

```go
func (g *Group) Go(f func() error) {
	g.wg.Add(1)

	go func() {
		defer g.wg.Done()

		if err := f(); err != nil {
			g.errOnce.Do(func() {
				g.err = err
				if g.cancel != nil {
					g.cancel()
				}
			})
		}
	}()
}
```

`Wait`方法其实只是调用了`waitgroup`的同步方法，在子任务全部完成时取消`Context`并返回可能出现的错误，无则nil。

```go
func (g *Group) Wait() error {
	g.wg.Wait()
	if g.cancel != nil {
		g.cancel()
	}
	return g.err
}
```

- 出现错误或者等待结束后都会调用，`Context`的`cancel`方法取消上下文
- 只有**第一个出现的错误才会被返回**，剩余的错误直接抛弃

## Semaphore

信号量在并发编程中常见的一种同步机制，其会保证持有的计数器在`0`到初始化的权重之间，

每次**获取资源**时都会**将信号量中的计数器减去**对应的数值，在**释放**时重新**加**回来，当**计数器大于信号量时进入休眠**，等待其他进程释放信号。

权重信号量，按照不同权重对资源的访问进行管理

- `NewWeighted` 创建新的信号量
- `Acquire` 获取了指定权重的资源，若当前没有空闲资源，就会现如休眠等待
- `TryAcquire` 获取指定权重的资源，若当前没有空闲资源，直接返回false
- `Relase` 释放指定权重的资源

`NewWeighted` 方法的主要创建一个新的权重信号量，传入信号量最大权重就会返回一个新的 `Weighted`结构体指针。

```go
func NewWeighted(n int64) *Weighted {
	w := &Weighted{size: n}
	return w
}


type Weighted struct {
	size    int64
	cur     int64
	mu      sync.Mutex
	waiters list.List
}
```

waiter列表存储着等待获取资源的用户，此外他还包含当前信号量的上限以及一个计数器`cur`，计算范围是`[0,size]`

> weighted提供了一种绑定并发访问资源的方法。 调用者可以请求给定权重的访问权限。

`Acquire`获取指定权重资源的方法，

> Acquire获取权重为n的信号量，直到资源可用或ctx完成为止一直阻塞。成功时返回nil。失败时，返回ctx.Err（）并保持信号量不变。如果ctx已经完成，则Acquire仍然可以成功执行而不会阻塞。

- 当信号量中剩余的资源大于获取的资源并且没有等待的 Goroutine 时就会直接获取信号量；
- 需要获取的信号量大于`Weighted`的大小，由于不可能满足条件就会直接返回
- 遇到其他情况时会将当前Goroutine加入到等到队列并通过select等待当前goroutine被唤醒，别唤醒后获取信号量。

`TryAcquire`:判断当前信号量是否由充足的资源获取，如果有充足的资源就会直接立刻返回`true` 否则`false`

与`Acquire`相比 `TryAcquire`由于不会等待资源的释放所以可能更适用于一些延时敏感、用户需要立刻感知结果的场景。

`Release`：当我么对信号量进行释放时，`Release`方法会从头到尾遍历`waiters`列表中全部的等待者，如果释放资源后的信号量有充足的剩余资源就会通过Channel唤起指定的goroutine

注：

- `Acquire`和`TryAcquire`方法均用于获取资源，前者用于同步获取会等待锁的释放，后者会在无法获取锁时直接返回。
- Release 方法会按照FIFO的顺序唤醒可以被唤醒的Goroutine
- 若一个goroutine获取了较多的资源，由于release的释放策略可能会等待较长的时间。

## SingleFlight

Go提供的一种同步原语，它能够在一个服务中抑制对下游的多次重复请求，一个比较常见的场景是 使用Redis对数据库中的一些数据进行缓存并设置了超时时间，缓存超时的一瞬间可能有非常多的并行请求发现了 Redis 中已经不包含任何 缓存所以大量的流量会打到数据库上影响服务的延时和质量。

singleflight 就能有效地解决这个问题，它的**主要作用就是对于同一个 Key 最终只会进行一次函数调用**，在这个上下文中就是只会进行一次数据库查询，查询的结果会写回 Redis 并同步给所有请求对应 Key 的用 户

减少了对下游瞬间流量，在获取下游资源非常耗时时，访问数据库、缓存等场景下，非常适合使用`SingleFlight`

singleflight.Group{} 创建一个新的 Group 结构体，然后通过调用 Do 方法就能对相同的请求进行抑制

Group： 代表一类工作，并形成一个命名空间，可以重复执行工作单元

```go
type Group struct {
	mu sync.Mutex       // protects m  保护m
	m  map[string]*call // lazily initialized  延迟初始化
}
```

call：call is an in-flight or completed singleflight.Do call

```go
type call struct {
	wg sync.WaitGroup

	// These fields are written once before the WaitGroup is done
	// and are only read after the WaitGroup is done.
	val interface{}
	err error

	// forgotten indicates whether Forget was called with this call's key
	// while the call was still in flight.
	forgotten bool

	// These fields are read and written with the singleflight
	// mutex held before the WaitGroup is done, and are read but
	// not written after the WaitGroup is done.
	dups  int
	chans []chan<- Result
}
```

call 结构体中的 val 和 err 字段都是在执行传入的函数时只会被赋值一次，它们也只会在 WaitGroup 等待结束都被读取，而 dups 和 chans 字段分别用于存储当前 singleflight 抑制的请求数量以及在结果返 回时将信息传递给调用方。

`Singleflight`提供了两个用于**抑制相同请求**的方法，其中一个**同步等待**的方法`Do`, 另一个是返回channel的`DoChan`

每次`Do`方法的调用都会获取互斥锁并尝试对`Group`持有的映射表进行懒加载，随后判断是否已经存在`key`对应的函数调用：

- 当不存在对应的call结构体时：
  - 初始化一个新的call结构体指针
  - 增加waitGroup持有的计数器
  - 将call结构体指针添加到映射表
  - 释放持有的互斥锁`Mutex`
  - 阻塞地调用`doCall`方法等待结果的返回
- 当已经存在对应的`Call`结构体时：
  - 增加dups计数器，表示当前重复的调用次数
  - 释放持有的互斥锁`Mutex`
  - 通过`WaitGroup`等待请求返回

DoChan 方法和 Do 的区别就是，它使用 Goroutine 异步执行 doCall 并向 call 持有的 chans 切片中追加 chan Result 变量，这也是它能够提供异步传值的原因。

注：

- Do和DoChan 一个用于同步阻塞调用传入的函数，一个用于异步调用传入的参数并通过Channel接收函数的返回值
- Froget方法可以通知Singleflight在持有的映射表中删除某个键，接下来对该键的调用就会直接执行方法而不是等待前面的函数返回
- 一旦调用的函数返回了错误，所有在等待的goroutine也就接收到了同样的错误。

## 总结

- Mutex 互斥锁
  -  如果互斥锁处于初始化状态，就会直接通过置位 mutexLocked 加锁；
  - 如果互斥锁处于 mutexLocked 并且在普通模式下工作，就会进入自旋，执行 30 次 PAUSE 指令消耗 CPU 时间等待锁的释放；
  - 如果当前 Goroutine 等待锁的时间超过了 1ms ，互斥锁就会被切换到饥饿模式；
  - 互斥锁在正常情况下会通过 runtime_SemacquireMutex 方法将调用 Lock 的 Goroutine 切换至休眠 状态，等待持有信号量的 Goroutine 唤醒当前协程；
  - 如果当前 Goroutine 是互斥锁上的最后一个等待的协程或者等待的时间小于 1ms ，当前 Goroutine 会将互斥锁切换回正常模式；
  - 如果互斥锁已经被解锁，那么调用 Unlock 会直接抛出异常；
  - 如果互斥锁处于饥饿模式，会直接将锁的所有权交给队列中的下一个等待者，等待者会负责设置 mutexLocked 标志位；
  - 如果互斥锁处于普通模式，并且没有 Goroutine 等待锁的释放或者已经有被唤醒的 Goroutine 获得 了锁就会直接返回，在其他情况下回通过 runtime_Semrelease 唤醒对应的 Goroutine；
- RWMutex 读写互斥锁
  - readerSem — 读写锁释放时通知由于获取读锁等待的 Goroutine；
  -  writerSem — 读锁释放时通知由于获取读写锁等待的 Goroutine；
  -  w 互斥锁 — 保证写操作之间的互斥；
  -  readerCount — 统计当前进行读操作的协程数，触发写锁时会将其减少 rwmutexMaxReaders 阻塞后续 的读操作；
  - readerWait — 当前读写锁等待的进行读操作的协程数，在触发 Lock 之后的每次 RUnlock 都会将 其减一，当它归零时该 Goroutine 就会获得读写锁；
  - 当读写锁被释放 Unlock 时首先会通知所有的读操作，然后才会释放持有的互斥锁，这样能够保证读操 作不会被连续的写操作『饿死』；
- WaitGroup 等待一组goroutine结束
  - Add 不能在和 Wait 方法在 Goroutine 中并发调用，一旦出现就会造成程序崩溃
  - WaitGroup 必须在 Wait 方法返回之后才能被重新使用；
  - Done 只是对 Add 方法的简单封装，我们可以向 Add 方法传入任意负数（需要保证计数器非负） 快速将计数器归零以唤醒其他等待的 Goroutine；
  - 可以同时有多个 Goroutine 等待当前 WaitGroup 计数器的归零，这些 Goroutine 也会被『同 时』唤醒；
- Once 程序运行期间仅执行一次
  - Do 方法中传入的函数只会被执行一次，哪怕函数中发生了 panic ；
  - 两次调用 Do 方法传入不同的函数时只会执行第一次调用的函数；
- Cond 发生指定时间时唤醒
  - Wait 方法在调用之前一定要使用 L.Lock 持有该资源，否则会发生 panic 导致程序崩溃
  - Signal 方法唤醒的 Goroutine 都是队列最前面、等待最久的 Goroutine；
  - Broadcast 虽然是广播通知全部等待的 Goroutine，但是真正被唤醒时也是按照一定顺序的；
- ErrGroup 为一组goroutine提供同步、错误传播以及上下文取消的功能
  - 出现错误或者等待结束后都会调用 Context 的 cancel 方法取消上下文；
  - 只有第一个出现的错误才会被返回，剩余的错误都会被直接抛弃；
- Semaphore 带权重的信号量
  - Acquire 和 TryAcquire 方法都可以用于获取资源，前者用于同步获取会等待锁的释放，后者会在无 法获取锁时直接返回；
  - Release 方法会按照 FIFO 的顺序唤醒可以被唤醒的 Goroutine；
  - 如果一个 Goroutine 获取了较多地资源，由于 Release 的释放策略可能会等待比较长的时间；
- Singleflight 抑制下游的重复请求
  - leFlight 用于抑制对下游的重复请求 Do 和 DoChan 一个用于同步阻塞调用传入的函数，一个用于异步调用传入的参数并通过 Channel 接受函数的返回值；
  - Forget 方法可以通知 singleflight 在持有的映射表中删除某个键，接下来对该键的调用就会直接执 行方法而不是等待前面的函数返回；
  - 一旦调用的函数返回了错误，所有在等待的 Goroutine 也都会接收到同样的错误；

## 竞争条件检测

竞争检查器(Go的runtime)在go build、go run 或者 go test 后加上 -race 就是使得编译器创建一个应用的“修改”版或者一个附带了能够记录所有运行期对共享变量访问工具的test，并且会记录下每一个读或者写共享变量的goroutine的身份信息。

竞争检查器会检查这些事件，会寻找在哪一个goroutine中出现了这样的case，例如其读或者写了一个共享变量，这个共享变量是被另一个goroutine在没有进行干预同步操作便直接写入的。这种情况也就表明了是对一个共享变量的并发访问，即数据竞争。这个工具会打印一份报告，内容包含变量身份，读取和写入的goroutine中活跃的函数的调用栈。这些信息在定位问题时通常很有用。



## 定时器

用于一次的定时器

`timer`就是Golang定时器内部表示，每一个timer都存储于堆中,

```go
 type timer struct {
     tb *timersBucket
     i int

     when int64
     period int64
     f func(interface{}, uintptr)
     arg interface{}
     seq uintptr
 }
```

`tb`就是用于存储当前定时器的容器，而`i`是当前定时器在堆中的索引，可以通过`tb`和`i`找到当前定时器在堆中的位置。

when 表示当前定时器被唤醒的时间，  period 表示两次被唤醒的间隔。

```go
type Timer struct {
	C <-chan Time
	r runtimeTimer
}
```

Timer定时器必须通过`NewTimer`或者`AfterTimer`函数进行创建，其中`runtimeTimer`就是time结构体。当定时器失效时，失效的时间就会被发送给当前定时器持有的channel`C`,订阅管道中消息的goroutine，就会收到当前定时器失效的时间。

在 time 包中，除了 timer 和 Timer 两个分别用于表示运行时定时器和对外暴露的 API 之 外，

`timersBucket`这个用于存储定时器的结构体也非常重要，它会存储一个处理器上的全部定时器，不过如果当前 机器的核数超过了 64 核，也就是机器上的处理器 P 的个数超过了 64 个，多个处理器上的定时器就可能存储在同 一个容器中

```go
type timersBucket struct{
    lock          mutex
    gp            *g
    created       bool
    sleeping      bool
    rescheduling  bool
    sleepUntil    int64
    waitnote      note
    t 			  []*timer
}
```

 `t`存储定时器指针的切片，每一个运行的Go程序都会在内存中存储着64个容器，容器中存储定时器的信息。

每个容器都有`timer`切片(类似于最小堆)，最小堆会按照`timer`应该触发的事件回对它们进行排序，最小堆最上面的定时器，就是最近需要被唤醒的timer。

`time` 包对外提供的两种创建定时器的方法：

- `NewTimer`接口，这个接口会创建一个用于通知触发时间的channel，调用`startTimer`方法并返回一个创建指向`Timer`结构体的指针
- `AfterFunc`与`NewTimer`不同之处是该方法没有创建一个用于通知触发时间的channel，只会在定时器到期时调用传入的方法。

定时器的触发是由`timerproc`中的一个双层for循环控制的，外层的for主要负责对当前goroutine的控制，
它不仅会负责锁的释放和获取，还会在合适的时机触发当前的goroutine的休眠。

## Ticker

用于多次通知的Ticker计数器，计数器中包含了一个用于接收通知的channel和一个定时器，（这俩字段组成了用于连续多次触发事件的计时器）

```go
type Ticker struct{
    C<-chan Time  
    r runtimeTimer
}
```

创建方法：

- NewTicker 显式的创建Ticker计时器指针，
- Tick 获取一个会定期发送消息的channel

> 每一个NewTicker方法开启的计时器都需要在不需要使用时调用Stop来关闭， 若不显式调用stop 创建的计时器并不能被GC回收，
>
> 而Tick创建的计时器由于对外只是提供了channel，所以一定没有关闭的。




## Goroutine和线程

goroutine和操作系统的线程。两者的区别实际上只是一个量的区别，但量变会引起质变的道理同样适用于goroutine和线程。