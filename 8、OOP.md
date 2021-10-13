# OOP

Nim 支持面向对象编程(OOP)是极简单的，并且可以使用强大的OOP技术。OOP被视为一种方法设计一个程序，而非唯一方法。通常一个过程式的方法会导致更简单高效的代码。特别的，优先使用对象组合，而非（类）继承（面向对象的设计法则）

对象：像元素一般是一种结构体化的方式把不同的值包装在一起。然而对象提供了更多元素没有的属性：继承和隐藏，因为对象封装数据，**T()对象构造函数应仅被定义在内部(构造器)，**在运行时对象可以访问他们的类型，**`of`操作符，用来检查对象的类型。**

```python
type
  Person= ref object of RootObj
  name*:string
  age:int
  Student= ref object of Person
     id:int
  
var 
  stu:Student
  per:Person
assert(stu of Student)   // is true

// 对象构造
student=Student(name:"jhon",age:18,id:17)
echo stu[]
```

对象域对外是可见的，**模块不得不用`*`标记，与元组相比，不同对象类型是从不会相等的。新的对象只能被定义在type部分内**

## 继承

**继承使用object of 语法**，如果一个对象没有合适的祖先，**RootObj可以作为它的祖先**，但 这只是一个约定。没有祖先的对象是隐藏的final，可以使用`inheritable`编译指示来产生一个除了来自system.RootObj之外的根对象

**每当使用继承时应使用`ref`对象**，他不是绝对必要的，但是用非`ref`对象赋值

```
let person:Person=Student(id:123)//  将截断子类域
```

注意：如果使用非ref 对象，用person：Person = Student(name:”mm”,age:22,id:123) 赋值语句，会编译出错，类型不对。

如果使用ref对象，会截断id域， echo person 为（name:”mm”, age: 5)。与上面说的不同。

组合(has-a)往往优于继承(is-a)对于简单的代码重用，由于在nim中对象是一种值类型，组合和继承一样高效。注：(引用类型(重量级对象)和值类型(轻量级对象))

### 相互递归类型

对象，元组和引用可以塑造相当复杂的数据结构相互依赖彼此;他们是相互递归的。在nim中这些类型只能在一个的那一的type部分声明 (其他任何需要任意前端符号会减慢编辑)

```python
type
  Node= ref NodeObj    // 一个nodeobj的跟踪引用
  NodeObj= object
    le,ri:Node      //left and right 节点        
    sym: ref Sym    // 叶节点
  Sym= object
     name:string
     line:int
     code:Node
```

### 类型转换

nim区分显示的类型转换和隐式的类型，**显示类型转换用`casts`操作符并且强制编译器解释一种位模式成为另一种类型。**

隐式的类型转换是一个更礼貌的方式将一个类型转换位另一个：他们保存摘要值，不一定是位模式。如果一个类型转换是不可能的，编译器会控诉或者抛出一个异常。

类型转换语法：destination_type(expression_to_convert)目的类型(要转换的表达式)(像一个普通的调用)

```
proc getID(x:Person):int=
   Student(x).id
```

如果x不是一个Student类型，会抛出异常(“InvalidObjectConversionError”)

### 对象变体

通常一个对象层次结构在特定情况下，是不必要的，需要简单的变体类型

```
# This is an example how an abstract syntax tree could be modelled in Nim
type
  NodeKind = enum  # the different node types
    nkInt,          # a leaf with an integer value
    nkFloat,        # a leaf with a float value
    nkString,       # a leaf with a string value
    nkAdd,          # an addition
    nkSub,          # a subtraction
    nkIf            # an if statement
  Node = ref NodeObj
  NodeObj = object
    case kind: NodeKind  # the ``kind`` field is the discriminator
    of nkInt: intVal: int
    of nkFloat: floatVal: float
    of nkString: strVal: string
    of nkAdd, nkSub:
      leftOp, rightOp: Node
    of nkIf:
      condition, thenPart, elsePart: Node

var n = Node(kind: nkFloat, floatVal: 1.0)
# the following statement raises an `FieldError` exception, because
# n.kind's value does not fit:
n.strVal = ""
```

一个对象层次结构的一个优点是，不需要不同的对象类型之间的转换。然而，访问无效的对象域会引发一个异常。

### 方法

在普遍的面向对象程序语言中，过程(也叫方法)被绑定到一个类，

缺点：

- ·程序员无法控制添加一个方法到一个类中是不可能的或者需要丑陋的解决方法。
- ·很多情况下方法应该属于哪里是不清楚的：是加入一个字符串方法还是一个数组方法

nim通过部分配方法到一个类中避免这样的问题。所有的方法在nim中都是多方法

#### 方法调用语法

调用的语法是：obj.method(args) 而不是method(obj,args)

方法的调用不受对象的限制，可以被用于任何类型

```
import strutils

echo("abc".len) # is the same as echo(len("abc"))
echo("abc".toUpper())
echo({'a', 'b', 'c'}.card)
stdout.writeln("Hallo") # the same as writeln(stdout, "Hallo")
```

**nim没必要get-properities:通常get-procedures被称为方法调用语法实现相同的功能。但是设定一个值是不一样的，这需要一个特殊的setter语法**

```
type
  Socket* = ref object of RootObj
    FHost: int # 在其他的外部模块不能调用 FHost。
               # ‘F’ 前缀是一个避免冲突的表识约定，因为函数的名字叫做 ‘hoat'。
               
proc `host=`*(s: var Socket, value: int) {.inline.} =
  ## setter of hostAddr
  s.FHost = value

proc host*(s: Socket): int {.inline.} =
  ## getter of hostAddr
  s.FHost

var s: Socket
new s
s.host = 34  # same as `host=`(s, 34)
echo s.host() 
```

### 动态分配

**动态分配使用关键字method**来代替proc

```
type
  PExpr = ref object of RootObj ## abstract base class for an expression
  PLiteral = ref object of PExpr
    x: int
  PPlusExpr = ref object of PExpr
    a, b: PExpr

# watch out: 'eval' relies on dynamic binding
method eval(e: PExpr): int =
  # override this base method
  quit "to override!"

method eval(e: PLiteral): int = e.x
method eval(e: PPlusExpr): int = eval(e.a) + eval(e.b)

proc newLit(x: int): PLiteral = PLiteral(x: x)
proc newPlus(a, b: PExpr): PPlusExpr = PPlusExpr(a: a, b: b)

echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))
```

在例子中，构造器newLit和newPlus是过程，因为对于它们使用静态绑定更有意义，但是eval是一个方法因为它需要动态绑定。

内联约定调用者不应该调用这个程序，而是直接内联它的代码。注意，Nim 不能内联，但是离开Nim到C编译器：它生成 __inline 程序。这只是一个提示对于编译器：它可能完全忽视它,它可能会内联程序不标记为内联。















