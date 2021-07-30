# defer中的細節

> 在golang当中，defer代码块会在函数调用链表中增加一个函数调用。
> 这个函数调用不是普通的函数调用，而是会在函数正常返回，也就是return之后添加一个函数调用。因此，defer通常用来释放函数内部变量。

defer是Go中提供的一種用於注冊延遲調用的機制，每次defer都會把函數壓入棧中，當前函數返回前再把延遲函數取出執行。defer 语句并不会马上执行，而是会进入一个栈，函数 return 前，会按先进后出（FILO）的顺序执行。也就是说最先被定义的 defer 语句最后执行。**先进后出的原因是后面定义的函数可能会依赖前面的资源，自然要先执行；否则，如果前面先执行，那后面函数的依赖就没有了**。

```go
func f1() int {
	var i int
	defer func() {
		i++
	}()
	return i
}

func f2() (r int) {
	defer func() {
		r++
	}()
	return r
}
```

語句定義時候，引用外部變量有兩種形式：

1. 作爲參數，將值傳遞給defer，并被緩存起來
2. 作爲閉包引用，在defer真正調用時根據整個上下文來確定當前的值



```go
func main(){
    startedAt:=time.Now()
    
    defer fmt.Println(time.Since(startedAt))
    
    time.Sleep(time.Second)
}
```

```
0s 
```

错误原因：调用`defer`关键字会立刻对函数中外部参数进行拷贝，所以 time.Since(startedAt)的结果不是在main函数推出之前计算的，而是在defer关键字调用时计算的，最终导致结果输出为0s

解决方式：  defer之后传入匿名函数 

```
func main(){
    startedAt:=time.Now()
    
    defer func(){fmt.Println(time.Since(startedAt))}()
    
    time.Sleep(time.Second)
}
```



### 關於return

return  xxx

經過編譯之後，變成3條指令

```go
返回值=xxx
調用defer
空的return
```

### 舉例

```go
func f2() (r int) {
    t := 5
    // 1.赋值
    r = t

    // 2.闭包引用，但是没有修改返回值 r
    defer func() {
        t = t + 5
    }()

    // 3.空的 return
    return
}
```

第二步沒有涉及到返回r值，所以返回的值為5

```go
func f3() (r int) {

    // 1.赋值
    r = 1

    // 2.r 作为函数参数，不会修改要返回的那个 r 值
    defer func(r int) {
        r = r + 5
    }(r)

    // 3.空的 return
    return
}
```

**第二步，r 是作为函数参数使用，是一份复制，defer 语句里面的 r 和 外面的 r 其实是两个变量，里面变量的改变不会影响外层变量 r，所以不是返回 6 ，而是返回 1。**

```go
func f2() (r int) {
                      //  r=0  此處為隱式賦值
	defer func() {   // 閉包引用 r++
		r++
	}()
	return r     // r=1
}
```



```go
func f1() int {
	var i int    // 顯示聲明  i=0
	defer func() {
		i++
	}()
	return i
}
```

defer 函数也会操作这个局部变量。对于匿名返回值来说，可以假定有一个变量存储返回值，比如假定返回值变量为 anony，上面的返回语句可以拆分成以下过程：

```go
annoy = i
i++
return
```

由于 i 是整型，会将值拷贝给 anony，所以 defer 语句中修改 i 值，对函数返回值不造成影响，所以返回 0 。

```go
type Slice []int

func NewSlice() Slice {
    return make(Slice, 0)
}
func (s *Slice) Add(elem int) *Slice {
    *s = append(*s, elem)
    fmt.Print(elem)
    return s
}
func main() {
    s := NewSlice()
    defer s.Add(1).Add(2)
    s.Add(3)
}
```

输出为132，Add() 方法的返回值依然是指针类型 `*Slice`，所以可以循环调用方法 Add()；

defer函数的参数(以及接收者)是在**defer语句出现的位置开始计算的**，而不是在函数执行时计算，所以，所以 s.Add(1) 会先于 s.Add(3) 执行

在异常发生时，如果在defer中调用recover()，可以捕获触发panic时的参数，且恢复到正常的流程。

如果defer中调用的recover的包装函数的话，异常的捕获工作将失败。

同样嵌套的defer函数中调用recover也会导致无法捕获异常。

```go
func main(){
    defer func(){
        defer func(){
            if i:=recover();i!=nil{
                fmt.Println(r)
            }
    
        }
    }
}
```

 两个嵌套的defer直接调用recover和一层defer函数中调用包装的recover一样，都是经过两个函数帧才能到达真正的recover(),此时Goroutine对应的上一级栈帧中已经没有了异常信息

defer 中直接调用包装的recover就又可以直接工作了

```go
func f1()interface{}{
    return recover()
}
func main(){
    defer f1()
    panic(3)
}
```

如果直接在defer后直接调用recover函数，依然不能工作。

```go
func mian(){
	defer recover()
	panic(1)
}
```

必须要与异常的栈帧只隔开一个栈帧，recover才可以捕获异常

换言之 recover 捕获的是父级的函数栈帧的异常(刚好可以跨越一层defer())

```go
fn mian(){
    defer func(){
        if r:=recover();r!=nil{
            println(r) 
        }()
        panic(2)
    }
}
```

### 当defer被声明时，其参数就会被实时解析

```go
package main

import (
	"fmt"
)

func main() {
	i := 1
	defer func(i int) int{
		i= i+1
		return i
	}(i)
	fmt.Println(i)
}
```

结果输出为1
变量(i)在defer被声明的时候，就已经确定其确定的值了
**defer输出的值，就是定义时的值。而不是defer真正执行时的变量值**

defer语句在方法返回“时”触发，也就是说return和defer是“同时”执行的。

## 执行顺序先进后出

当同时定义了多个defer代码块时，golang安装先定义后执行的顺序依次调用defer。

### defer可以读取有名返回值

先执行return 在进行defer的操作

```go
package main

import (
	"fmt"
)

func main() {
	i := c()
	fmt.Println(i)
}

func c() (i int) {
	defer func() { i++ }()
	return 1
}
```

结果输出为2
执行C函数时，先执行return操作即 return 1  然后defer捕获环境中的变量
再执行自增操作。

return： 
result = xxx
调用defer函数
return   result 

匿名返回值时： defer 修改是对xxx执行的，而不是result， 

命名返回值时， result 就是xxx，defer对于result的修改也会被直接返回。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	st:=time.Now()
	defer fmt.Println(time.Since(st))

	time.Sleep(time.Second)
}
```

结果为0s，可以直到 **defer立刻对函数中引用的外部参数进行拷贝**，所以 time.Since(st)的结果不是在main函数结束之前计算的，而是在defer关键字调用时计算的。

### Go中defer使用原则：

1. 先给返回值赋值，然后调用defer表达式，最后才是返回到调用函数中。

2. golang按照先定义后执行的顺序依次调用defer

3. defer是在return调用之后才执行的

4. defer可以读取有名返回值

5. defer延迟执行的是最后的一个函数，

   > 整个defer是在最后执行。当然可以了使用 defer fun(){
   > }()，包住此方法

6.  defer 的执行顺序只影响到函数，函数的中涉及到的函数（变量如果是函数）的执行顺序不受影响，仍然按照过程执行，

7.  **当发生panic时，所在goroutine的所有defer会被执行，但是当调用os.Exit()方法退出程序时，defer并不会被执行**。

```go
func f1() (result int) {
	defer func() {
		result++
	}()
	return 0
}   // res=1
func f2() (r int) {
	t := 5
	defer func() {
		t = t + 5
	}()
	return t
}  // res =5

func f3() (r int) {
	defer func(r int) {
		r = r + 5
	}(r)
	return 2
}// res=2
```


## recover

recover
内置函数用来管理含有panic行为的goroutine，recover运行在defer函数中，获取panic抛出的错误值，并将程序恢复成正常执行的状态。如果在defer函数之外调用recover，那么recover不会停止并且捕获panic错误.
如果goroutine中没有panic或者捕获的panic的值为nil，recover的返回值也是nil。由此可见，recover的返回值表示当前goroutine是否有panic行为

- panic 只会触发当前goroutine的延迟函数调用
- recover 只有在defer函数中调用才会生效
- panic 允许在defer中嵌套多次调用

```go
package main

import "fmt"

func main() {
	defer fmt.Println("in main")
	defer func() {
		defer func() {
			panic("panic twice")
		}()
		panic("panic third")
	}()

	panic("panic first")
}
```



### defer表达式如果放置在panic之后该函数在panic后就无法被执行到

```go
func main() {
	panic("the first panic news")
	defer recover()
}
```

result:

```
/prog.go:6:2: unreachable code
Go vet exited.

panic: the first panic news

goroutine 1 [running]:
main.main()
	/tmp/sandbox729663397/prog.go:5 +0x3e
```

### 函数中的defer panic

函数中如果有panic会立即停止，但不会立即返回，若有defer时先调用defer，此时defer中若有recover() 则会调用执行完defer之后，在进行返回。

```go
package main

func main() {
	f1()
}
func f1() {
	defer recover()
	panic("the first panic news")

}
```

### recover和 goroutine

recover都是在当前goroutine里进行捕获，

对于创建goroutine的外层函数，如果goroutine内部发生panic且没有recover，
外层函数是无法用recover来捕获的，这会造成程序崩溃。

```go
package main

import (
	"sync"
)

var wg sync.WaitGroup

func main() {
	wg.Add(2)
	go f1()
	go f2() 
	wg.Wait()

}
func f1() {
	defer recover()
	panic("the first panic news")

	wg.Done()
}

func f2() {
	panic("the second panic news")
	wg.Done()
}
```

recover返回的是interface{}类型而不是go中的 error 类型，如果外层函数需要调用err.Error()，会编编译错误，也可能会在执行时panic。







