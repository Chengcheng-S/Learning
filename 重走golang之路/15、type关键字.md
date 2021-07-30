# type

一、定义类型：

1. 定义结构体  

   ```GO
   type name  struct{
   	filed  T
   	filed  T
   }
   ```

2. 定义接口类型

   ```go
   type name interface{//}
   ```

3. 定义新类型     **声明新类型之后，他不会继承原有类型的方法集**

   ```go
   type name T
   ```

4. 定义函数类型

   ```gp
   type  name func(int)int
   ```

二、类型别名：

type name=T

三、非本地类型不能定义方法：

重新添加某个包名下的方法

1. ```name
   type name time.Duration
   func(m name)SimpleSet(){ ......  }
   ```

2. ```go
   在time包下重写这个Duration方法
   	type name time.Duration
   ```

四、结构体成员嵌入式使用别名
