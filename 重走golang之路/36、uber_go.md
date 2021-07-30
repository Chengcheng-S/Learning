### 1、 指向interface的指针

将接口类型作为值传递，在传递过程中，实质上传递的底层数据仍然可以是**指针**。

interface实质上在底层用两个字段表示：

-  指向某种信息的指针  <====> `type`
- 数据指针。 若存储的数据是指针，直接存储，若存储的是一个值，则存储指向该值的指针。

```go
type F interface{
	f()
}
type s1 struct{}

func (s s1)f(){}

type s2 struct{}
func (s *s2) f(){}
```

对于 s1 和s2 的区别在于 s1 无法修改底层的数据，但是s2 可以直接修改底层的数据。

### 2、interface合理性验证

编译时验证接口的符合性， 包含：

1.  将实现特定接口的导出类型作为接口API的一部分进行检查
2. 实现统一接口的(导出和非导出) 类型属于实现类型的集合
3. 任何违反接口合理性检查的场景都会终止编译，并且通知给用户。

```go
type Handler struct{...}

func (h *Handler)ServeHTTP{
	w http.ResponseWriter,
	r *http.Request,
}
```

若 Handler没有实现`http.Handler` 会在运行时报错

solution：

```go
type Handler struct{...}
var _http.Handler=(*Handler)(nil)
func (h *Handler)ServeHTTP{
	w http.ResponseWriter,
    r *http.Request,
}{
    //...
}
```

若  `*Handler` 与 `http.Handler` 的接口不匹配, 那么语句 `var _ http.Handler = (*Handler)(nil)` 将无法编译通过。

赋值的右边应该是断言类型的零值，对于pointer、slice、map 这是nil， 对于 struct 这是空的

```go
type LogHandler struct {
  h   http.Handler
  log *zap.Logger
}
var _ http.Handler = LogHandler{}
func (h LogHandler) ServeHTTP(
  w http.ResponseWriter,
  r *http.Request,
) {
  // ...
}
```

### 接收器与接口

使用值接收器的方法既可以通过值调用，也可以通过指针调用。 带指针接收器的方法只能通过指针或`addressable values` 调用

```go
type S struct {
  data string
}

func (s S) Read() string {
  return s.data
}

func (s *S) Write(str string) {
  s.data = str
}

sVals := map[int]S{1: {"A"}}

// 你只能通过值调用 Read
sVals[1].Read()

// 这不能编译通过：
//  sVals[1].Write("test")

sPtrs := map[int]*S{1: {"A"}}

// 通过指针既可以调用 Read，也可以调用 Write 方法
sPtrs[1].Read()
sPtrs[1].Write("test")
```

类似的,即使方法有了值接收器,也同样可以用指针接收器来满足接口

ps: 

-  一个类型可以又值接收器方法和指针接收器方法集
  - 值接收器方法集是指针方法值得自己，反之不是
- 规则  
  - 值对象只可以使用值接收器方法集
  - 指针对象可以使用值接收器方法+指针接收器方法
- 接口的匹配
  - 类型实现了接口的所有方法叫做匹配
  - 要么是类型的值方法集匹配接口,要么是指针方法集匹配接口
- 值方法集和接口匹配
  - 给接口变量赋值的不管是值还是指针对象，都可以，因为都包含值方法集
- 指针方法集和接口匹配
  - 只能将指针对象赋值给接口变量，因为只有指针方法集和接口匹配
  - 如果将值对象赋值给接口变量，会在编译期报错(触发接口检测机制)

### 零值Mutex是有效的

零值的`sync.Mutex` 和`sync.RWMutex`是有效的。所以指向`mutex`的指针基本是不必要的。

```go
mu:=new(sync.Mutex)  //  多此一举
mu.Lock()
```



```go
var mu sync.Mutex
mu.Lock()
```

若使用接口体指针，mutex可以非指针的形式作为接口提的组成字段，或者更高的方式是直接嵌套在接口体之中。如果私有接口体类型或是要实现Mutex接口的类型，可以使用嵌入mutex的方法。

```go
type smap struct {
  sync.Mutex // only for unexported types（仅适用于非导出类型）

  data map[string]string
}

func newSMap() *smap {
  return &smap{
    data: make(map[string]string),
  }
}

func (m *smap) Get(k string) string {
  m.Lock()
  defer m.Unlock()

  return m.data[k]
}
```

为私有类型或需要实现互斥接口的类型嵌入



```go
type SMap struct {
  mu sync.Mutex // 对于导出类型，请使用私有锁

  data map[string]string
}

func NewSMap() *SMap {
  return &SMap{
    data: make(map[string]string),
  }
}

func (m *SMap) Get(k string) string {
  m.mu.Lock()
  defer m.mu.Unlock()

  return m.data[k]
}
```

对于导出类型，使用专用字段。

### 在边界处拷贝Slices和Maps

slice 和map 包含了指向底层数据的指针。

#### 接收slice和map

当map或slice 作为函数参数传入时，若存储了对它们的引用，则user可以对齐进行修改。

```go
func (d *Driver) SetTrips(trips []Trip) {
  d.trips = trips
}

trips := ...
d1.SetTrips(trips)

// 修改 d1.trips ？   error
trips[0] = ...
```



```go
func(d *Driver)SetTrips(trips []Trip){
    d.trips=make([]Trip,len(trips))
    copy(d.trips,trips)
}

trips := 
d1.SetTrips(trips)

// 此处修改trips 不会影响到 d1.trips
trips[0]= 
```

### channel 的size

cahnnel size通常为1或者无缓冲， 默认情况下是无缓冲的，

```go
//  缓冲
c:=make(chan int,1)
//  无缓冲
c:= make(chan int)
```

### 枚举

Go中通过声明一个自定义类型和一个使用了 iota 的 const 组来引入枚举。 由于变量默认值为`0`,通常应以**非零值**开头枚举。

```go
type  a int

const {
	A a=iota
	B 
	C
}
```

使用这种方式声明的枚举，A的初始值为0，B、C 依次递增。

```go
type  a int

const {
	A a=iota+1
	B 
	C
}
```

如此声明的话  A  为1 ， B、C 依次递增。

### time表示时间

#### `time.Time` 表示瞬时时间

处理时间的瞬间时使用`time.time` 在比较、添加或减去时间时使用`time.Time`中的方法

```go
func fa(now,start,end int) bool{
	return start<=now && now<end	
}   //  fa()  并未真正实现了时间的对比，这种方法并不可取
```

```go
func fb(now,start,end int)bool{
    return (start.Before(now)||start.Equal(now))&& now.Before(end)
}
```

在一个时间瞬间上加上24h

```go
tomorrow:=t.AddDate(0,0,1)  //  args: 0  years   0 months   1 days
// 获取下一个日历日的同一时间点  使用 time.AddDate
```

```go
newd:= t.Add(24*time.Hour)   
//  保证某一时刻比前一时刻晚24h
```



### 使用`time.Duration`表达时间段

`time.Duration` 处理时间段时使用

```go
func pool(delay int){
    for{
        time.sleep(time.Duration(delay)*time.Millisecond)
    }
} //  time.Duration 间隔模棱两可
```



```go
func fb(delay time.Duration){
    for{
        time.sleep(delay)
    }
}
fb(10*time.Second)  // 间隔10s
```

#### 对外部系统使用`time.Time` 和`time.Duration`

尽可能在与外部系统的交互中使用`time.Duration` 和`time.Time`:

- Command-line 标志： `flag`通过 `time.ParseDuration`支持`time.Duration`
- JSON: `encoding/json` 通过`UnmarshallJSON` 方法支持将`time.Time` 编码为RFC 3339字符串
- SQL :  `database/sql` 支持将`DATETIME` 或`TIMESTAMP` 列表转换为`time.Time`，如果底层驱动程序支持则返回。
- YAML： `gopkg.in/yaml.v2` 支持将`time.Time`作为RFC 3339字符串 并通过`time.ParseDuration`支持 `time.Duration`

当不能在这些交互中使用`time.Duration`时，使用`int` 或`float` 并在**字段名称中包含单位。**

```go
type Config struct{
    IntervalMillis int `json:"intervalMillis"`	
}
// {"intervalMillis":1000}
```

### 错误类型

Go中有多种声明错误的选项：

1.  `errors.New` 简单静态字符串的错误
2. `fmt.Errorf` 格式化的错误字符串
3. 实现`Error()` 方法的自定义类型
4. 用`"pkg/errors".Wrap` 的Wrapped errors

返回错误时，根据不同的情况选择 不同的错误方法：

- 对于不需要额外信息的简单错误   `errors.New` 
- 对于需要检测并且处理此错误  使用自定义类型并实现该`error()`方法
- 需要传播的错误
- 最后则是 `fmt.Errorf`

```go
// package foo

var ErrCouldNotOpen = errors.New("could not open")

func Open() error {
  return ErrCouldNotOpen
}

// package bar

if err := foo.Open(); err != nil {
  if err == foo.ErrCouldNotOpen {
    // handle
  } else {
    panic("unknown error")
  }
}
```

```go
type errNotFound struct {
  file string
}

func (e errNotFound) Error() string {
  return fmt.Sprintf("file %q not found", e.file)
}

func open(file string) error {
  return errNotFound{file: file}
}

func use() {
  if err := open("testfile.txt"); err != nil {
    if _, ok := err.(errNotFound); ok {
      // handle
    } else {
      panic("unknown error")
    }
  }
}
```

直接导出自定义错误类型时 需要注意， 其已成为程序包公共API的一部分，建议公开匹配器功能以检查错误。

```go
// package foo

type errNotFound struct {
  file string
}

func (e errNotFound) Error() string {
  return fmt.Sprintf("file %q not found", e.file)
}

func IsNotFoundError(err error) bool {
  _, ok := err.(errNotFound)
  return ok
}

func Open(file string) error {
  return errNotFound{file: file}
}

// package bar

if err := foo.Open("foo"); err != nil {
  if foo.IsNotFoundError(err) {
    // handle
  } else {
    panic("unknown error")
  }
}
```

#### 错误包装 (error Wrapping)

一个方法调用失败时，有三种主要的错误传播方式：

- 若没有添加其他上下文，并且想要维护原始错误类型，则返回原始错误
- 添加上下文，使用`“pkg/errors”.Wrap` 便于错误消息提供更多上下文  `“pkg/errors”.Cause` 提取原始错误。
- 如果调用者不需要检测或处理的特定错误情况，使用`fmt.Errorf`

在将上下文添加到返回的错误时，请避免使用“failed to”之类的短语以保持上下文简洁，这些短语会陈述明显的内容，并随着错误在堆栈中的渗透而逐渐堆积：

```go
s,err:=Store.New()
if err!=nil{
    return fmt.Errorf(
        "new store:%s",err
    )
}
```

#### 处理类型断言失败

```go
t,ok:=type.(T)
if !ok{...}
```

#### no panic

在生产环境中运行的代码必须避免出现 panic。如果发生错误，该函数必须返回错误，并允许调用方决定如何处理它。

```go
func run(args []string) error {
  if len(args) == 0 {
    return errors.New("an argument is required")
  }
  // ...
  return nil
}

func main() {
  if err := run(os.Args[1:]); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}
```

panic/recover 不是错误处理策略。仅当发生不可恢复的事情（例如：nil 引用）时，程序才必须 panic。程序初始化是一个例外：程序启动时应使程序中止的不良情况可能会引起 panic。

### 避免使用`init()`

尽可能避免使用`init()`。当`init()`是不可避免或可取的，代码应先尝试：

- 无论程序环境或调用如何，都要完全确定。
- 避免依赖于其他`init()`函数的顺序或副作用。虽然`init()`顺序是明确的，但代码可以更改， 因此`init()`函数之间的关系可能会使代码变得脆弱和容易出错。
- 避免访问或操作全局或环境状态，如机器信息、环境变量、工作目录、程序参数/输入等
- 避免`I/O`，包括文件系统、网络和系统调用。

### 追加时优先指定切片的容量

在尽可能的情况下，在初始化要追加的切片时为`make()`提供一个容量值。

```go
for n := 0; n < b.N; n++ {
  data := make([]int, 0, size)
  for k := 0; k < size; k++{
    data = append(data, k)
  }
}
```

### 优先使用strconv 而不是fmt

使用原语转为字符串或从字符串转换时，`strconv` 速度快于`fmt`

```go
for i := 0; i < b.N; i++ {
  s := strconv.Itoa(rand.Int())
}
```

### 避免字符串到字节的转换

不要反复从固定字符串创建字节 slice。相反，请执行一次转换并捕获结果。

```go
data := []byte("Hello world")
for i := 0; i < b.N; i++ {
  w.Write(data)
}
```



