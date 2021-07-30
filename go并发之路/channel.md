go中channel的例子

将channel用作`future/promise`
## 返回单向接收通道作为函数返回结果
```go
package main
import (
 "time"
 "math/rand"
 "fmt"
)
func main() {
	rand.Seed(time.Now().UnixNano())
	a,b :=longTimeRequest(),longTimeRequest()
	fmt.Println(sumSquares(<-a,<-b))
}
func longTimeRequest() <-chan int32 {
	r := make(chan int32)
	go func() {
		time.Sleep(time.Second * 3)  // 模拟一个工作负载
		r <- rand.Int31n(100)
	}()
	return r
}

func sumSquares(a, b int32) int32 {
	return a*a + b*b
}
```
sumSquares函数需要接收两个参数进行求和，每个参数又需要从channel中读取，直到channel中读取到数据为止。
两个实参总共需要三秒而不是六秒。


### 将单向发送通道类型用做函数实参
```go
func main() {
	rand.Seed(time.Now().UnixNano())
	ra, rb := make(chan int32), make(chan int32)
	go longTimeRequest(ra)
	go longTimeRequest(rb)

	fmt.Println(sunSquares(<-ra,<-rb))
}

func longTimeRequest(r chan<- int32) {
	time.Sleep(time.Second * 3)
	r <- rand.Int31n(100)
}

func sunSquares(a, b int32) int32 {
	return a*a + b*b
}
```
不同于之前的例子，longTimeRequest 函数接收一个单向发送通道类型参数而不是返回一个单向接收通道结果

可以采用一个通道来接收longTimeRequest的返回值
```go
	res:= make(chan int32 ,2)
	go longTimeRequest(res)
	go longTimeRequest(res)

	fmt.Println(sunSquares(<-res,<-res))
```
### 最快回应
有时一份数据可能同时由多个数据源获取，这些数据源将返回相同的数据。因为各种因素，数据的返回速度参差不齐，

注：假设有N个数据源，为了防止被舍弃的回应对应的协程永久阻塞，则传输数据用的channel必须为一个容量至少为`N-1`的缓冲通道

```go
func main() {
	rand.Seed(time.Now().UnixNano())

	startTime:=time.Now()


	c:= make(chan int32 ,5) // 此处 必须是一个缓冲通道
	for i := 0; i < cap(c); i++ {
		go longTimeRequest(c)
	}
	rnd := <-c  // 只有一个回应被使用
	fmt.Println(time.Since(startTime))
	fmt.Println(rnd)
}

func longTimeRequest(r chan<- int32) {
	ra,rb:=rand.Int31(),rand.Intn(3)+1
	time.Sleep(time.Duration(rb)*time.Second)
	r <-ra
}
```
## 使用channel实现通知
一个channel中无值可接收，则此channel上的下一个接受操作将阻塞直到另一个协程发送值到该channel为止。

所以一个协程可以向此通道发送一个值来通知另一个等待着在此channel接收值的协程，

```go

func main() {
	values := make([]byte, 32*1024*1024)
	if _, err := rand.Read(values); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}  

	done:=make(chan struct{})

	// 协程排序
	go func() {
		sort.Slice(values, func(i, j int) bool {
			return values[i]<values[j]
		})
		done <- struct{}{} // 通知排序已完成
	}()


	<-done  // 等待通知
	fmt.Println(values[0],values[len(values)-1])
}
```
### 从一个通道接收一个值来实现单对单通知
若一个channel的数据缓冲队列已满，但是其发送协程队列为空，向此通道发送一个值将阻塞，直到有一个协程从该通道中读取数据为止。
一般情况下使用非缓冲通道来实现(非缓冲通道的的数据缓冲队列总是满的)
```go
func main() {
	done := make(chan struct{})
	go func() {
		fmt.Println("go channel")
		time.Sleep(3 * time.Second)
		<-done // 使用一个接收操作来通知主协程
	}()
	done <- struct{}{} // 阻塞，等待通知
	fmt.Println(done)
}
```
### 多对单和单对多通知
```go
func main() {
	log.SetFlags(0)
	ready,done:=make(chan T),make(chan T)
	go worker(1,ready,done)
	go worker(2,ready,done)
	go worker(3,ready,done)

	time.Sleep(time.Second*3)
	ready<-T{};ready<-T{};ready<-T{}
	<-done;<-done;<-done
}

type T =struct {}
func worker(id int,ready <-chan T,done chan<-T){
	<-ready  // 阻塞
	log.Printf("worker %v working",id)

	time.Sleep(time.Second*time.Duration(id+1))
	log.Printf("worker %v working end",id)
	done<-T{}
}
```
### 通过关闭channel实现群发通知
已关闭的channel可以接收到无数个值,

将上述例子中的`ready<-T{}` 替换为 close(ready) 实现单对单的通知。

### 定时通知 Timer
定时器通知
```go
func main() {
	fmt.Println("one")
	<-AfterDuration(time.Second)
	fmt.Println("second")
	<-AfterDuration(time.Second)
	fmt.Println("third")

}

func AfterDuration(d time.Duration) <-chan struct{} {
	c := make(chan struct{}, 1)
	go func() {
		time.Sleep(d)
		c <- struct{}{}
	}()
	return c
}
```
注：`time.After(duration)` 使得当前协程进入阻塞状态，而调用time.Sleep() 不会

## channel用作互斥锁
将容量为1的缓冲通道用作互斥锁：

- 通过发送操作加锁，接受操作解锁
- 接收操作加锁，发送操作解锁
```go
func main() {
	mutex := make(chan struct{}, 1) // 容量必须为1

	counter := 0
	increase := func() {
		mutex <- struct{}{} // 加锁
		counter++
		<-mutex // 解锁
	}

	increase1000 := func(done chan<- struct{}) {
		for i := 0; i < 1000; i++ {
			increase()
		}
		done <- struct{}{}
	}

	done := make(chan struct{})
	go increase1000(done)
	go increase1000(done)
	<-done; <-done
	fmt.Println(counter) // 2000
}
```
### 将channel用作计数信号量
缓冲通道可以被用作计数信号量，计数信号量可以被视为多主锁，若一个缓冲channel的容量为N，可以被看作在任何时刻最多可能有N个主人的锁

二元信号量是特殊的计数信号量，每个二元信号量在任意时刻最多有一个主人。

计数信号量常用于限制最大的并发数，获取一个用作技术信号量的channel的一份所有权：

- 通过发送操作获取所有权，写操作释放所有权
- 写操作获取所有权，发送操作释放所有权

```go
package main

import (
	"log"
	"time"
	"math/rand"
)

type Customer struct{id int}
type Bar chan Customer

func (bar Bar) ServeCustomer(c Customer) {
	log.Print("++ 顾客#", c.id, "开始饮酒")
	time.Sleep(time.Second * time.Duration(3 + rand.Intn(16)))
	log.Print("-- 顾客#", c.id, "离开酒吧")
	<- bar // 离开酒吧，腾出位子
}

func main() {
	rand.Seed(time.Now().UnixNano())

	bar24x7 := make(Bar, 10) // 最对同时服务10位顾客
	for customerId := 0; ; customerId++ {
		time.Sleep(time.Second * 2)
		customer := Customer{customerId}
		bar24x7 <- customer // 等待进入酒吧
		go bar24x7.ServeCustomer(customer)
	}
	for {time.Sleep(time.Second)}
}
```

## 对话
两个协程通过一个通道进行消息传递
```go

type Ball uint64

func Play(playerName string, table chan Ball) {
	var lastValue Ball = 1
	for {
		ball := <- table // 接球
		fmt.Println(playerName, ball)
		ball += lastValue
		if ball < lastValue { // 溢出结束
			os.Exit(0)
		}
		lastValue = ball
		table <- ball // 回球
		time.Sleep(time.Second)
	}
}

func main() {
	table := make(chan Ball)
	go func() {
		table <- 1 // （裁判）发球
	}()
	go Play("A:", table)
	Play("B:", table)
}
```
## 使用channel传送传输channel
一个通道类型的元素类型可以是另一个通道类型。 
```go
package main

import "fmt"

var counter = func(n int ) chan<-chan <-int{
	requests :=make(chan chan<-int)
	go func() {
		for request := range requests {
			if request ==nil{
				n++
			}else {
				request <-n  // 返回当前计数
			}
		}
	}()
	return requests
}(0)

func main() {
	cha := func(done chan<- struct{}) {
		for i := 0; i < 1000; i++ {
			counter <- nil
		}
		done <- struct{}{}
	}

	done := make(chan struct{})
	go cha(done)
	go cha(done)
	<-done;<-done
	request:=make(chan int , 1)
	counter<-request
	fmt.Println(<-request)
}
```

### 使当前协程永久阻塞

go中的无分支的select，控制代码块使得当前协程永久处于阻塞状态。一般用字啊主协程中以房子程序退出。

```go
package main

import "runtime"

func DoSomething() {
	for {
		// 做点什么...

		runtime.Gosched() // 防止本协程霸占CPU不放
	}
}

func main() {
	go DoSomething()
	go DoSomething()
	select{}
}
```

### 尝试发送和尝试接收

含有一个`default`分支和一个`case`分支的`select`代码块可以被用做一个**尝试发送或者尝试接收操作**，取决于`case`关键字后跟随的是一个发送操作还是一个接收操作。

- 如果`case`关键字后跟随的是一个发送操作，则此`select`代码块为一个尝试发送操作。 如果`case`分支的发送操作是阻塞的，则`default`分支将被执行，发送失败；否则发送成功，`case`分支得到执行。
- 如果`case`关键字后跟随的是一个接收操作，则此`select`代码块为一个尝试接收操作。 如果`case`分支的接收操作是阻塞的，则`default`分支将被执行，接收失败；否则接收成功，`case`分支得到执行。

尝试发送和尝试接收的代码块用不阻塞

> 标准编译器对尝试发送和尝试接收代码块做了特别的优化，使得它们的执行效率比多`case`分支的普通`select`代码块执行效率高得多。

```go
package main

import "fmt"

func main() {
	type Book struct{id int}
	bookshelf := make(chan Book, 3)

	for i := 0; i < cap(bookshelf) * 2; i++ {
		select {
		case bookshelf <- Book{id: i}:
			fmt.Println("成功将书放在书架上", i)
		default:
			fmt.Println("书架已经被占满了")
		}
	}

	for i := 0; i < cap(bookshelf) * 2; i++ {
		select {
		case book := <-bookshelf:
			fmt.Println("成功从书架上取下一本书", book.id)
		default:
			fmt.Println("书架上已经没有书了")
		}
	}
}
```

### 无阻塞检查一个通道是否关闭

假如没有任何协程会向一个通道发送数据，则可以使用下面的代码来（并发安全地）检查此通道是否已经关闭，此检查不会阻塞当前协程。

```go
func IsClosed(c chan T)bool{
	select{
		case <-c:
			return true
		default:
	}
	return false
}
```

### 导致当前协程永久阻塞的方法
- 向一个永不会被接收数据的channel发送数据
  ```go
   make(chan struct{}) <-struct{}
    make(chan<-struct{}) <-struct{}
  ```
- 从一个未被并且将来也不会被发送数据的(且不会被关闭的)通道读取数据
- 从一个nil通道读取或发送数据
- 使用一个不含任何分支的select流程控制代码块  