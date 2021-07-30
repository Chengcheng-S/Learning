# go vet

检查程序中的不规范的命名以及操作，GO vet file name 

即使检测出程序中不合理的地方‘



# GOlint

检查代码规范

golint filename  检测比go vet 较详细





# --race

检查是否有并发竞争

go run --race name.go



# 查看汇编代码

go tool compile -S  name.go



# 逃逸分析

`-gcflags "-N -l"` 是为了关闭编译器优化和函数内联，防止后面在设置断点的时候找不到相对应的代码位置。

go build -gcflags "-N -l" -o hello src/main.go

# 编译相关

## go build

`go build` 用来编译指定 packages 里的源码文件以及它们的依赖包，编译的时候会到 `$GoPath/src/package` 路径下寻找源码文件。`go build` 还可以直接编译指定的源码文件，并且可以同时指定多个。

```go
usage: go build [-o output] [-i] [build flags] [packages]
```

`-o` 只能在编译单个包的时候出现，它指定输出的可执行文件的名字

`-i`会**安装编译目标所以依赖的包**，安装是指生成与代码包相对应的`.a`文件，即**静态库文件**(参与**链接**)，并放置到当前工作区的pkg目录下，且**库文件的目录层级和源码层级一致**。

build flags  (build clean get install list run test 共用一套)

| 参数  | 作用                                                         |
| :---- | :----------------------------------------------------------- |
| -a    | 强制重新编译所有涉及到的包，包括标准库中的代码包，这会重写 /usr/local/go 目录下的 `.a` 文件 |
| -n    | 打印命令执行过程，不真正执行                                 |
| -p n  | 指定编译过程中命令执行的并行数，n 默认为 CPU 核数            |
| -race | 检测并报告程序中的数据竞争问题                               |
| -v    | 打印命令执行过程中所涉及到的代码包名称                       |
| -x    | 打印命令执行过程中所涉及到的命令，并执行                     |
| -work | 打印编译过程中的**临时文件夹**。通常情况下，编译完成后会被**删除** |

go的源文件分为三类：

- 命令源码文件：Go的入口，包含main()函数，文件开始声明package main 隶属于main包
- 库源码文件： 各种函数、接口等，如工具类函数
- 测试源文件：以`_test.go`为后缀的文件，用于测试程序的功能和性能。

注：go build 不会编译测试源文件。go build 命令在编译只包含库源码文件的代码包（或者同时编译多个代码包）时，只会做检查性的编译，而不会输出任何结果文件。

## go install 

用于**编译并安装指定的代码包**以及他们的**依赖包**。比go build多一个安装编译后的结果文件到指定目录的步骤。

```go
go install src/main.go
或者
go install util
```



## go run

编译并运行命令源码文件

```
go run -x -work src/main.go
```

## go pprof

pprof 分析性能、分析数据的工具，PProf用profile.proto读取分析样本的集合，并生成可视化报告，以帮助分析数据(支持文本和图形)

采样方式：

- runtime/pprof: 采集程序（非Server）指定区块的运行数据进行分析
- net/http/pprof: 基于HTTP Server运行，并且可以采集运行时的数据进行分析
- go test：通过运行测试用例，指定所需标识进行采集

使用模式：

- Report Generation：报告生成
- Interactive Terminal Use：交互式终端使用
- Web Interface：Web 界面

用途：

- CPU Profilng
- Memory Profiling
- Block Profiling
- Mutex Profiling

基于HTTP Server运行 必须引入

```go
import{
_"net/http/profile"
}
```

浏览器输入 端口号/pprof

```
/debug/pprof/

Types of profiles available:
Count	Profile
0	allocs
0	block
0	cmdline
5	goroutine
0	heap
0	mutex
0	profile
7	threadcreate
0	trace
full goroutine stack dump
Profile Descriptions:

allocs: A sampling of all past memory allocations
block: Stack traces that led to blocking on synchronization primitives
cmdline: The command line invocation of the current program
goroutine: Stack traces of all current goroutines
heap: A sampling of memory allocations of live objects. You can specify the gc GET parameter to run GC before taking the heap sample.
mutex: Stack traces of holders of contended mutexes
profile: CPU profile. You can specify the duration in the seconds GET parameter. After you get the profile file, use the go tool pprof command to investigate the profile.
threadcreate: Stack traces that led to the creation of new OS threads
trace: A trace of execution of the current program. You can specify the duration in the seconds GET parameter. After you get the trace file, use the go tool trace command to investigate the trace.
```

- allocs  查看过去所有内存分配的样本
- block 查看导致阻塞同步的堆栈跟踪
- cmdline 当前程序命令行的完整的调用路径
- goroutine 当前所有运行的goroutine堆栈跟踪
- heap  查看活动对象的内存分配情况
- mutex  查看导致互斥锁的竞争持有者的堆栈跟踪
- profile 默认进行30s的CPU Profiling 会得到一个profile文件
- theadcreate 查看创建新OS线程的堆栈跟踪

其后输入goroutine/debug=1  在浏览器中进行访问

```
goroutine profile: total 5
1 @ 0x43a795 0x431441 0x43093c 0x4cfecc 0x4d1251 0x4d280c 0x5e2b86 0x5f4a95 0x6f419b 0x4f6eea 0x4f7c14 0x4f7e5b 0x67f2a3 0x6ee7ab 0x6ee7da 0x6f5508 0x6f9a9b 0x468961
#	0x43093b	internal/poll.runtime_pollWait+0x5b		F:/Go/src/runtime/netpoll.go:203
#	0x4cfecb	internal/poll.(*pollDesc).wait+0x4b		F:/Go/src/internal/poll/fd_poll_runtime.go:87
#	0x4d1250	internal/poll.(*ioSrv).ExecIO+0x120		F:/Go/src/internal/poll/fd_windows.go:228
#	0x4d280b	internal/poll.(*FD).Read+0x2fb			F:/Go/src/internal/poll/fd_windows.go:527
#	0x5e2b85	net.(*netFD).Read+0x55				F:/Go/src/net/fd_windows.go:152
#	0x5f4a94	net.(*conn).Read+0x94				F:/Go/src/net/net.go:184
#	0x6f419a	net/http.(*connReader).Read+0xfa		F:/Go/src/net/http/server.go:786
#	0x4f6ee9	bufio.(*Reader).fill+0x109			F:/Go/src/bufio/bufio.go:100
#	0x4f7c13	bufio.(*Reader).ReadSlice+0x43			F:/Go/src/bufio/bufio.go:359
#	0x4f7e5a	bufio.(*Reader).ReadLine+0x3a			F:/Go/src/bufio/bufio.go:388
#	0x67f2a2	net/textproto.(*Reader).readLineSlice+0x72	F:/Go/src/net/textproto/reader.go:58
#	0x6ee7aa	net/textproto.(*Reader).ReadLine+0xaa		F:/Go/src/net/textproto/reader.go:39
#	0x6ee7d9	net/http.readRequest+0xd9			F:/Go/src/net/http/request.go:1015
#	0x6f5507	net/http.(*conn).readRequest+0x197		F:/Go/src/net/http/server.go:966
#	0x6f9a9a	net/http.(*conn).serve+0x6da			F:/Go/src/net/http/server.go:1822

1 @ 0x43a795 0x431441 0x43093c 0x4cfecc 0x4d1251 0x4d4ba9 0x4d4e5f 0x5e30fb 0x5fc0a9 0x5fae3b 0x6fe634 0x6fe37e 0x73e1d4 0x73e19d 0x43a3c2 0x468961
#	0x43093b	internal/poll.runtime_pollWait+0x5b	F:/Go/src/runtime/netpoll.go:203
#	0x4cfecb	internal/poll.(*pollDesc).wait+0x4b	F:/Go/src/internal/poll/fd_poll_runtime.go:87
#	0x4d1250	internal/poll.(*ioSrv).ExecIO+0x120	F:/Go/src/internal/poll/fd_windows.go:228
#	0x4d4ba8	internal/poll.(*FD).acceptOne+0xa8	F:/Go/src/internal/poll/fd_windows.go:896
#	0x4d4e5e	internal/poll.(*FD).Accept+0x15e	F:/Go/src/internal/poll/fd_windows.go:930
#	0x5e30fa	net.(*netFD).accept+0x7a		F:/Go/src/net/fd_windows.go:193
#	0x5fc0a8	net.(*TCPListener).accept+0x38		F:/Go/src/net/tcpsock_posix.go:139
#	0x5fae3a	net.(*TCPListener).Accept+0x6a		F:/Go/src/net/tcpsock.go:261
#	0x6fe633	net/http.(*Server).Serve+0x263		F:/Go/src/net/http/server.go:2901
#	0x6fe37d	net/http.(*Server).ListenAndServe+0xbd	F:/Go/src/net/http/server.go:2830
#	0x73e1d3	net/http.ListenAndServe+0x73		F:/Go/src/net/http/server.go:3086
#	0x73e19c	main.main+0x3c				C:/Users/师琤琤/Desktop/newgo/main.go:21
#	0x43a3c1	runtime.main+0x211			F:/Go/src/runtime/proc.go:203

1 @ 0x43a795 0x456238 0x73e298 0x468961
#	0x456237	time.Sleep+0xc7		F:/Go/src/runtime/time.go:188
#	0x73e297	main.main.func1+0xa7	C:/Users/师琤琤/Desktop/newgo/main.go:17

1 @ 0x6f3cc1 0x468961
#	0x6f3cc0	net/http.(*connReader).backgroundRead+0x0	F:/Go/src/net/http/server.go:677

1 @ 0x732d6c 0x732b87 0x72f8a1 0x73cf41 0x73d9ac 0x6fae4b 0x6fcd0c 0x6fe28a 0x6f9c33 0x468961
#	0x732d6b	runtime/pprof.writeRuntimeProfile+0x9b	F:/Go/src/runtime/pprof/pprof.go:694
#	0x732b86	runtime/pprof.writeGoroutine+0xa6	F:/Go/src/runtime/pprof/pprof.go:656
#	0x72f8a0	runtime/pprof.(*Profile).WriteTo+0x3e0	F:/Go/src/runtime/pprof/pprof.go:329
#	0x73cf40	net/http/pprof.handler.ServeHTTP+0x340	F:/Go/src/net/http/pprof/pprof.go:248
#	0x73d9ab	net/http/pprof.Index+0x73b		F:/Go/src/net/http/pprof/pprof.go:271
#	0x6fae4a	net/http.HandlerFunc.ServeHTTP+0x4a	F:/Go/src/net/http/server.go:2012
#	0x6fcd0b	net/http.(*ServeMux).ServeHTTP+0x1ab	F:/Go/src/net/http/server.go:2387
#	0x6fe289	net/http.serverHandler.ServeHTTP+0xa9	F:/Go/src/net/http/server.go:2807
#	0x6f9c32	net/http.(*conn).serve+0x872		F:/Go/src/net/http/server.go:1895
```



### shell 交互

```
>go tool pprof http://127.0.0.1:8086/debug/pprof/goroutine?debug=1
Fetching profile over HTTP from http://127.0.0.1:8086/debug/pprof/goroutine?debug=1
Saved profile in    \pprof\pprof.goroutine.001.pb.gz
Type: goroutine
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top 10
Showing nodes accounting for 4, 100% of 4 total
Showing top 10 nodes out of 31
      flat  flat%   sum%        cum   cum%
         3 75.00% 75.00%          3 75.00%  runtime.gopark
         1 25.00%   100%          1 25.00%  runtime/pprof.writeRuntimeProfile
         0     0%   100%          1 25.00%  internal/poll.(*FD).Accept
         0     0%   100%          1 25.00%  internal/poll.(*FD).Read
         0     0%   100%          1 25.00%  internal/poll.(*FD).acceptOne
         0     0%   100%          2 50.00%  internal/poll.(*ioSrv).ExecIO
         0     0%   100%          2 50.00%  internal/poll.(*pollDesc).wait
         0     0%   100%          2 50.00%  internal/poll.runtime_pollWait
         0     0%   100%          1 25.00%  main.main
         0     0%   100%          1 25.00%  main.main.func1
(pprof)
```

### heap profiling

```
go tool pprof http://127.0.0.1:8086/debug/pprof/heap
Fetching profile over HTTP from http://127.0.0.1:8086/debug/pprof/heap
Saved profile in C:\Users\师琤琤\pprof\pprof.alloc_objects.alloc_space.inuse_objects.inuse_space.001.pb.gz
Type: inuse_space
Time: Oct 13, 2020 at 3:32pm (CST)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof)
```



### -inuse_space 程序常驻内存的占用情况

```
go tool pprof -inuse_space http://127.0.0.1:8086/debug/pprof/heap
```

### alloc_objects 分析应用程序的内存临时分配情况

```
go tool pprof -alloc_objects http://127.0.0.1:8086/debug/pprof/heap
```

### goroutine 分析

```
go tool pprof http://127.0.0.1:8086/debug/pprof/goroutine
```

使用traces命令 返回对应的所有调用栈，以及指标信息

## GOPS

GO进程诊断工具gops 

```
go get -u github.com/google/gops
```

直接执行gops命令会列出本计所有正在运行的GO程序

```
gops
13116 2292  gops.exe  go1.14.2 F:\GO\bin\bin\gops.exe
17432 11964 go.exe    go1.14.2 F:\GO\bin\go.exe
```

该命令会显示以下内容：

- PID
- PPID
- 程序名称
- 构建该程序的 Go 版本号
- 程序所在绝对路径

注意，列表中有个程序名称后面带了个 `*`，表示该程序加入了 `gops` 的诊断分析代码。

### gops <pid>

`gops <pid>` 查看本机指定 `PID` Go 程序的基本信息

```
gops 17268
parent PID:     17432
threads:        5
memory usage:   0.067%
cpu usage:      0.076%
username:       DESKTOP-138IVB1\user
cmd+args:       C:\Users\user\AppData\Local\Temp\go-build327553454\b001\exe\main.exe
elapsed time:   00:42
local/remote:   127.0.0.1:49466 <-> 0.0.0.0:0 (LISTEN)
```

### gops tree

以目录树的形式展示所有的go程序

### gops stack

于显示程序所有堆栈信息，包括每个 goroutine 的堆栈信息、运行状态、运行时长等。

```
gops memstats 127.0.0.1:9105

alloc: 1.36MB (1428632 bytes)
total-alloc: 10.21MB (10709376 bytes)
sys: 9.07MB (9509112 bytes)
lookups: 91
mallocs: 102818
frees: 91896
heap-alloc: 1.36MB (1428632 bytes)
heap-sys: 5.22MB (5472256 bytes)
heap-idle: 2.34MB (2457600 bytes)
heap-in-use: 2.88MB (3014656 bytes)
heap-released: 0 bytes
heap-objects: 10922
stack-in-use: 704.00KB (720896 bytes)
stack-sys: 704.00KB (720896 bytes)
stack-mspan-inuse: 47.95KB (49096 bytes)
stack-mspan-sys: 80.00KB (81920 bytes)
stack-mcache-inuse: 6.78KB (6944 bytes)
stack-mcache-sys: 16.00KB (16384 bytes)
other-sys: 1.21MB (1266624 bytes)
gc-sys: 492.00KB (503808 bytes)
next-gc: when heap-alloc >= 4.00MB (4194304 bytes)
last-gc: 2018-10-18 13:37:04.37511973 +0800 CST
gc-pause-total: 9.209158ms
gc-pause: 52831
num-gc: 60
enable-gc: true
debug-gc: false
```

### gops gc

 `gops gc (<pid>|<addr>)` 查看指定程序的垃圾回收(GC)信息

### gops setgc

`gops setgc (<pid>|<addr>)` 设定指定程序的 GC 目标百分比

### gops stats

`gops stats (<pid>|<addr>)` 查看指定程序的 `goroutine` 数量、`GOMAXPROCS` 值等信息

### gops pprof-cpu (<pid>|<addr>)

```
gops pprof-cpu 2608
Profiling CPU now, will take 30 secs...
Profile dump saved to: C:\Users\AppData\Local\Temp\cpu_profile281242487
Binary file saved to: C:\Users\AppData\Local\Temp\binary743683690
Type: cpu
Time: Oct 13, 2020 at 9:06pm (CST)
Duration: 30.01s, Total samples = 0
No samples were found with the default sample value type.
Try "sample_index" command to analyze different sample values.
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top
Showing nodes accounting for 0, 0% of 0 total
      flat  flat%   sum%        cum   cum%
```

### gops pprof-heap

`gops pprof-heap (<pid>|<addr>)` 调用并展示 `go tool pprof` 工具中关于 heap 的性能分析数据，操作与 `pprof` 一致。

### gops trace

`gops trace (<pid>|<addr>)` 追踪程序运行5秒，生成可视化报告，自动展开于浏览器中





