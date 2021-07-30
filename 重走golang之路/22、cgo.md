# cgo

CGO

```go
package main

//#include<stdio.h>
import"C"

func main(){
    str:="this is go=====>C"
	C.puts(C.CString(str))
}
```

通過`import "C"`,啓用CGO的特性，go build命令會在編譯和鏈接階段啓動gcc編譯器。

包含Clang的<stdio.h>頭文件，通過cgo下的C.CString函數將go字符轉爲C的字符串，最後通過C.puts輸出

注：將C代碼寫入到`/**/ 和//`   import"C"和c代碼之間不能有空行

## 自定義C函數

```go
package  mian

/*
#incude<stdio.h>
static void SayHello(const char*s){
	puts(s);
}
*/
import "C"

func main(){
	C.puts(C.CString("hello,\n"))

	
    // 自定義c函數
	C.SayHello(C.CString("自定義C函數"))
}
```

注：若之前運行的命令是`go run hello.go` 或`go build hello.go` 的話，次數必須使用 `go run .`  或	`go build .`

CGO 不止用于golang中调用C函数，也可以导出C函数给C语言调用
抽象 一个hello.h的模块，全部接口函数都在hello.h文件定义
void  SayHello(/*const*/ char* s);



```go
import "C"

//export SayHello   将golang实现的sayhello函数导出为c语言函数
func sayhello(s *C.char){
	fmt.Println(C.CString(s))
}
通过面向C语言接口的编程技术，简化函数的使用，可以将sayhello当作一个标准库的函数使用
package main
//#include<hello.h>
import "C"
func main(){
	C.SayHello(C.CString("go——>c\n"))
}
```



## 面向C接口的GO编程



### CGO基础

import "C" 表示CGO 启用 上边的注释中包含C的语句，确保在CGO的前提下，可以在当前目录中包含c/c++源文件



## 类型转换

在Go语言中访问C语言的符号时，一般是通过虚拟的“C”包访问，比如C.int对应C语言的int类型

### Go字符串切片

在CGO生成的_cgo_export.h头文件中还会为Go语言的字符串、切片、字典、接口和管道等特有的数据类型生成对应的C语言类型：

### 结构体、联合、枚举类型

C语言的结构体、联合、枚举类型不能作为匿名成员被嵌入到Go语言的结构体中。在Go语言中，我们可以通过C.struct_xxx来访问C语言中定义的struct xxx结构体类型
若c struct中的成员名称为go的关键字可以使用_name的方式进行访问

C语言结构体中位字段对应的成员无法在Go语言中访问，如果需要操作位字段成员，需要通过在C语言中定义辅助函数来完成。对应零长数组的成员，无法在Go语言中直接访问数组的元素，但其中零长的数组成员所在位置的偏移量依然可以通过unsafe.Offsetof(a.arr)来访问。



联合类型使用C.union_name 访问，go不支持联合类型，将转为对应大小的字节数组。
在golang中操作联合类型
1、定义辅助函数
2、使用"encoding/binary"手工解码成员
3、使用unsafe强制转换为对应的类型

```go
union B {
	int i;
	float f;
};
fmt.Println("b.i:", *(*C.int)(unsafe.Pointer(&b)))
	fmt.Println("b.f:", *(*C.float)(unsafe.Pointer(&b)))
```

### 枚举类型使用C.enum_name 进行访问

在C语言中，枚举类型底层对应int类型，支持负数类型的值。我们可以通过C.ONE、C.TWO等直接访问定义的枚举值

数组、字符串和切片
C.CString针对输入的Go字符串，克隆一个C语言格式的字符串；返回的字符串由C语言的malloc函数分配，不使用时需要通过C语言的free函数释放

C.CBytes函数的功能和C.CString类似，用于从输入的Go语言字节切片克隆一个C语言版本的字节数组，同样返回的数组需要在合适的时候释放。

C.GoString用于将从NULL结尾的C语言字符串克隆一个Go语言字符串。

C.GoStringN是另一个字符数组克隆函数。

C.GoBytes用于从C语言数组，克隆一个Go语言字节切片。

本质：
当Go语言字符串和切片向C语言转换时，克隆的内存由C语言的malloc函数分配，最终可以通过free函数释放。当C语言字符串或数组向Go语言转换时，克隆的内存由Go语言分配管理。


在C语言中可以通过GoString和GoSlice来访问Go语言的字符串和切片。如果是Go语言中数组类型，可以将数组转为切片后再行转换。如果字符串或切片对应的底层内存空间由Go语言的运行时管理，那么在C语言中不能长时间保存Go内存对象。

### 指针间的转换

在Go语言中两个指针的类型完全一致则不需要转换可以直接通用。如果一个指针类型是用type命令在另一个指针类型基础之上构建的，换言之两个指针底层是相同完全结构的指针，那么我我们可以通过直接强制转换语法进行指针间的转换。
go禁止两个非同类型指针相互转换
cgo两个不同类型的指针间的相互转换

```go
var p *X
var q *Y

q = (*Y)(unsafe.Pointer(p)) // *X => *Y
p = (*X)(unsafe.Pointer(q)) // *Y => *X
```

为了实现X类型指针到Y类型指针的转换，我们需要借助unsafe.Pointer作为中间桥接类型实现不同类型指针之间的转换。unsafe.Pointer指针类型类似C语言中的void*类型的指针。

任何类型的指针都可以通过强制转换为unsafe.Pointer指针类型去掉原有的类型信息，然后再重新赋予新的指针类型而达到指针间的转换的目的



### 数值和指针的转换

Go语言禁止将数值类型直接转为指针类型
Go语言针对unsafe.Pointr指针类型特别定义了一个uintptr类型。我们可以uintptr为中介，实现数值类型到unsafe.Pointr指针类型到转换。再结合前面提到的方法，就可以实现数值和指针的转换了



首先是int32到uintptr类型，然后是uintptr到unsafe.Pointr指针类型，最后是unsafe.Pointr指针类型到*C.char类型。



### 切片间的相互转换

```go
var p []X
var q []Y

pHdr := (*reflect.SliceHeader)(unsafe.Pointer(&p))
qHdr := (*reflect.SliceHeader)(unsafe.Pointer(&q))

pHdr.Data = qHdr.Data
pHdr.Len = qHdr.Len * unsafe.Sizeof(q[0]) / unsafe.Sizeof(p[0])
pHdr.Cap = qHdr.Cap * unsafe.Sizeof(q[0]) / unsafe.Sizeof(p[0])
```



## 函數調用

函数是C语言编程的核心，通过CGO技术我们不仅仅可以在Go语言中调用C语言函数，也可以将Go语言函数导出为C语言函数。

### GO調用C函數

对于一个启用CGO特性的程序，CGO会构造一个虚拟的C包。通过这个虚拟的C包可以调用C语言函数。

```go
/*
static int add(int a, int b) {    
	return a+b;
}
*/
import "C"

func main() {
	C.add(1, 1)
}
```

定義了一個在文件中可見的add函數，接著通過C.add進行調用

### C函數的返回值

```go
/*
static int div(int a, int b) {
	return a/b;
}
*/
import "C"
import "fmt"

func main() {
	v := C.div(6, 3)
	fmt.Println(v)
}
```

對於有返回值的C函數，可以直接獲取其值，由於C函數不支持多返回值，但是又想排除輸入的除數爲零的情況，這時需要引入`<errno.h>`標準庫提供的一個`errno`宏用於表示錯誤的狀態，将`errno`看着一个线程安全的全局变量，可以用于记录最近一次错误的状态码。

go語言也針對`errno`做了特殊的支持，在CGO调用C函数时如果有两个返回值，那么第二个返回值将对应`errno`错误状态。

```go
/*
#include<errno.h>

int div(int a,int b){
	if (b==0){
		errno=EINVAL;
		return 0;
	}
	return a/b;
}
*/
import "C"
import "fmt"

func main(){
    v,err:=C.div(2,1)
    fmt.Println(v,e)
}
```

## void函數返回值



C语言函数还有一种没有返回值类型的函数，用void表示返回值类型。一般情况下，我们无法获取void类型函数的返回值，因为没有返回值可以获取。之前，cgo对errno做了特殊处理，可以通过第二个返回值来获取C语言的错误状态。对于void类型函数，这个特性依然有效。

```go
//static void noreturn() {}
import "C"
import "fmt"

func main() {
	_, err := C.noreturn()
	fmt.Println(err)
}
```

`err` 表示，對應的錯誤碼，第一個參數則是C語言void對應的go的類型



## C調用GO導出函數



CGO还有一个强大的特性：将Go函数导出为C语言函数。这样的话我们可以定义好C语言接口，然后通过Go语言实现。

```go
import"C"

//export add
func add(a,b C.int)C.int{
	return a+b
}
```

add函数名以小写字母开头，对于Go语言来说是包内的私有函数。但是从C语言角度来看，导出的add函数是一个可全局访问的C语言函数。如果在两个不同的Go语言包内，都存在一个同名的要导出为C语言函数的add函数，那么在最终的链接阶段将会出现符号重名的问题。

## 内部機制

CGO的特性主要是通過CGO的命令行工具來輔助輸出go和c之間的橋接程序

### CGO生成的中間文件

在構建cgo包時增加`-work`,輸出中間文件所在的目錄，并且在構建完成是保留中間文件。   較簡單額cgo程序可以通過 `go tool cgo`查看生成的中間文件

下圖爲CGO生成中間文件的示意圖

![img](https://img.cntofu.com/book/advanced-go-programming-book/images/ch2-cgo-generated-files.dot.png)

包中有4个Go文件，其中nocgo开头的文件中没有`import "C"`指令，其它的2个文件则包含了cgo代码。cgo命令会为每个包含了cgo代码的Go文件创建2个中间文件，比如 main.go 会分别创建 main.cgo1.go 和 main.cgo2.c 两个中间文件。然后会为整个包创建一个 `_cgo_gotypes.go` Go文件，其中包含Go语言部分辅助代码。此外还会创建一个 `_cgo_export.h` 和 `_cgo_export.c` 文件，对应Go语言导出到C语言的类型和函数。

### GO調用C函數

```go
package main

//int sum(int a, int b) { return a+b; }
import "C"

func main() {
	println(C.sum(1, 1))
}
```

```
go tool cgo main.go
```

### C調用GO函數

```go
package main

//int sum(int a, int b);
import "C"

//export sum
func sum(a, b C.int) C.int {
	return a + b
}

func main() {}
```

爲了在c中使用該函數，需要將Go編譯為一個C的靜態庫

```
$ go build -buildmode=c-archive -o sum.a sum.go
```

以上编译命令将生成一个`sum.a`静态库和`sum.h`头文件。其中`sum.h`头文件将包含sum函数的声明，静态库中将包含sum函数的实现。









































