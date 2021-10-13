

# IO

## 打开模式

```
fileMode=enum
 fmRead,               // 只读
 fmWrite               // 只写
 fmReadWrite			// 读写，不存在时创建
 fmReadWriteExisting     // 读写，不能存在是不创建
 fmAppend				// 末尾追加数据
```

## 读文件

```
var file:File 
file=open(r"C:\Users\师琤琤\Desktop\docker\base.txt")
# echo file.readChar()    读取一个字符

# 读取所有的内容，默认为只读模式
# echo file.readAll()


#  读取一行文本
# echo file.readLine()

# 返回文件字节
# echo file.getFileSize()
```



```
file=open(r"C:\Users\师琤琤\Desktop\docker\one.txt",fmreadWrite)
//fmreadWrite 文件不存在时创建文件，如果存在则清空文件的内容

echo file.readAll()
```

## 写文件

```
file=open(r"C:\Users\师琤琤\Desktop\docker\one.txt",fmWrite)

file.write("this is nim IO write to one.txt")
file.close()
```

fmWrite 打开文件，**写入的内容覆盖之前的内容**

```
file = open(r"E:\Nim\write.txt",fmAppend)       #打开文件，写入的内容添加到最后面。
file.write("\n")
file.write("How are you")
file.close()
```

## 直接写入文件

```
var content:string
var filename=r"C:\Users\师琤琤\Desktop\docker\one.txt"
content="\n this is second message that nim's io write to one.txt"

writeFile(filename,content)

echo readFile(filename)
```

## 标准输入流

```
echo "what's the name ?"
var name:string=readLine(stdin)
echo $name,"hello "
```

## 标准输出流

```
proc p2(f:File,a:varargs[string,`$`]) =
    for s in items(a):
        write(f,s)
        write(f,"\n")
    write(f,"\n")
p2(stdout,123,"asd",8520)        
```

## open过程签名

```
proc open*(f: var File, filename: string,
               mode: FileMode = fmRead, bufSize: int = -1): bool {.tags: [],
               benign.}
 
 
以`mod`的模式打开一个 filename文件， 默认的模式为只读
```

## reopen签名

```
proc reopen*(f: File, filename: string, mode: FileMode = fmRead): bool {.
      tags: [], benign.}
      
重新打开名为filename的文件，模式为mod。 常用于重定向    
```

## close签名

```
proc close*(f:File){.importc: "fclose", header: "<stdio.h>", tags: [].}
```

**关闭文件**

## endofFile

```
proc endOfFile*(f: File): bool {.tags: [], benign.}
```

如果以`f`结尾，将返回true

## readChar

```
proc readChar*(f: File): char {.
      importc: "fgetc", header: "<stdio.h>", tags: [ReadIOEffect].}
```

**从文件中读取一个字符**

## flushFile

```
proc flushFile*(f: File) {.
      importc: "fflush", header: "<stdio.h>", tags: [WriteIOEffect].}
```

**刷新缓冲区**

## readAll

```
proc readAll*(file: File): TaintedString {.tags: [ReadIOEffect], benign.}
```

**从文件中读取全部内容**

## readFile

```
proc readFile*(filename: string): TaintedString {.tags: [ReadIOEffect], benign.}
```

**读取文件的内容，之后调用readAll，然后关闭文件**

编译时调用这个宏可以使用`staticRead <#staticRead>`_.

## writeFile

```
proc writeFile*(filename, content: string) {.tags: [WriteIOEffect], benign.}
```

**将content写入到file中**

## readLine

```
proc readLine*(f: File): TaintedString  {.tags: [ReadIOEffect], benign.}
```

**从文件中读取一行，一行文本可能被回车、换行或者回车换行界定，换行符不是返回字符串的一部分**

- line不能时nil，
- 如果已经到了文件末尾，将返回false，否则true
- 如果fasle被返回，则line没有包含新数据

## writeln

```
proc writeln*[Ty](f: File, x: varargs[Ty, `$`]) {.inline,
                             tags: [WriteIOEffect], benign.}
```

在文件中写入x，然后写入‘\n’

## getFileSize

```
proc getFileSize*(f: File): int64 {.tags: [ReadIOEffect], benign.}
```

检索文件的大小(以字节为单位)

## readBytes

```
proc readBytes*(f: File, a: var openArray[int8|uint8], start, len: Natural): int {.
      tags: [ReadIOEffect], benign.}
```

```
Natural* = range[0..high(int)]
```

读取`len`字节到`a`的缓冲区,返回实际读取的字节数，它可能比`len`小,不可能比它大

## readChars

```
proc readChars*(f: File, a: var openArray[char], start, len: Natural): int {.
      tags: [ReadIOEffect], benign.}
```

读取`len`字节到 `a` 缓冲区，从 ``a[start]``开始

## readBuffer

```
proc readBuffer*(f: File, buffer: pointer, len: Natural): int {.
      tags: [ReadIOEffect], benign.}
```

**pointer*{.magic:Pointer.}**内置指针类型，使用addr操作可以得到一个指针变量

读取`len`字节到`buffer`指定的缓冲区

## writeBytes

```
proc writeBytes*(f: File, a: openArray[int8|uint8], start, len: Natural): int {.
      tags: [WriteIOEffect], benign.}
```

写入字节到文件

## writeChars

```
proc writeChars*(f: File, a: openArray[char], start, len: Natural): int {.
      tags: [WriteIOEffect], benign.}
```

写入字节到文件

## writeBuffer

```
proc writeBuffer*(f: File, buffer: pointer, len: Natural): int {.
      tags: [WriteIOEffect], benign.}
```

把参数 `buffer` 指向的缓冲区中`len`字节写到文件`f`中。返回实际写入的字节数，如果出现错误它可能比`len`小。

## setFilePos

```
proc setFilePos*(f: File, pos: int64) {.benign.}
```

设置用于读/写操作的文件指针的位置，文件的第一个字节的索引为0

## getFilePos

```
proc getFilePos*(f: File): int64 {.benign.}
```

检索用于读取文件f指针的当前位置，文件的第一个字节索引为0

## getFileHandle

```
proc getFileHandle*(f: File): FileHandle {.importc: "fileno",header: "<stdio.h>"}
```

返回文件f的操作系统句柄，进队忒的那个的编程平台有用







