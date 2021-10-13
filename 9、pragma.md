# pragma

编译指示: 编译指示是Nim给编译器附加信息的方法/ 命令不引入大量的新关键词。编译指示是特别的用大括号和点标识的，如： {.and.}。

`{.   .}`

### deprecated pragma

deprecate 指示被用来标记为弃用

```
proc p(){.deprecated.}
var x{.deprecated.}:char
```

也可以在声明时使用，需要定义一个重命名列表

```
type
  File=object
  Stream=ref object
  {.deprecated:[TFile,File,PStream:Stream]
```

### noSideEffect pragma

无副作用指示，用于标记proc/iterator为 无副作用，在该函数里使用影响效率的函数或者修改某些内容就会出错，如echo

```
func `+`(x,y:int):int
```

**func可能成为无副作用函数的关键字或语法糖(就是说以后更新正式版可能会加入func这个关键字来声明无副作用函数.**

> 函数副作用：是指函数在正常工作任务之外对外部环境所施加的影响。
>
> ，函数副作用是指函数被调用，完成了函数既定的计算任务，但同时因为访问了外部数据，尤其是因为对外部数据进行了写操作，从而一定程度地改变了系统环境。函数的副作用也有可能是发生在函数运行期间，由于对外部数据的改变，导致了同步运行的外部函数受到影响
>
> 例如，调用函数时在被调用函数内部：
>
> ·修改全局量的值；
>
> ·修改主调用函数中声明的变量的值(一般通过指针参数实现)。

### procvar pragma

过程变量指示：标记一个函数，可以传递给一个过程变量

### compileTime pragma

标记的函数/变量技能在编译时使用，不会生成代码，辅助宏来使用

### noReturn pragma

标记的函数没有返回值

### discardable pragma

标记的函数可以不写返回这或者discard



### nolnit pragma

指示的变量不会初始化指示

### requireslnit pragma

指示的变量需显式初始化

```
type 
  myObject=object {.requireslnit.}
proc p()=
  var x:myObject
  if someCondition():
      x=a()
  else:
      x=b()
  use x   
```

### acyclic pragma

非周期指示：标记那些看起来周期循环(其实就是递归使用自身的类型)的object类型为非周期类型，主要是为了优化效率不让GC把这种类型的对象当循环周期部分来处理

```
type 
  Node=ref NodeObj
  NodeObj{.acyclic,final.}=object
      left,right:Node
      data:string
```

把node类型定义为一个树结构, 注意像这种定义为**递归的类型 GC会假设这种类型会形成一个周期图, 使用acyclic指示的话 GC将会无视它,** 

把acyclic指标用于真正的循环周期类型, GC将造成内存泄漏, 当然不会有其它更糟糕的情况

> acyclic 将成为ref类型属性

```
type
   Node=acyclic  ref NodeObj
   NodeObj=object
      left,right:Node
      data:string
```

### final pragma

该类型不可被继承

### shallow pragma

浅拷贝指示影响类型的语义让编译器允许浅拷贝，可能会导致严重的语义问题打破内存安全(优点则是快速、高效)，

因为nim的语义要求深拷贝序列(seq)和字符串(string)

```
type
   NodeKind=enum nkleaf,nkInner
   Node {.final, shallow.} = object
    case kind: NodeKind
    of nkLeaf:
      strVal: string
    of nkInner:
      children: seq[Node]
```

### pure pragma

抽象指示： 对象类型可以被抽象指示，以便该类型字段在运行时省略类型识别，也可**以标记一个enum，必须写完整才能访问其字段**

```
type
  MyEnum {.pure.} = enum
    valueA, valueB, valueC, valueD

echo valueA # 错误, 必须类型字段写完整.
echo MyEnum.valueA # 正确
```

### asmNoStackFrame pragma

无堆栈帧汇编指示： 函数可被标记，告诉编译器该函数不生成堆栈，也没有退出声明，如return返回值，其生成的函数为C语言的 **declspec(naked)或__attribute**((naked))属性函数(取决于使用的C语言编译器).

注：这个指示只能在该函数里使用汇编语句

### error pragma

使编译器输出一个错误的消息内容，使其在编译发生错误时不一定会终止，

error指示也可以用来标注一个符号(如一个迭代器或者函数)，如果使用符号则发出一个编译时错误，对于排除那些有效的重载和类型转换的操作是非常有用的

```
#### 如果使用这个函数就会弹出编译时错误.
proc `==`(x, y: ptr int): bool {.error.}
```

### fatal pragma

使编译器输出一个错误消息的内容**，相对于error指示，fatal指示放在何处何处就出错**

```
when not defined(object):
    {.fatal:"Compile this programming with the objetc command!".}
```



### warning pragma

使编译器输出一个**警告消息内容，警告后继续编译**

### hint pragma

使编译器输出一个**提示消息的内容，提示之后继续编译**

### line pragma

行指示：  影响注释语句在堆栈回溯跟踪时的可见信息

```
template myassert*(cond: expr, msg = "") =
  if not cond:
    # change run-time line information of the 'raise' statement:
    {.line: InstantiationInfo().}:
      raise newException(EAssertionFailed, msg)

```

如果行指示想使用参数，则参数需要为一个元组(tuple [filename:string,line:int])**,如果无参，则需使用，system.InstantiationInfo()函数.**

### linearScanEnd pragma

告诉编译器如何编译case语句，须在case语句里的声明：

```
case myint
of 0:
  echo "most command case"
of 1:
  {.linearScanEnd.}
  echo "second most common case"
of 2: echo "unlikely:use branch table"
else: echo "unlikely too: use branch table for",myint  
```

使用case语言里的某个分支使用了linearScanEnd指示就会让该分支之上所有分支的时间效率为O(1),

### computedGoto pragma

跳转计算指示： 告诉编译器在while循环里如何编译case语句，须在循环内声明。

```
type
  MyEnum = enum
    enumA, enumB, enumC, enumD, enumE

proc vm() =
  var instructions: array [0..100, MyEnum]
  instructions[2] = enumC
  instructions[3] = enumD
  instructions[4] = enumA
  instructions[5] = enumD
  instructions[6] = enumC
  instructions[7] = enumA
  instructions[8] = enumB
  
  instructions[12] = enumE
  var pc = 0
  while true:
    {.computedGoto.}
    let instr = instructions[pc]
    case instr
    of enumA:
      echo "yeah A"
    of enumC, enumD:
      echo "yeah CD"
    of enumB:
      echo "yeah B"
    of enumE:
      break
    inc(pc)

vm()
```

computedGoto非常适合作为解释器来使用, 如果使用的C语言编译器不支持跳转计算扩展功能 该指示将被忽略.

### immediate pragma

立即指示：  使模板不参与重载解析，可以在参数调用前不检查语义，所以可以接受未声明的标识符。

```
### 普通模板
template declareInt(x: expr) =
  var x: int

declareInt(x) # 错误: 未知的标识符: 'x'

###立即指示的模板
template declareInt(x: expr) {.immediate.} =
  var x: int

declareInt(x) # 正确
```

### compilation option pragmas

编译选项指示：可以覆盖proc/method/converter的代码生成选项

| 编译指示       | 可用值            | 描述                                                      |
| -------------- | ----------------- | --------------------------------------------------------- |
| checks         | on/off            | 代码生成时是否打开运行时检测                              |
| boundChecks    | on/off            | 代码生成时是否检测数组边界                                |
| overflowChecks | on/off            | 代码生成时是否检测下溢和溢出                              |
| nilChecks      | on/off            | 代码生成时是否检测nil指针                                 |
| assertions     | on/off            | 代码生成时断言是否生效                                    |
| warnings       | on/off            | 是否打开编译器的警告消息                                  |
| hints          | on/off            | 是否打开编译器的提示消息                                  |
| optimization   | none/speed/size   | 优化代码的速度或大小, 或关闭优化功能                      |
| patterns       | on/off            | 是否打开改写术语的模板和宏?                               |
| callconv       | cdecl/stdcall/... | 对所有的函数(proc)和函数类型(proc type)指定默认的调用协议 |

```
{.checks:off,optimization:speed.}
//  编译时不会进行运行时检测(checks)和速度优化(optimization)
```

### push and pop pragmas

推入/弹出指示： 该指示需要成对使用，功能类似于选项指示，作用是临时覆盖那些设置

```
{.push checks:off.}  // 保存旧的设置
// 编译push/pop区域内的代码时不进行运行时检测
///speed critical    
///  do something
{.pop.}   //恢复旧设置
```

### register pragma

寄存器指示： 只能用于变量，会声明一个寄存器变量 ，告诉编译器该变量应该使用硬件寄存器来提供更快得访问速度，在高度特定的情况下(例如字节码解释器的消息循环)可能会更有效率

### global pragma

 在函数(proc)里使用变量加上global指示可一直使用此变量, 该变量只会在程序运行时初始化一次.

```
proc  isHexNumber(s:string):bool=
    var pattern {.golbal.}=re"[0-9a-fA-F]+"
    reslut =s.match(pattern)
```

**注：每个函数里得golbal变量只是相对该函数是唯一得，其他函数里golbal变量同名不受影响**

### deadCodeElim pragma

死代码消除： 只应用于整个模块，告诉编译器是否对模块激活死代码消除功能，编译时加上`–`deadCodeElim:on时，所有得程序都有了死代码消除功能

```
{.deadCodeElim:on.}
```

### pragma pragma

pp指示：声明用户自定义得指示，这十分有用，因为模板和宏不会影响指示，他们不能从模块导入

```
when appType =="lib":
   {.pragma:rtl,export,dynlib,cdecl.}
else:
    {.pragma:rtl,importc, dynlib: "client.dll", cdecl.}
proc p*(a,b:int):int{.rtl.}=
    result=a+b
```

**被命名为rtl的指示可以从任意动态库中导入其中的符号(函数或变量)或为动态库生成导出符号.**

### Disabling certain messages

禁止某些消息

```
{.hint[LineTOOLong]:off.}  // 禁止太长得指示
```

### experimental  pargma

实验性指示

```
{.experimental.}

proc useUsing(dest: var string) =
  using dest
  add "foo"
  add "bar"
```



### Foregin function interface 

外部函数接口

### importc pragma

Clang导入指示 ，表示从外部文件导入符号(过程或变量)

```
proc printf(formatstr: cstring){.header: "<stdio.h>", importc: "printf", varargs.}
```

**上面是导入C语言的符号, 如果想导入C++的就是importcpp, objc的就是importobjc.**

### Export pragma 

Clnag导出指示：作为库导出符号

```
###fib.nim
proc fib(a: cint): cint {.exportc.} =
  if a <= 2:
    result = 1
  else:
    result = fib(a - 1) + fib(a - 2)
```

```
//maths.c
###include "fib.h"
###include <stdio.h>

int main(void)
{
  NimMain();
  for (int f = 0; f < 10; f++)
    printf("Fib of %d is %d\n", f, fib(f));
  return 0;
}
```

直接编译要加入nimcache目录：

```
> nim c --noMain --noLinking --header:fib.h fib.nim
> gcc -o m -Inimcache -Ipath/to/nim/lib nimcache/*.c maths.c
```

也可以编译成静态库给c/c++用, linux下可能要加-ldl

```
> nim c --app:staticLib --noMain --header fib.nim
> gcc -o m -Inimcache -Ipath/to/nim/lib libfib.nim.a maths.c
```

可以编译为js给html使用

```
<html><body>
<script type="text/javascript" src="fib.js"></script>
<script type="text/javascript">
alert("Fib for 9 is " + fib(9));
</script>
</body></html>
```



```
nim js -o:fib.js fib.nim
```

### Extern pargma

外部指示：类似于importc， export，extern指示会影响名字识别，字符串转给extern可以是格式化字符串

```
proc p(s: string) {.extern: "prefix$1".} =
  echo s
```

把p设为外部名`prefix$1`（1为参数），类似于wim得函数符号协议

### Bycopy pragma

被复制指示： 可应用于元素和对象，**通过编译器把类型得值转给函数**

### Byref pragma

Byref指示可应用于对象和元组, **通过编译器把该类型作为引用传给函数**.

### Varargs pragma

让使用得函数最后一个参数转为可变参数，这个函数使用得nim字符串会自动转为csrting

```
proc printf(formatstr: cstring) {.nodecl, varargs.}

printf("hallo %s", "world") # "world" 将转换为cstring
```



### Union pragma 

应用与任何对象类型,共享字段， 暂不支持GC和继承(目前有可能支持GC和内存控制)



### Packed pragma

应用于任何对象类型，确保对象的字段头尾相接连续保存在一段内存内, 这适用于网络包传输和硬件驱动, 封包指示目前还不能使用继承和GC管理内存. 未来发展的方向: 将支持继承, 如果封闭的内部有使用gc的话将会在编译时提示错误.

### Unchecked pragma

让数组不进行边界检查，要一个灵活大小却又不确定大小的数组时使用，

```
type
  ArrayPart{.unchecked.} = array[0..0, int]
  MySeq = object
    len, cap: int
    data: ArrayPart
```

无检测的数组类型没有GC内存管理.
未来的发展方向: 无检测的数组将支持GC内存管理.

### Dynlib pragma for import

**dynlib 指示可结合importc指示从动态链接库里导入符号等，(dll是win的， so是linux和unix的)**

```
proc gtk_image_new(): PGtkWidget
  {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}
```

支持版本控制

```
proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
  importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
```

动态库导入不仅支持常数字符串, 同样支持一般的字符串表达式.

```
import os

proc getDllName: string =
  result = "mylib.dll"
  if existsFile(result): return
  result = "mylib2.dll"
  if existsFile(result): return
  quit("could not load dynamic library")

proc myImport(s: cstring) {.cdecl, importc, dynlib: getDllName().}
```

**注意** 

- 像libtcl(|8.5|8.4).so只支持在常数字符串, 因为它是预编译.
- 动态初始化顺序的问题，运行时传递变量给指示将会失败
- 动态库可以被 **--dynlibOverride:name**命令行选项覆盖

### Dynlib pragma for export

动态库导出提示：  dynlib指示也能能把符号导出给他人使用, 该指示没有参数且必须结合exportc指示使用.

```
proc exportme(): int {.cdecl, exportc, dynlib.}
```

**动态库导出只在程序通过命令行选项 --app:lib 编译成动态链接库才有用.**

















