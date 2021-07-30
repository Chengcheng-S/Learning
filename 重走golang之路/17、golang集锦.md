1、通过指针变量p访问成员变量name，语法正确的为(A,B)

A  P.name

B (*p).name

C (&p).name

D p->name

2、    

```go
func add(args... int)int{
    sum:=0
    for _,age:=range args{
        sum+=arg
    }
    return  sum
}
```

对该函数调用正确的是(ABD)

A add(1,2)

B add(1,3,7)

C add([]int{1,3,7})

D add([]int{1,23,7}...)

解析： 函数add 传参为可变参数args 且为int类型，而 []int{1,3,7}传递int类型的数组，至于[]int{1,3,7}...  传递的则是数组中的元素

const  ：声明常量不能为对象类型、只有基本数据类型可以作为常量(int string  bool  float complex)

即： 

```
const (

ERR_ELEM_EXISTerror = errors.New("element already exists")

ERR_ELEM_NT_EXISTerror = errors.New("element not exists")

)   这样声明错误的
```

3、关于布尔变量b的赋值，下面错误的用法是（BC）
A. b = true
B. b = 1
C. b = bool(1)
D. b = (1 == 2)

4、golang中没有隐藏的this指针，这句话的含义是（）
A. 方法施加的对象显式传递，没有被隐藏起来
B. golang沿袭了传统面向对象编程中的诸多概念，比如继承、虚函数和构造函数
C. golang的面向对象表达更直观，对于面向过程只是换了一种语法形式来表达
D. 方法施加的对象不需要非得是指针，也不用非得叫this

5、下面赋值正确的是（BD）
A. var x = nil
B. var x interface{} = nil
C. var x string = nil
D. var x error = nil

解析： nil 值。nil 只能赋值给指针、chan、func、interface、map 或 slice 类型的变量。强调下 D 选项的 error 类型，它是一种内置接口类型，

6、删除切片中的元素的算法

```go
func (s*Slice)Remove(value interface{}) error {
for i, v:= range *s {
    if isEqual(value, v) {
        *s =append((*s)[:i],(*s)[i + 1:]...)
        return nil
    }
}
returnERR_ELEM_NT_EXIST
}
```

7、关于函数声明，下面语法错误的是（c）
A. func f(a, b int) (value int, err error)
B. func f(a int, b int) (value int, err error)
C. func f(a, b int) (value int, error)
D. func f(a int, b int) (int, int, error)
解析：关于函数返回值命名： 当存在多个返回值时，多个返回值需要同时命名或同时未命名，不可存在命名返回值和未命名返回值混用，否则报错

```go
\main.go:23:20: syntax error: mixed named and unnamed function parameters
混合命名和未命名函数参数
```

8、golang中大多数数据类型都可以转化为有效的JSON文本，下面几种类型除外（BCD）
A. 指针
B. channel
C. complex
D. 函数

9、关于map的操作

```go
var b map [string]int
b["one"]=1
//  只声明未定义 所以map为空为分配内存，需要make分配内存否则
assignment to entry in nil map
```

10、关于channel  有缓冲的channel为非同步的，而无缓冲的channel为同步的

11、关于goconvey，下面说法错误的是（D）
		A. goconvey是一个支持golang的单元测试框架
		B. goconvey能够自动监控文件修改并启动测试，并可以将测试结果实时输出到web界面
		C. goconvey提供了丰富的断言简化测试用例的编写
		D. goconvey无法与go test集成

11、 go vet 用于golang源码中静态错误的简单工具，消灭go vet 扫描出来的静态错误可以提升程序的质量

关于go vet 说法错误的为（B）

A. go vet是golang自带工具go tool vet的封装
		B. 当执行go vet database时，可以对database所在目录下的所有子文件夹进行递归检测
		C. go vet可以使用绝对路径、相对路径或相对GOPATH的路径指定待检测的包
		D. go vet可以检测出死代码

12、 关于map的说法正确的是(A)

A. map反序列化时json.unmarshal的入参必须为map的地址
		B. 在函数调用中传递map，则子函数中对map元素的增加不会导致父函数中map的修改
		C. 在函数调用中传递map，则子函数中对map元素的修改不会导致父函数中map的修改
		D. 不能使用内置函数delete删除map的元素

批注：

```go
var b map[string]int
	b=make(map [string]int )
	b["x"]=1
	b["y"]=1
	b["z"]=1
	delete(b,"z")
	fmt.Println(b)
```

可以试用内置函数delete 删除map中的元素，

map为引用传递，修改副本会导致原map的改变，即：

```go
func main() {
	var b map[string]int
	b=make(map [string]int )
	b["x"]=1
	b["y"]=1
	b["z"]=1

	zz:=ab(b)
	fmt.Println(zz)
	fmt.Println(b)
}


func ab (x map[string]int)map[string]int{
	for key,_:=range x{
		if key=="y"{
			delete(x,key)
		}

	}
	return x
}
```

返回值则为

```go
F:\GO\bin\src\Gomockone>go run test.go
map[x:1 z:1]
map[x:1 z:1]

```

13、defer函数的执行顺序

defer是先进后出，panic需要等待defer结束后才能向上传递，出现panic是，会按照defer先入后出的顺序执行，最后执行panic

```go
package main
import "fmt"
func main(){
    defer_add()
}
func defer_call(){
    deferfunc(){fmt.Println(000)}
    deferfunc(){fmt.Println(001)}
    deferfunc(){fmt.Println(002)}
    panic("中断")
}


```

例子：

```go
package main

import "fmt"

func main() {

	defer func() {
		recover()

		fmt.Println("执行结束")
	}()
	deferfunc()
}

func deferfunc() {
	defer println("执行前")
	defer println("执行中")
	defer println("执行后")

	panic("中断执行")
}

```

程序的输出结果为：

```go
未加入recover恢复异常之前的输出结果
F:\GO\bin\src\Gomockone>go run defers.go
执行后
执行中
执行前
panic: 中断执行

goroutine 1 [running]:
main.deferfunc()
        F:/Go/bin/src/Gomockone/defers.go:20 +0xda
main.main.func1()
        F:/Go/bin/src/Gomockone/defers.go:9 +0x3b
main.main()
        F:/Go/bin/src/Gomockone/defers.go:11 +0x27
exit status 2

```

加入recover之后的输出结果：

```panic
F:\GO\bin\src\Gomockone>go run defers.go
执行后
执行中
执行前
执行结束

```

注： recover 恢复panic需要配合defer关键词

14、go执行的随机性和闭包

```go
package main

import (
	"fmt"
	"runtime"
	"sync"
)

var wg sync.WaitGroup

func main() {
	runtime.GOMAXPROCS(1)
	wg.Add(20)
	for i := 0; i < 10; i++ {
		go func() {
			fmt.Println("a", i)
			wg.Done()
		}()

	}

	for j := 0; j < 10; j++ {
		go func(i int) {
			fmt.Println("b", i)
			wg.Done()
		}(j)

	}

	wg.Wait()
}

```

解析：a输出均为10，b 为0~9的随机数，第一个go func中i是for循环中的一个变量，地址不变化，遍历完成之后，最终i=10，而第二个go func 中的参数则是传入函数的参数，i发生值拷贝，go func 内部指向拷贝地址

15、golang中的组合继承

```go
package main

import "fmt"

func main() {
	t := Teacher{}
	t.ShowB()

	p := People{}
	p.Showa()
}

type People struct{}

func (p *People) Showa() {
	fmt.Println("show a")
	p.Showb()
}

func (p *People) Showb() {
	fmt.Println("showb")
}

type Teacher struct {
	People
}

func (t *Teacher) ShowB() {
	fmt.Println("teachers show b")
}

```

解析：golang的组合模式，可以实现OOP，被组合的类型people所包含的方法虽然升级成了外部类型Teacher这个组合类型的方法(一定为匿名字段)，但它们的方法(ShowA())调用时接受者并没有发生变化。 此时People类型并不知道自己会被什么类型组合，当然也就无法调用方法时去使用未知的组合者Teacher类型的功能。

16、select 随机性

```go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	runtime.GOMAXPROCS(1)
	chanin := make(chan int, 1)
	chanstr := make(chan string, 1)

	chanin <- 7
	chanstr <- "hh"

	select {
	case dat := <-chanin:
		fmt.Println(dat)
	case str := <-chanstr:
		fmt.Println(str)

		default:
			fmt.Println("无需安装")
	}
}

```

解析：

程序中的两个channel都为带缓冲的即 make(chan T,num) 运行时不会报错，若为普通通道则会报错

```go
F:\GO\bin\src\Gomockone>go run select随机性.go
fatal error: all goroutines are asleep - deadlock!

goroutine 1 [chan send]:
main.main()
        F:/Go/bin/src/Gomockone/select随机性.go:13 +0xa6
exit status 2

```

select语句的 原则：

1. select中只要有一个case能return，则立即执行
2. 如果同时有多个case均能return 随机选择任意的一个case执行
3. 若没有case可以执行，则执行default语句





17、初始化数组，make初始化含有默认值

```go
import "fmt"

func main() {
	s := make([]int, 1)
	s = append(s, 1, 2, 3)
	fmt.Println(s)
}

```

结果：

```rust
F:\GO\bin\src\Gomockone>go run ss.go
[0 1 2 3]
```

new(T)与make(T,args) 均用来分配内存，new(T)会为T类型的新值分配已置零的内存空间，并返回地址(指针),即类型为*T的值，返回一个指针，该指针指向新分配的、类型为T的零值。适用于值类型， 数组、结构体

make(T,args)返回初始化之后的T类型的值，该值并不是T类型的零值，也不是*T,是经过初始化之后的T的引用。make()只适用于slice、map、channel

- make 的作用是初始化内置的数据结构
- new根据传入的类型在堆上分配一片内存区域，并返回指向这片内存空间的指针

 18、 go方法集

golang的方法集仅仅影响接口实现和方法表达式转化，与通过实例或者指针调用方法无关

```go
package main

import "fmt"

type Person interface {
	Speak(string) string
}

type Student struct{}

func (s *Student) Speak(think string) string {
	talk := ""
	if think == "x" {
		talk = "yes"
	} else {
		talk = "no"
	}
	return talk
}

func main() {
	var per Person = Student{}
	think := "x"
	fmt.Println(per.Speak(think))
}

```

运行出错

```go
F:\GO\bin\src\Gomockone>go vet ss.go
# command-line-arguments
vet.exe: .\ss.go:22:19: cannot use (Student literal) (value of type Student) as
 Person value in variable declaration: missing method Speak

```

因为接口对象调用者为student指针，初始化的时候需要使用指针

`var per Person=&student{}`

# Golang

谷歌开发的系统编程语言， 具有内置的垃圾回收机制， 支持高并发，可以编译为单个可执行的二进制文件，不需要添加库或运行时环境即可在服务器上执行。

golang不支持泛型，(泛型虽然便捷，在类型系统和运行时的复杂性方面付出了代价)， Go的解决方法使用interface替代任意类型，简单有效。



go run name.go 直接编译并运行go文件，产生的可执行程序在临时文件夹中

go build name.go   在当前目录下生成可执行的文件

go get package_name  下载源码到GOPATH/src

go  install packaege_name  对指定的包进行编译安装

1. package 是一个类库，则在GOPATH/pkg 生成对应的包文件
2. 若为含有main的包，在bin下生成可执行文件



make创建的缓冲区被分配内存之后，如何小获缓冲区，并回收内存

buffer=nil  在运行时buffer=nil 将启动GC 回收内存

引用类型的值的内存分配实在堆中，栈中使用一个地址指向堆中，需要回收时，将栈中的 指针/引用指向nil即可

切片和数组的差异

1. 数组大小固定，切片不固定
2. 切片在运行时可以动态的增加或减少切片的大小，但是数组不可以
3. 使用了内置的添加、赋值功能对切片的操作

golang实现哈希映射

​    哈希表在golang中类似于map

19、以下程序的输出说明什么原因

```go
func main() {

     slice := []int{0,1,2,3}
     m := make(map[int]*int)

     for key,val := range slice {
         m[key] = &val
     }

    for k,v := range m {
        fmt.Println(k,"->",*v)
    }
}
```

结果

```go
0 -> 3
1 -> 3
2 -> 3
3 -> 3
```

解析：`for range` 循环的时候会创建每个元素的副本，而不是元素的引用，所以 m[key] = &val 取的都是变量 val 的地址，所以最后 map 中的所有元素的值都是变量 val 的地址，因为最后 val 被赋值为3，所有输出都是3.

正确写法

```go
 slice := []int{0,1,2,3}
     m := make(map[int]*int)

     for key,val := range slice {
         value := val
         m[key] = &value
     }

    for k,v := range m {
        fmt.Println(k,"===>",*v)
        }
```



20、 new()和make() 的区别

```makefile
new(T) 和 make(T,args) 是 Go 语言内建函数，用来分配内存，但适用的类型不同。

new(T) 会为 T 类型的新值分配已置零的内存空间，并返回地址（指针），即类型为 *T的值。换句话说就是，返回一个指针，该指针指向新分配的、类型为 T 的零值。适用于值类型，如数组、结构体等。

make(T,args) 返回初始化之后的 T 类型的值，这个值并不是 T 类型的零值，也不是指针 *T，是经过初始化之后的 T 的引用。make() 只适用于 slice、map 和 channel.
```

21、以下的程序能否编译通过

```go
list:=new([]int)
list=append(list,1)
```

解析： 编译不能通过,`new`方法返回的list是一个指针类型，不能对指针执行`append`操作。但是可以使用`make`初始化之后再用,通用的`map channel`建议也是用make()初始化

22、以下的程序能否通过编译

```go
func main() {
    list := new([]int)
    list = append(list, 1)
    fmt.Println(list)
}
```

解析：编译不通过，append() 的第二个参数不能直接使用 slice，后边需要`...`才可以将一个切片追加到另一个切片之上。`append(s1,s2…)`

23、以下程序编译能否通过

```go
var(
    size := 1024
    max_size = size*2
)

func main() {
    fmt.Println(size,max_size)
}
```

解析 ：编译失败，  `:=`d的用途

```
1.必须使用显示初始化；
2.不能提供数据类型，编译器会自动推导；
3.只能在函数内部使用简短模式；
```

24、以下的程序编译是否通过

```go
func main() {
    sn1 := struct {
        age  int
        name string
    }{age: 11, name: "qq"}
    sn2 := struct {
        age  int
        name string
    }{age: 11, name: "qq"}

    if sn1 == sn2 {
        fmt.Println("sn1 == sn2")
    }

    sm1 := struct {
        age int
        m   map[string]string
    }{age: 11, m: map[string]string{"a": "1"}}
    sm2 := struct {
        age int
        m   map[string]string
    }{age: 11, m: map[string]string{"a": "1"}}

    if sm1 == sm2 {
        fmt.Println("sm1 == sm2")
    }
}
```

解析：编译失败，结构体的比较

1. 结构体只能比较是否相等，但是不能比较大小
2. 相同类型的结构体才能够进行比较，结构体是否相同不但与属性类型有关，还与属性顺序相关，sn3 与 sn1 就是不同的结构体
3. 如果 struct 的所有成员都可以比较，则该 struct 就可以通过 == 或 != 进行比较是否相等，比较时逐个项进行比较，如果每一项都相等，则两个结构体才相等，否则不相等

可比较的数据类型：`bool`,`数值`,`字符`,`指针`,`数组`。  像是`切片`,`map`,`函数`不可比较。

25、以下程序能否编译

```go
package main

import "fmt"

type MyInt1 int    // 定义一个新类型
type MyInt2 = int  //  类型别名

func main() {
    var i int =0
    var i1 MyInt1 = i 
    var i2 MyInt2 = i
    fmt.Println(i1,i2)
}
```

解析：编译失败，因为MyInt1 是顶一个一个新类型，而MyInt2是int类型得别名(其本质仍为int)，可以赋值

26、下面程序输出结果

```go
package main
import (
	"fmt"
)

func main(){
	a:=[...]int{1,2,3,4,5}
    b:=a[3:4:4]
    fmt.Println(t[0])
}
```

解析： 输出结果为4，切片：假如底层数组的大小为 k，截取之后获得的切片的长度和容量的计算方法：长度：j-i，容量：k-i。截取操作符还可以有第三个参数，形如 [i,j,k]，第三个参数 k 用来限制新切片的容量，但不能超过原数组（切片）的底层数组大小。截取获得的切片的长度和容量分别是：j-i、k-i。

27、以下程序的输出结果为何

```go
func main() {
    a := [2]int{5, 6}
    b := [3]int{5, 6}
    if a == b {
        fmt.Println("equal")
    } else {
        fmt.Println("not equal")
    }
}
```

解析： 程序会报错，虽然a，b都是数组类型，且可以比较，但是数组的长度也是数组类型的组成部分，所以a，b是不同的类型，是不可以进行比较的

28、关于cap函数的适用类型，说法正确的是(abd)

a array

b slie

c map

d channel

解析：cap函数只支持array slice channel

29、以下程序的输出是什么

```go
func main() {  
    s := make(map[string]int)
    delete(s, "h")
    fmt.Println(s["h"])
}
```

解析 ：输出为0  ，删除map中不存在的值不会报错，因为map中不存在任何数据 所以只能返回类型零值

30、下列属于go的关键字的是(a)

a func    b class   c  def   d  echo

Go的25个关键字

``` go
break	default	 func	interface	select	case	defer
go	  map	struct    chan	else	goto	package	  switch
const	fallthrough	  if   range 	type   continue    for
import   return   var  
```

31、下列程序输出为何

```go
func mian(){
	i:=-5
	j:=+5
	fmt.Printf("%+d ,%+d",i,j)
}
```

解析:结果输出为-5,+5   ,`%d` 表示输出十进制的数字，`+`则表示输出数值的符号

32、解析以下程序

```go
type People struct{}

func (p *People) ShowA() {
    fmt.Println("showA")
    p.ShowB()
}
func (p *People) ShowB() {
    fmt.Println("showB")
}

type Teacher struct {
    People
}

func (t *Teacher) ShowB() {
    fmt.Println("teacher showB")
}

func main() {
    t := Teacher{}
    t.ShowB()
}
```

解析：此为结构体嵌套，Teacher是一个外部的类型，内嵌People。内部类型的属性、方法，可以为外部类型所有，就好像是外部类型自己的一样。此外，外部类型还可以定义自己的属性和方法，甚至可以定义与内部相同的方法，这样内部类型的方法就会被`“屏蔽”`。这个例子中的 ShowB() 就是同名方法。

33、解析程序

```go
func hello(i int) {  
    fmt.Println(i)
}
func main() {  
    i := 5
    defer hello(i)
    i = i + 10
}
```

解析：输出结果为5，hello() 函数的参数在执行 defer 语句的时候会保存一份副本，在实际调用 hello() 函数时用，所以是 5。

34、 修改以下程序

```go
func main(){
	var m map[string]int
	m["a"]=1
	if v:=m["b"];v!=nil{
		fmt.Println(v)
	}
}
```

改进之后

```go
func main(){
	m:=make(map[string]int)
	m["a"]=1
	if v,ok:=m["b"];ok{
		fmt.Println(v)
	}
}
```

解析：对于map的使用，必须先声明并且初始 即使用`make`

35、以下程序的返回值为何：

```go
func increaseA() int {
    var i int
    defer func() {
        i++
    }()
    return i
}

func increaseB() (r int) {
    defer func() {
        r++
    }()
    return r
}

func main() {
    fmt.Println(increaseA())
    fmt.Println(increaseB())
}
```

解析：返回值 ，return，defer的执行顺序是： 先为返回值赋值，然后执行defer，所以执行结果为0,1

36、以下的两个切片声明的区别为何

```go
var  a []int
b:=[]int{}
```

解析：第一种方式声明的是`nil`的切片,第二种则是长度和容量为0的空切片，第一种切片声明不会分配内存，优先选择

37、  语法错误的是：

```go
type S struct {
}

func f(x interface{}) {
}

func g(x *interface{}) {
}

func main() {
    s := S{}
    p := &s
    f(s) //A
    g(s) //B
    f(p) //C
    g(p) //D
}
```

解析：BD  函数的参数为`interface`  表明可以接受任何类型的参数，即使接受指针类型也是`interface{}`,而不是`*interface{}`。还有一点则是"**永远不用使用一个指针指向一个接口类型，因为它本身已经是一个指针了**"

38、

```go
var a bool = true
func main() {
    defer func(){
        fmt.Println("1")
    }()
    if a == true {
        fmt.Println("2")
        return
    }
    defer func(){
        fmt.Println("3")
    }()
}
```

结果：

```
this is return sytanx
this is the first defer
```

解析：defer 关键字后面的函数或者方法想要执行必须先注册，`return` 之后的 defer 是`不`能注册的， 也就不能执行后面的函数或方法

39、程序解析

```go
    s1 := []int{1, 2, 3}
    s2 := s1[1:]
    s2[1] = 4
    fmt.Println(s1)
    s2 = append(s2, 5, 6, 7)
    fmt.Println(s1)
```

解析： s2属于s1的切片 所以s2和s1共享一个底层数组，所以`s2[1]=4`导致底层数组的变化 所以s1发生了变化，而append操作会导致底层数组的扩容，s2 也因此指向了新的数组，所以s2得append操作不会改变s1指向得底层数组得变化。

40、程序解析

```go
func (i int) PrintInt ()  {
    fmt.Println(i)
}

func main() {
    var i int = 1
    i.PrintInt()
}
```

解析： 这段程序是不可编译的，因为基于 int 类型创建了 PrintInt() 方法，由于 int 类型和方法 PrintInt() 定义在不同的包内，所以编译出错。特批(**基于类型创建的方法必须定义在同一个包内**)

41、程序解析

```go
const (
    a = iota
    b = iota
)
const (
    name = "name"
    c    = iota
    d    = iota
)
func main() {
    fmt.Println(a)
    fmt.Println(b)
    fmt.Println(c)
    fmt.Println(d)
}
```

解析： 输出为`0 1 1 2` .  iota是golang语言中的常量计数器，只能用于常量的表达式中， iota在`const`关键字出现时将被重置为`0`,const中每增加一行常量声明将使iota计数一次。

42、以下程序对的输出内容

```go
type Direction int

const (
    North Direction = iota
    East
    South
    West
)

func (d Direction) String() string {
    return [...]string{"North", "East", "South", "West"}[d]
}

func main() {
    fmt.Println(South)
    i:=i{}

	fmt.Println(i) //结果为0
    
    y:=&i{}
    fmt.Println(y) //  结果为 i is 0
}

type i struct {

	x int
}

func (i *i)String()string{
	return fmt.Sprintf("i is %v",i.x)
}
```

解析： 输出为south，根据iota可以推断出south的值为3，如果类型定义了		`String`方法，当使用fmt.Printf(),fmt.Println(),fmt.Print() 会自动调用这个string方法，实现字符串的打印， 如果String为指针方法，使用fmt系列 函数时，不会调用String方法。若需要隐式调用则需要声明时，指定为 该类型的指针

42、程序解析

```go
type Math struct{
	x,y int
}
var m=map[string]Math{
	"x":Math{1,2},
}
func main(){
    m["x"].x=4
    fmt.Println(m)
}
```

解析：编译错误，关于map的字段 需要了解的，当map的字段为`struct`类型时，无法直接更改这个字段的值(因为map中的元素不可寻址，需要区分的则是slice中的元素可以寻址)，若要强制更改map中的字段值方法有二： 1) 使用局部变量

```go
 tmp := m["foo"]
    tmp.x = 4
    m["foo"] = tmp
    fmt.Println(m["foo"].x)
```

2) 使用指针类型

```go
type Math struct {
    x, y int
}

var m = map[string]*Math{
    "foo": &Math{2, 3},
}

func main() {
    m["foo"].x = 4
    fmt.Println(m["foo"].x)
    fmt.Printf("%#v", m["foo"])   // %#v 格式化输出详细信息
}
```

43、程序解析：

```go
func main() {
    fmt.Println([...]int{1} == [2]int{1})
    fmt.Println([]int{1} == []int{1})
}
```

解析：程序中的错误有两处：一、go中不同的类型是不可以比较的(数组的长度也是数组中的一部分)；二、切片是不可以比较的

44、程序解析

```go
var p *int   // 全局变量

func foo() (*int, error) {
    var i int = 5
    return &i, nil
}

func bar() {
    //use p
    fmt.Println(*p)
}

func main() {
    p, err := foo()   //局部变量p  覆盖了原有的全局变量p
    if err != nil {
        fmt.Println(err)
        return
    }
    bar()
    fmt.Println(*p)
}
```

解析： 程序的运行结果为`runtime error`,变量作用域。问题出在操作符`:=`，对于使用:=定义的变量，如果新变量与同名已定义的变量不在同一个作用域中，那么 Go 会新定义这个变量。对于本例来说，main() 函数里的 p 是新定义的变量，会`遮住`全局变量 p，导致执行到bar()时程序，全局变量 p 依然还是 nil，程序随即 Crash。

关于本程序的修改

```go
func main() {
    var err error
    p, err = foo()
    if err != nil {
        fmt.Println(err)
        return
    }
    bar()
    fmt.Println(*p)
}
```

45、程序解析

```go
func main() {
	a := [...]int{1, 2, 3}
	for k,v := range a {
		go func() {
			fmt.Println(k,v)
		}()
	}
	time.Sleep(time.Second*3)
}
```

结果输出为

```go
F:\GO\bin\src\train>go run ccc.go
2 3
2 3
2 3
```

for range 使用短变量声明(`:=`)的方式迭代变量，值得注意的是变量i,v 在每次循环体中都会被`重用`,而不是重新声明。各个 goroutine 中输出的 i、v 值都是 for range 循环结束后的 i、v 最终值，而不是各个goroutine启动时的i, v值。可以理解为闭包引用，使用的是上下文环境的值。

改进方式

```go
// 使用参数传递
for k,v := range a {
		go func(k,v int) {
			fmt.Println(k,v)
		}(k,v)
	}
```

```go
// 使用临时变量保留当前值
for i, v := range m {
    i := i           // 这里的 := 会重新声明变量，而不是重用
    v := v
    go func() {
        fmt.Println(i, v)
    }()
}
```

46、

```go
func f(n int)(r int){
	defer func() {
		r+=n
		recover()
	}()
	var f func()
	defer f()

	f= func() {
		r+=2
	}
	return n+1
}
func main(){
    fmt.Println(f(3))
}
```

解析：  程序返回值为7,    执行步骤：先执行`return `即 r=n+1， 随后执行第二个defer，由于未定义f()，会发生panic，然后去执行第一个defer  r=r+n   返回值 r=7  

47、

```go
 var a = [5]int{1, 2, 3, 4, 5}
    var r [5]int

    for i, v := range a {
        if i == 0 {
            a[1] = 12
            a[2] = 13
        }
        r[i] = v
    }
    fmt.Println("r = ", r)// r=[1,2,3,4,5]
    fmt.Println("a = ", a)//a=[1,12,13,4,5]
```

在`for range` 中迭代的为元素的副本，本例中迭代的则是a的副本，a的变化不会导致结果的变化即 r=[1,2,3,4,5]。 若要改动a且影响到r的值，迭代时需要传递a的地址，从而改变其值。

```go
for i,v :=range &a{
	if i==0{
		a[2]=8
	}
	r[i]=v
}
//  此时输出的a 和r 完全一致
```

48、关于可变参数

```go
func change(s ...int) {
    s = append(s,3)
}

func main() {
    slice := make([]int,5,5)
    slice[0] = 1
    slice[1] = 2
    change(slice...)
    fmt.Println(slice)
    change(slice[0:2]...)
    fmt.Println(slice)
}
```

解析： 可变参数，Go 提供的语法糖`...`,可以将 slice 传进可变函数，不会创建新的切片。第一次调用 change() 时，append() 操作使切片底层数组发生了扩容，原 slice 的底层数组不会改变；第二次调用change() 函数时，使用了操作符[i,j]获得一个新的切片，假定为 slice1，它的底层数组和原切片底层数组是重合的，不过 slice1 的长度、容量分别是 2、5，所以在 change() 函数中对 slice1 底层数组的修改会影响到原切片。

49、关于协程，下面说法正确是（AD）

- A. 协程和线程都可以实现程序的并发执行；
- B. 线程比协程更轻量级；
- C. 协程不存在死锁问题；
- D. 通过 channel 来进行协程间的通信；

50、关于程序输出正确得是：

```go
func main() {
    i := 1
    s := []string{"A", "B", "C"}
    i, s[i-1] = 2, "Z"
    fmt.Printf("s: %v \n", s)
}

```

输出为[z,b,c]  golang中得多重赋值，分为两个步骤，有先后顺序

1. 计算等号左边得索引表达式和取地表达式，接着计算等号右边得表达式
2. 赋值

因此本例先计算s[i-1]，等同于 i,s[0]=2,z

51、

```go
const j=123
var i=789
func main(){
	fmt.Println(&j,&i)
}
```

```go
invalid operation: cannot take address of j (untyped int
constant 123)
```

解析:常量不同于变量的运行期间分配内存，常量通常会被编译器在预处理阶段直接展开，作为指令数据，无法寻址。

nil 可以用作 interface、function、pointer、map、slice 和 channel 的“空值”。但是如果不特别指定的话，Go 语言不能识别类型，

52、以下程序的结果为何

```go
func Foo(x interface{}) {
     if x == nil {
         fmt.Println("empty interface")
         return
     }
     fmt.Println("non-empty interface")
}
func main() {
     var x *int = nil
    Foo(x)
}
```

解析：结果为`non-empty interface`,inerface组成为：类型和值，当且仅当类型和值都为nil时，interface才为nil

53、关于select机制，下面说法正确的是(ABC)

- A. select机制用来处理异步IO问题；
- B. select机制最大的一条限制就是每个case语句里必须是一个IO操作；
- C. golang在语言级别支持select关键字；
- D. select关键字的用法与switch语句非常类似，后面要带判断条件；

54、程序解析

```go
func Stop(stop <-chan bool){
	close(stop)
}

```

解析： panic:(invalid argument: stop (variable of type <-chan bool) must
not be a receive-only channel) 

stop 是从通道中读取的值，close是关闭channel，而不是关闭值。

55、

```go
type Param map[string]interface{}

 type Show struct {
     *Param
 }

 func main() {
     s := new(Show)
     s.Param["day"] = 2
}
```

解析：程序出错， 问题一：map需要初始化才可以使用，问题二：指针不支持索引。 

```go
func main() {
	s:=Show{}
	p:=make(Parm)

	p[1]=0

	s.Parm=&p
	fmt.Println(*s.Parm)
}

type Parm map[int]interface{}

type Show struct {
	*Parm
}
```

56、

```go
type ConfigOne struct {
     Daemon string
 }

 func (c *ConfigOne) String() string {
     return fmt.Sprintf("print: %v", c)
 }

 func main() {
    c := &ConfigOne{}
    c.String()
}
```

运行结果

```
runtime: goroutine stack exceeds 1000000000-byte limit
runtime: sp=0xc020161338 stack=[0xc020160000, 0xc040160000]
fatal error: stack overflow
```

解析： 如果类型实现String方法，当格式化输出时会自动使用String方法，上面的。这段代码是在该类型的 String() 方法内使用格式化输出，导致递归调用，最后抛错。(由于未确定c的具体值，所以一致递归调用)。

57、

```go
x:=interface{}(nil)
	y:=(*int)(nil)
	a:=y==x
	b:=y==nil
	d,c:=x.(interface{})
```

其中a为 false  b为true  c为false，类型断言语法：i.(Type)，其中 i 是接口，Type 是类型或接口。编译时会自动检测 i 的动态类型与 Type 是否一致。但是，如果动态类型不存在，则断言总是失败

58、

```go
type info struct {
    result int
}
func work() (int,error) {
    return 13,nil
}
func main() {
    var data info
    data.result, err := work() 
    fmt.Printf("info: %+v\n",data)
}
```

```
 non-name data.result on left side of :=
```

不能使用短变量声明设置结构体字段。

59、

```go
func main() {
    isMatch := func(i int) bool {
        switch(i) {
        case 1:
        case 2:
            return true
        }
        return false
    }
    fmt.Println(isMatch(1))
    fmt.Println(isMatch(2))
}
```

结果为false ，true。 Go 语言的 switch 语句虽然没有"break"，但如果 case 完成程序会默认 break，可以在 case 语句后面加上关键字 fallthrough，这样就会接着走下一个 case 语句（不用匹配后续条件表达式）。或者，利用 case 可以匹配多个值的特性。

修改之后的程序

```go
func main() {
	is := func(i int) bool {
		switch i {

	    case 1,2:
			return true
		}
		return false
	}
	fmt.Println(is(1))
	fmt.Println(is(2))
}

```

60、

```go
type N int

func (n N) test(){
     fmt.Println(n)
 }

 func main()  {
     var n N = 10
     p := &n

    n++
    f1 := n.test

    n++
    f2 := p.test

    n++
    fmt.Println(n)

    f1()
    f2()
}
```

解析：13 11 12,当指针值赋值给变量或者作为函数参数传递时，会立即计算并复制该方法执行所需的接收者对象，与其绑定，以便在稍后执行时，能隐式第传入接收者参数。

61、

```go
type T struct {
    x int
    y *int
}

func main() {

    i := 20
    t := T{10,&i}

    p := &t.x

    *p++
    *p--

    t.y = p

    fmt.Println(*t.y)
}
```

運算符優先級规则：递增运算符 ++ 和递减运算符 -- 的优先级低于解引用运算符 * 和取址运算符 &，解引用运算符和取址运算符的优先级低于选择器 . 中的属性选择操作符。

62、

```go
var n N = 10
    p := &n

    n++
    f1 := n.test

    n++
    f2 := p.test

    n++
    fmt.Println(n)

    f1()
    f2()
```

儅目標方法的接收者是指針類型時，被複製的為指針

63、

```go
package main

type T struct{}

func (*T) foo() {
}

func (T) bar() {
}

type S struct {
  *T
}

func main() {
  s := S{}
  _ = s.foo
  s.foo()
  _ = s.bar
}
```

s.bar() 展開為 (*s.T).bar, s.T為`空指針`，解引用引起`panic`

64、

```go
func main() {

	var k = 9
	for k = range []int{} {}
	fmt.Println(k)

	for k = 0; k < 3; k++ {
	}
	fmt.Println(k)


	for k = range (*[3]int)(nil) {
	}
	fmt.Println(k)
	
}
```

輸出結果為：9 3 2

65、

```go
func  main(){
	nil:=12
	var _ map[string]int=nil
}
```

在當前作用域中 nil被賦值爲int類型，不能賦值給map

66、

```go
func main() {
    var x int8 = -128
    var y = x/-1
    fmt.Println(y)
}
```

結果爲`-128`,原因是内存溢出。



67、下面选项正确的是(AD)

- A. 类型可以声明的函数体内；
- B. Go 语言支持 ++i 或者 --i 操作；
- C. nil 是关键字；
- D. 匿名函数可以直接赋值给一个变量或者直接执行；

68、

```go
func F(n int) func() int {
    return func() int {
        n++
        return n
    }
}

func main() {
    f := F(5)
    defer func() {
        fmt.Println(f())
    }()
    defer fmt.Println(f())
    i := f()
    fmt.Println(i)
}
```

結果爲：7 6 8 ，defer後面的函數如果帶參數，會優先計算參數，并將結果存儲在棧中，直到defer的時候取出。

69、 flag 是 bool 型变量，下面 if 表达式符合编码规范的是(BCD)

- A. if flag == 1
- B. if flag
- C. if flag == false
- D. if !flag

70、

```go
type T struct {
	n int
}
func main() {
	ts:=[2]T{}
	for i,t :=range &ts{
		switch i {
		case 0:
			t.n=3
			ts[1].n=9
		case 1:
			fmt.Println(t.n)

		}
	}
	fmt.Println(ts)
}

```

結果為：9，{{0},{9}},  因爲range 傳遞的是副本所以t.n=3  不會影響數組的值，傳遞的是ts的地址，對t[1]的更改會影響數組的值。

71、關於字符串的連接語法正確的是()

- A  str:='abc'+'123'
- B   str:="ad"+"\nd"
- C   str:='12'+"ac"
- D   fmt.Sprintf("adc%d",123)

在GO中 雙引號表示字符串，其實質是一個byte類型的數組，單引號則表示rune類型

72、

```go
func main() {

    println(DeferTest1(1))
    println(DeferTest2(1))
}

func DeferTest1(i int) (r int) {
    r = i
    defer func() {
        r += 3
    }()
    return r
}

func DeferTest2(i int) (r int) {
    defer func() {
        r += i
    }()
    return 2
}
```

輸出為： 4，  3 

73、

```go
var f = func(i int) {
    print("x")
}

func main() {
    f := func(i int) {
        print(i)
        if i > 0 {
            f(i - 1)
        }
    }
    f(10)
}
```

输出结果为10x，  此处的f(x-1)不是递归调用，而是调用预定义好的全局变量f()

74、p為野指針，因爲返回的棧内存在函數結束時會被釋放？

```go
type TimesMatcher struct {
    base int
}

func NewTimesMatcher(base int) *TimesMatcher  {
    return &TimesMatcher{base:base}
}

func main() {
    p := NewTimesMatcher(3)
    fmt.Println(p)
}

```

A. false
       B. true

解析： 錯誤， go中的GC規定，只要有一個指針指向引用一個變量，那麽這個變量就不會被釋放，在Go中返回函數參數或臨時變量是安全的。
