# GO中的LOOP

go只有一种循环结构：`for`循环，由三部分组成

1. 初始化语句：第一次迭代前执行
2. 条件表达式： 在每次迭代前求值
3. 后置语句： 在每次迭代的结尾执行

初始化语句通常为依据短变量声明，该变量声明仅在for语句的作用域中可见，一旦for的布尔值为`false`将结束循环

注： 不同于其他的编程语言，Go中的for语句后面的三个构成部分外没有小括号，大括号则是必须的

例

```go
for i := 0; i < 10; i++ {
		//do something
	}
	fmt.Println(sum)
```

初始化语句和后置语句是可选的。

```go
for ; sum < 1000; {
		sum += sum
	}
```

Go中的"while"

当for语句中没有了分号，就变成了所谓的while循环了

```go
for sum < 1000 {
		sum += sum
	}
```

无限循环

省略了循环条件，循环则变为了无限循环

```go
for{
	i++
}
```



## IF

Go中`if`语句和for类似，表达式外无需小括号 `( )` ，而大括号 `{ }` 则是必须的。

```go
if x < 0 {
		do somet
	}
```



同 `for` 一样， `if` 语句可以在条件表达式前执行一个简单的语句。

该语句声明的变量作用域仅在 `if` 之内。在 `if` 的简短语句中声明的变量同样可以在任何对应的 `else` 块中使用。

## Switch

`switch` 是编写一连串 `if - else` 语句的简便方法。它运行第一个值等于条件表达式的 case 语句。

Go 的 switch 语句类似于 C、C++、Java、JavaScript 和 PHP 中的，不过 Go 只运行选定的 case，而非之后所有的 case。 实际上，Go 自动提供了在这些语言中每个 case 后面所需的 `break` 语句。 除非以 `fallthrough` 语句结束，否则分支会自动终止。 Go 的另一点重要的不同在于 switch 的 case 无需为常量，且取值不必为整数。switch 的 case 语句从上到下顺次执行，直到匹配成功时停止。

```go
today := time.Now().Weekday()
	switch time.Saturday {
	case today + 0:
		fmt.Println("Today.")
	case today + 1:
		fmt.Println("Tomorrow.")
	case today + 2:
		fmt.Println("In two days.")
	default:
		fmt.Println("Too far away.")
	}
```

没有条件的 switch 同 `switch true` 一样。

这种形式能将一长串 if-then-else 写得更加清晰。

```go
t := time.Now()
	switch {
	case t.Hour() < 12:
		fmt.Println("Good morning!")
	case t.Hour() < 17:
		fmt.Println("Good afternoon.")
	default:
		fmt.Println("Good evening.")
	}
```





