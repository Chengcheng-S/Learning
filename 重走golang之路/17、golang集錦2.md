#### 1、

程序解析

```go
func main(){
	count:=0
	for i:=range [256]strucct{}{
		m,n:=byte(i),int(8)
		if n==-n{
			count++
		}
        if m==-m{
        	count++
        }
	}
	fmt.Println(count)
}
```

解析：4  數據溢出，當i為0、128會發生相等的情況

#### 2、

同级文件的包名不允许有多个， 一个文件夹下只能有一个包，可以有多个.go 文件，但这些文件必须属于同一个包

#### 3、

```go
func main() {
	a:=[...]int{1,2,3}
	s:=a[1:2]
	fmt.Println(s)
	s[0]=11
	s=append(s, 12)
	s=append(s,13)
	s[0]=21
	fmt.Println(s)
	fmt.Println(a)
}
```

结果为  因为 append 添加元素之后 如果预留的位置不够 **会另开辟一块区域来存储数据**这也就是s[0]=21 不在影响数组a的原因

```
[2]
[21 12 13]
[1 11 12]
```

#### 4、

```go
func main() {
	fmt.Println(strings.TrimRight("heollo","lo"))
}
```

TrimRight 会将第二个参数的字符串拿出来和第一个字符串比较，如果有相同的则删除，(不论顺序，只要有相似的就会删除)

若要正确的截取一个字符串 请使用**TrimSuffix() 函数**

#### 5、

```go
func main() {
    var src, dst []int
    src = []int{1, 2, 3}
    copy(dst, src) 
    fmt.Println(dst)
}
```

从目标切片(src)拷贝到(dst)返回len(dst)\len(src)间的最小值，若要将src中的全部元素拷贝到了dst中，必须给dst分配足够的空间

```go
dst=make([]int, len(src))
n := copy(dst, src)
fmt.Println(n,dst)
```

#### 6、

```
const (
    Century = 100
    Decade  = 010
    Year    = 001
)

func main() {
    fmt.Println(Century + 2*Decade + 2*Year)
}
```

在go中**0开头的数字为八进制， 0x为十六进制的**，运算需要进行进制转换

#### 7、

```go
type T int

func F(t T) {}

func main() {
    var q int
    F(q)
}
```

编译失败，T是一个新的类型， q为int类型。即使**二者底层数据类型一致**，所以编译失败   若要编译成功需要使用过类型别名或者声明q为T类型

```go
type T []int

func F(t T) {}

func main() {
    var q []int
    F(q)
}
```

编译可以通过， 底层类型相同的变量可以相互赋值的另一个重要条件： 至少有一个**不是**有名类型(named type)

Named Type有两类：

- **内置类型**： int，floiat， string， bool 等
- 使用关键字**type声明的类型**

Unnamed Type 基于已有的Named Type 组合一起的类型，例如 **struct{} ,[]string, interface{}, map**

#### 8、

```go
func (m map[string]string) Set(key string, value string) {
    m[key] = value
}

func main() {
    m := make(map[string]string)
    m.Set("A", "One")
}
```

编译失败，**Unamed不可以作为方法接收者**

使用named type  改进   

```go
type User map[string]string

func (m User) Set(key string, value string) {
    m[key] = value
}

func main() {
    m := make(User)
    m.Set("A", "One")
}

```

#### 9、

求两个数之间的最小值

```go
func min(a int, b uint){
	var min = 0
	min=copy(make([]int,a),make([]int,b))
	fmt.Println("min:",min)
}
```

使用copy内置函数：将元素从原切片复制到目标切片，（作为一种有特殊情况，他还将**字符串中的字节复制到字节的一部分**）源和目标可能会重叠。返回复制的元素数，即len(src)和len(dst)中的**最小值。**

使用copy函数返回两者中长度较小的值。

#### 10、

```go
func main() {
    a := 2 ^ 15
    b := 4 ^ 15
    if a > b {
        println("a")
    } else {
        println("b")
    }
}
```

go中的**^**表示按位异或 即：

```
0010 ^ 1111 == 1101   (2^15 == 13)
0100 ^ 1111 == 1011   (4^15 == 11)
```

#### 11、

```go
type foo struct{Val int}
type bar struct {Val int}

func main(){
    a := &foo{Val: 5}
    b := &foo{Val: 5}
    c := foo{Val: 5}
    d := bar{Val: 5}
    e := bar{Val: 5}
    f := bar{Val: 5}
    fmt.Print(a == b, c == foo(d), e == f)
}
```

结果为 false， true ，true  Go中没有引用变量，每个变量实际上都占用一个唯一的内存位置，第一个比较结果为false

#### 12、

```go
func A() int{
    time.Sleep(1*time.Second)
    return 1
}
func B() int{
    time.Sleep(10*time.second)
	return 2
}

func main(){
    ch:=make(chan int 1)
    go func (){
        select{
            case ch<-A():
            case ch<-B():
            default:
            	ch<-3
        }
    }
    fmt.Println(<-ch)
}
```

结果： 1，2 随机输出

#### 13、

关于map的说法正确的是(A)

- A map 反序列化时json.unmarshal() 的参数必须时map的地址
- B 在函数中传递map，子函数对map元组的增加不会导致父函数中map修改
- C  在函数中传递map，子函数对map元组的修改不会导致父函数中map修改
- 不能使用内置函数delete 删除map的元素

#### 14、

```go
func test(i int) (ret int) {
    ret = i * 2
    if ret > 10 {
        ret := 10
        return
    }
    return
}

func main() {
    result := test(10)
    fmt.Println(result)
}
```

编译错误：ret is shadowed during return  

ret 在返回时被覆盖，解决方法 函数中的ret:=10  改为ret=10

#### 15、

```go
func main() {
    true := false
    fmt.Println(true)
}
```

编译可以通过， true是**预定义标识符可以用作变量名**，最好不要这么做

#### 16、

关于循环语句，下面说法正确的有 CD

- A. 循环语句既支持 for 关键字，也支持 while 和 do-while；
- B. 关键字for的基本使用方法与C/C++中没有任何差异；
- C. for 循环支持 continue 和 break 来控制循环，但是它提供了一个更高级的 break，可以选择中断哪一个循环；
- D. for 循环不支持以逗号为间隔的多个赋值语句，必须使用平行赋值的方式来初始化多个变量；

#### 17、

```go
var ch chan int = make(chan int)

func generate() {
    for i := 17; i < 5000; i += 17 {
        ch <- i
        time.Sleep(1 * time.Millisecond)
    }
    close(ch)
}

func main() {
    timeout := time.After(800 * time.Millisecond)
    go generate()
    found := 0
    for {
        select {
        case i, ok := <-ch:
            if ok {
                if i%38 == 0 {
                    fmt.Println(i, "is a multiple of 17 and 38")
                    found++
                      if found == 3 {
                        break
                    }
                }
            } else {
                break
            }
        case <-timeout:
            fmt.Println("timed out")
            break
        }
    }
    fmt.Println("The end")
}
```

解析：**break 会跳出select块，但不会跳出for循环**，

可以使用goto或者break label解决

```go
var ch chan int = make(chan int)

func generate() {
    for i := 17; i < 5000; i += 17 {
        ch <- i
        time.Sleep(1 * time.Millisecond)
    }
    close(ch)
}

func main() {
    timeout := time.After(800 * time.Millisecond)
    go generate()
    found := 0
    MAIN_LOOP:
    for {
        select {
        case i, ok := <-ch:
            if ok {
                if i%38 == 0 {
                    fmt.Println(i, "is a multiple of 17 and 38")
                    found++
                    if found == 3 {
                        break MAIN_LOOP
                    }
                }
            } else {
                break MAIN_LOOP
            }
        case <-timeout:
            fmt.Println("timed out")
            break MAIN_LOOP
           }
    }
    fmt.Println("The end")
}
```

#### 18、

```go
var mu sync.Mutex
var chain string

func main() {
    chain = "main"
    A()
    fmt.Println(chain)
}
func A() {
    mu.Lock()
    defer mu.Unlock()
    chain = chain + " --> A"
    B()
}

func B() {
    chain = chain + " --> B"
    C()
}

func C() {
    mu.Lock()
    defer mu.Unlock()
    chain = chain + " --> C"
}
```

编译错误， 使用Lock 加锁之后，需要解锁才可以进行下一步操作

#### 20、

#### 关于同步锁，下面说法正确的是ABC

- A. 当一个 goroutine 获得了 Mutex 后，其他 goroutine 就只能乖乖的等待，除非该 goroutine 释放这个 Mutex；
- B. RWMutex 在读锁占用的情况下，会阻止写，但不阻止读；
- C. RWMutex 在写锁占用情况下，会阻止任何其他 goroutine（无论读和写）进来，整个锁相当于由该 goroutine 独占；
- D. Lock() 操作需要保证有 Unlock() 或 RUnlock() 调用与之对应

#### 21、

```go
type MyMutex struct {
    count int
    sync.Mutex
}

func main() {
    var mu MyMutex
    mu.Lock()
    var mu1 = mu
    mu.count++
    mu.Unlock()
    mu1.Lock()
    mu1.count++
    mu1.Unlock()
    fmt.Println(mu.count, mu1.count)
}
```

编译失败，  加锁后复制变量，会将锁的状态也复制，所以 mu1 其实是已经加锁状态，再加锁会死锁。

#### 22

```go
func goroutineA(a <-chan int) {
    val := <- a
    fmt.Println("G1 received data: ", val)
    return
}
func goroutineB(b <-chan int) {
    val := <- b
    fmt.Println("G2 received data: ", val)
    return
}
func main() {
    ch := make(chan int)
    go goroutineA(ch)
    go goroutineB(ch)
    ch <- 3
    time.Sleep(time.Second)
}
```

创建一个无缓冲的channel，启动两个goroutine，比那个将channel传递进去，然后像这个channel发送数据3

> G1 和 G2 被挂起了，状态是 `WAITING`，当 G1（`go goroutineA(ch)`） 运行到 `val := <- a` 时，它由本来的 running 状态变成了 waiting 状态（调用了 gopark 之后的结果）：G1 脱离与 M 的关系，但调度器可不会让 M 闲着，所以会接着调度另一个 goroutine 来运行
>
> G2 也是同样的遭遇。现在 G1 和 G2 都被挂起了，等待着一个 sender 往 channel 里发送数据，才能得到解救。

#### 23、

```go
package main
import "fmt"
type MyError struct {}
func (i MyError) Error() string {
    return "MyError"
}
func main() {
    err := Process()
    fmt.Println(err)
    fmt.Println(err == nil)
}
func Process() error {
    var err *MyError = nil
    return err
}
```

结果为：nil  false

> 定义了一个 `MyError` 结构体，实现了 `Error` 函数，也就实现了 `error` 接口。`Process` 函数返回了一个 `error` 接口，这块隐含了类型转换。所以，虽然它的值是 `nil`，其实它的类型是 `*MyError`，最后和 `nil` 比较的时候，结果为 `false`

#### 24、

```go
package main
import (
    "unsafe"
    "fmt"
)
type iface struct {
    itab, data uintptr
}
func main() {
    var a interface{} = nil
    var b interface{} = (*int)(nil)
    x := 5
    var c interface{} = (*int)(&x)
    ia := *(*iface)(unsafe.Pointer(&a))
    ib := *(*iface)(unsafe.Pointer(&b))
    ic := *(*iface)(unsafe.Pointer(&c))
    fmt.Println(ia, ib, ic)
    fmt.Println(*(*int)(unsafe.Pointer(ic.data)))
}
```

> a 的动态类型和动态值的地址均为 0，也就是 nil；b 的动态类型和 c 的动态类型一致，都是 `*int`；最后，c 的动态值为 5。

#### 25、逃逸

```go
package main
type S struct {}
func main() {
  var x S
  _ = identity(x)
}
func identity(x S) S {
  return x
}
```

分析： Go语言函数传递是值传递，调用函数时，直接在栈上copy一份参数，不存在逃逸

#### 26、逃逸

```go
package main
type S struct {}
func main() {
  var x S
  y := &x
  _ = *identity(y)
}
func identity(z *S) *S {
  return z
}
```

identity函数的输出直接作为返回值，因为**没有对z作引用**，所以**z没有逃逸**，对x的引用也没有逃出main函数的作用域，因此x也没有发生逃逸。

#### 27、

```go
package main
type S struct {}
func main() {
  var x S
  _ = *ref(x)
}
func ref(z S) *S {
  return &z
}
```

**z是对x的拷贝，ref函数中对z取了引用，所以z不能放在栈上，否则在ref函数之外，通过引用如何找到z，所以z必须要逃逸到堆上。仅管在main函数中，直接丢弃了ref的结果，但是Go的编译器还没有那么智能，分析不出来这种情况。而对x从来就没有取引用，所以x不会发生逃逸。**

#### 28、

```go
package main
type S struct {
  M *int
}
func main() {
  var i int
  refStruct(i)
}
func refStruct(y int) (z S) {
  z.M = &y
  return z
}
```

对y取了引用，所以y发生了逃逸，i先在main的栈帧中分配，之后又在refStruct栈帧中分配，然后又逃逸到堆上，到堆上分配了一次，共3次分配。

#### 28、

```go
package main
type S struct {
  M *int
}
func main() {
  var i int
  refStruct(&i)
}
func refStruct(y *int) (z S) {
  z.M = y
  return z
}
```

在main函数里对i取了引用，并且把它传给了refStruct函数，i的引用一直在main函数的作用域用，因此i没有发生逃逸。i只分配了一次，然后通过引用传递。

#### 29、

```go
package main
type S struct {
  M *int
}
func main() {
  var x S
  var i int
  ref(&i, &x)
}
func ref(y *int, z *S) {
  z.M = y
}
```

i发生了逃逸，S是在输入参数中，所以逃逸分析失败，i要逃逸到堆上。

#### 30

```go
package main

import "fmt"

func main() {
	var k=1
	var s=[]int{1,3}
	k,s[k]=0,2
	fmt.Println(s[0]+s[1])
}
```

输出结果为 3 

输出为[z,b,c]  golang中得多重赋值，分为两个步骤，有先后顺序

1. 计算等号左边得索引表达式和取地表达式，接着计算等号右边得表达式
2. 赋值

所以先计算  s[k]=2  即 s[1]=2

#### 31

```go
func main() {
	var k=9
	for k=range []int{}{}
	fmt.Println("k1",k)

	for k=0;k<3;k++{

	}
	fmt.Println("k2",k)
	for k=range (*[3]int)(nil){

	}
	fmt.Println("k3",k)
}
```

结果为9,3,2
