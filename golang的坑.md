# golang的坑

左大括号不能单独放一行

变量定义之后必须使用

包引入之后也需要使用 未使用的话可以用_忽略导入的包

简短声明只能之函数内部使用 a:=1

不能使用 简短声明重复声明单独的变量 左侧最少有一个新变量

不能使用简短声明来设置字段的值 struct 字段不能使用:=来赋值使用预定义的变量来避免解决。

 

变量覆盖： := 变量声明赋值的简写 != 赋值 可以使用vet工具诊断这种覆盖因为go默认不做覆盖检查， 添加-shadow选项来启用 go tool vet -shadow name.go

注： vet 不会报告全部被覆盖的变量，可以使用go-nyet 进一步检测。

 

显示类型的变量无法使用nil来初始化

​    nil 是引用类型的初始值 interface slice map function channel pointer,声明时必须指定类型 如： var x interface()=nil

 

直接使用值为nil的slice、map

​    允许对值为nil的slice添加元素，但对值为nil的map添加元素则会造成运行时的panic 

// slice 正确示例

```go
func main() {

  var s []int

  s = append(s, 1)

}
```



map的容量

   在创建map的时候可以指定容量，但不能像slice一样使用cap检测分配空间的大小

 

string类型的值不能为nil

 

Array类型的值作为函数参数

​    在golang中函数中使用数组作为参数时 如果需要修改数组的原始值，传参时需要传递 数组的指针类型  func(arr *[int]stirng)

 

直接使用slice即使函数内部得到的是slice的值拷贝，依旧会更新slice的原始数据

 

range遍历slice和array golang使用range遍历slice和array时，会生成key和value

 

slice和array为一维数据

使用原始的一维数组、“独立“ 的切片、“共享底层数组”的切片来创建动态的多维数组

 

 

1.使用原始的一维数组：要做好索引检查、溢出检测、以及当数组满时再添加值时要重新做内存分配。

 

2.使用“独立”的切片分两步：

 

创建外部 slice

 

对每个内部 slice 进行内存分配

 

注意内部的 slice 相互独立，使得任一内部 slice 增缩都不会影响到其他的 slice

 

1.使用“共享底层数组”的切片

 

创建一个存放原始数据的容器 slice

创建其他的 slice

切割原始 slice 来初始化其他的 slice

 

 

访问map中不存在的key

   go中直接返回元素对应类型的零值，比如nil，flase，"",0 检测key是否存在，直接利用map查看，key对应的value是否存在 

   if _,ok:=x[lkey];!ok{fmt.Pirntln("key is no entry")}

 

string 类型的值时常量，不可更改

​    若要修改string的值 先把string修改为rune类型 在进行修改 rune slice可以存储多个byte

   x:="acv"  xbytes:=[]rune(x)  xbytes[1]='c'  x=string(xbytes)

 

string和byte slice间的转换

 

Go 在 string 与 byte slice 相互转换上优化了两点，避免了额外的内存分配：

 

在 map[string] 中查找 key 时，使用了对应的 []byte，避免做 m[string(key)] 的内存分配

使用 for range 迭代 string 转换为 []byte 的迭代：for i,v := range []byte(str) {...}

 

 

字符串不是UTF8文本

   判断字符串是否为utf8的格式 ，可以使用ubicode/utf8中的ValidString() 函数

   ok:=utf8.ValidString（str）

 

 

字符串的长度：

​    内置的len() 统计字符串的字节数量，如果要得到字符串的字符数需要使用unicode/utf8 中的函数 RuneCountIntString(str)(int)

注： RunCountIntString() 并不总是返回直观观察到的字符数,有的字节占据2个rune

 

在多行array 、slice、map语句中缺少，号

​      

 y := []int{1,2,}  

  z := []int{1,2}  

 

 x := []int {

​    1,

​    2  ，}

   声明语句中}折叠到单行后，尾部的逗号不是必须的

 

log.Fatal和log.Panic 不单单是日志  可以终端程序的执行

 

对内建数据结构的操作并不是同步的

尽管go有大量的特性支持并发，并不保证并发的数据安全，用户需要保证变量等数据以原子操作更新， goroutine和channel 进行原子操作的好方法，或使用sync中的锁

 

range 迭代string得到的值

   将string转换为byte 类型 在遍历

  for _,v:=range []byte(str)

 

range 迭代map

   

Go 的运行时是有意打乱迭代顺序的，所以你得到的迭代结果可能不一致。但也并不总会打乱，得到连续相同的 5 个迭代结果也是可能的。

 

switch中的fallthrough语句

​     switch中的case代码块会默认带上break，但可以使用fallthrough来强制执行下一个case代码块，

 

自增和自减运算符

​    

很多编程语言都自带前置后置的 ++、-- 运算。但 Go 特立独行，去掉了前置操作，同时 ++、— 只作为运算符而非表达式。

golang中表示为i++ 而不是++I

 

按位取反

​    GO用^操作符来按位取反 同时^也是按位异或操作符

一个操作符能重用两次，是因为一元的 NOT 操作 NOT 0x02，与二元的 XOR 操作 0x22 XOR 0xff 是一致的。

 

Go 也有特殊的操作符 AND NOT &^ 操作符，不同位才取1。

 

运算符的优先级

  除了位清除(bit clear)操作符,GO也有很多其他语言的位操作符

 	**a<<b a左移b位后的值为：a*(2^b)**

  Precedence  Operator     

```
    5       * / % << >> & &^

​    4       + - | ^

​    3       == != < <= > >=

​    2       &&

​    1       ||

```

不导出的struct字段无法被encode

​    struct中的字段以小写开头的字段成员是无法被外界所访问的，所以在进行json、xml、gob等格式encode操作时，这些私有字段会被忽略，导出时为零值

 

 

程序退出时还有goroutine在执行

​    程序默认不等所有的goroutine都执行完才退出，常用sync下的WaitGroup让主程序陷入等待，等所有的goroutine全部执行完毕之后在结束程序

 

从已关闭的 channel 接收数据是安全的：

 

接收状态值 ok 是 false 时表明 channel 中已没有数据可以接收了。类似的，从有缓冲的 channel 中接收数据，缓存的数据获取完再没有数据可取时，状态值也是 false

 

向已关闭的 channel 中发送数据会造成 panic：

 

使用了值为nil的channel

   在一个值为nil的channel上发送和接收数据永远阻塞

 

  

若函数 receiver 传参是传值方式，则无法修改参数的原有值

方法 receiver 的参数与一般函数的参数类似：如果声明为值，那方法体得到的是一份参数的值拷贝，此时对参数的任何修改都不会对原有值产生影响。

 

除非 receiver 参数是 map 或 slice 类型的变量，并且是以指针方式更新 map 中的字段、slice 中的元素的，才会更新原有值:

 

## 二、 

### 关闭HTTP响应体

   

使用 HTTP 标准库发起请求、获取响应时，即使你不从响应中读取任何数据或响应为空，都需要手动关闭响应体。新手很容易忘记手动关闭，或者写在了错误的位置：



```
  tr := http.Transport{DisableKeepAlives: true}

  client := http.Client{Transport: &tr}

 

  resp, err := client.Get("https://golang.google.cn/")

  if resp != nil {

​    defer resp.Body.Close()

  }

  checkError(err)

 

  fmt.Println(resp.StatusCode)  // 200

 

  body, err := ioutil.ReadAll(resp.Body)

  checkError(err)

 

  fmt.Println(len(string(body)))

 
```

根据需求选择使用场景：

 

若你的程序要向同一服务器发大量请求，使用默认的保持长连接。

若你的程序要连接大量的服务器，且每台服务器只请求一两次，那收到请求后直接关闭连接。或增加最大文件打开数 fs.file-max 的值

### struct、map、slice、array 的值比较

使用==比较结构体变量，前提是两个结构体的成员都是可比价的类型

golag提供了无法比较的变量使用reflect下的DeepEqual()

注： 两个slice相等值和顺序必须一致 裁判定位相等

```go
 s1 := []int{1, 2, 3}

  s2 := []int{1, 2, 3}

​    // 注意两个 slice 相等，值和顺序必须一致

  fmt.Println("v1 == v2: ", reflect.DeepEqual(s1, s2))  // true
```

 如果要大小写不敏感来比较 byte 或 string 中的英文文本，可以使用 "bytes" 或 "strings" 包的 ToUpper() 和 ToLower() 函数。比较其他语言的 byte 或 string，应使用 bytes.EqualFold() 和 strings.EqualFold()

 

如果 byte slice 中含有验证用户身份的数据（密文哈希、token 等），不应再使用 reflect.DeepEqual()、bytes.Equal()、 bytes.Compare()。这三个函数容易对程序造成 timing attacks，此时应使用 "crypto/subtle" 包中的 subtle.ConstantTimeCompare() 等函数

 

reflect.DeepEqual() 认为空 slice 与 nil slice 并不相等，但注意 byte.Equal() 会认为二者相等：

### 从panic中恢复程序

   在一个defer延迟执行的函数中调用recover，便可以捕捉/中断panic

  recover必须很defer结合使用

 

在range迭代slice、map、array时通过更新引用来更新元素

  迭代之后得到其实为元素的一份值拷贝,更新拷贝不会改变原来的值,

   若要修改原来的值，需要通过索引去修改

  如果集合保存的时指向值的指针，仍需要索引访问元素，可以使用range来直接更新元数据

 

### slice中隐藏的数据

从 slice 中重新切出新 slice 时，新 slice 会引用原 slice 的底层数组。如果跳了这个坑，程序可能会分配大量的临时 slice 来指向原底层数组的部分数据，将导致难以预料的内存使用。可以通过拷贝临时 slice 的数据，而不是重新切片来解决**：**

```Go
func get() (res []byte) {

  raw := make([]byte, 10000)

  fmt.Println(len(raw), cap(raw), &raw[0])  // 10000 10000 0xc420080000

  res = make([]byte, 3)

  copy(res, raw[:3])

  return

}


func main() {

  data := get()

  fmt.Println(len(data), cap(data), &data[0])  // 3 3 0xc4200160b8

}
```

 旧slice

在一个已经存的slice中创建新的slice时，二者的数据指向相同的底层数据，某些情况下

，像一个slice中追加元素而它指向的底层数据容量不足时，将会重新分配一个新数组来存储数据，而其他的slice还指向原来的旧底层数组。 

### 类型声明方法

   声明一个自定义的方法时，不会继承原先的方法，若要继承原先的方法，可以将原类型的方法以匿名字段的形式嵌入到自定义的struct中

如：

```go
type my struct{

    sync.WaitGroup
}
```

interface类型声明 保留了原有的方法集

跳出 for -switch  for -select 代码块

   break配合label跳出指定的代码块； 

  goto 虽然也能跳转到指定位置，但依旧会再次进入 for-switch，死循环。

```go
func main() {

loop:

  for {

​    switch {

​    case true:

​      fmt.Println("breaking out...")

​      //break  // 死循环，一直打印 breaking out...

​      break loop

​    }

  }

  fmt.Println("out...")

}
```

for 循环中的迭代变量与闭包函数

 直接将当前的迭代值以参数形式传递给匿名函数

 

defer 函数的参数值

   对defer延迟执行的函数，它的参数会在声明的时候就会求出具体值，而不是执行时才求值。 

### defer函数的执行时机

​    对 defer 延迟执行的函数，会在调用它的函数结束时执行，而不是在调用它的语句块结束时执行，注意区分开。 

比如在一个长时间执行的函数里，内部 for 循环中使用 defer 来清理每次迭代产生的资源调用，就会出现问题： 

### 更新map字段的值

​    如果map的一个字段的值是struct类型，无法直接修改这个字段的值

   因为 map 中的元素是不可寻址的。需区分开的是，slice 的元素可寻址：

 

​    更新map中struct元素的字段有两个方法

   1、使用局部变量

```go

  m := map[string]data{

​    "x": {"Tom"},

  }

  r := m["x"]

  r.name = "Jerry"

  m["x"] = r

  fmt.Println(m)  // map[x:{Jerry}]
```

   2、使用元素的map指针

```go
  m := map[string]*data{

​    "x": {"Tom"},

  }
  m["x"].name = "Jerry"  // 直接修改 m["x"] 中的字段

  fmt.Println(m["x"])  // &{Jerry}
```

 

 

### 类型断言：

   由一个具体类型和及具体类型的值组成的接口值，分为动态类型和动态值

   判断接口中的值，使用类型断言 x.(T)  x表示类型为接口的变量，返回两个参数，第一个参数是x转化为T类型后的变量，第二个值是一个bool，若为true' 表示断言成功，为false 表示断言失败。

  断言的方法1、 value,ok:=x.(T)

​            2、switch          

```
switch instance :=接口对象.(type){

case 实际类型1:

....

case 实际类型2：

   ......

 

default:

.....

 

}
```

 

阻塞goroutine与资源泄露

​    使用带缓冲区的chan确保接收全部的goroutine接口全部的返回结果

 

 

 

## 究极篇：

   使用指针作为参数传递

interface只有在值和类型均为nil时才为nil

如果函数的返回值为interface类型 注意返回值

```
func main() {

  doIt := func(arg int) interface{} {

​    var result *struct{} = nil

​    if arg > 0 {

​      result = &struct{}{}

​    } else {

​      return nil  // 明确指明返回 nil

​    }

​    return result

  }

 

  if res := doIt(-1); res != nil {

​    fmt.Println("Good result: ", res)

  } else {

​    fmt.Println("Bad result: ", res)  // Bad result: <nil>

  }

}

 
```

关于内存的那些事：

​    go中使用new() 和make() 创建变量.变量为内存分配位置依旧归go编译器管理 ，GO可以根据内存大小 返回变量的准确内存地址，在gobuild 或go run时加上-m参数可以准确的返回内存分配位置。

并发 并行

​    在go之前版本中 ，任何时间至多有一个goroutine运行，

   在随后的版本中可以设置runtime.NumCPU() 设置上下文数量，返回逻辑cpu的核心数，或可以 设置环境变量 GOMAXPROCS动态的使用 runtime.GOMAXPROCS() 来调整。

注：GOMAXPROCS 表示执行 goroutine 的 CPU 核心数

   GOMAXPROCS 的值是可以超过 CPU 的实际数量的

 

 

new() 与make() 的区别

  new(T)与make(T,args) 均用来分配内存，new(T)会为T类型的新值分配已置零的内存空间，并返回地址(指针),即类型为*T的值，返回一个指针，改指针指向新分配的、类型为T的零值。适用于值类型， 数组、结构体

make(T,args)返回初始化之后的T类型的值，该值并不是T类型的零值，也不是*T,是经过初始化之后的T的引用。make()只适用于slice、map、channel

 

defer func(){recover()} 恢复panic

