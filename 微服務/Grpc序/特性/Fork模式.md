# Fork模式

Fork是XClient的一种方法，使用它向包含此服务的**所有服务器**发送请求。
如果任何服务器返回响应而没有错误，Fork将为这个XClient返回。如果所有服务器都返回错误，Fork将返回这些错误的错误。

故障备份模式。Failbackup最多使用两个请求，但是Fork使用更多的请求（与服务器计数相同）。

```go

func main() {
    ……
    xclient := client.NewXClient("Arith", client.Failover, client.RoundRobin, d, client.DefaultOption)
    defer xclient.Close()
    args := &example.Args{
        A: 10,
        B: 20,
    }
    for {
        reply := &example.Reply{}
        err := xclient.Fork(context.Background(), "Mul", args, reply)
        if err != nil {
            log.Fatalf("failed to call: %v", err)
        }
        log.Printf("%d * %d = %d", args.A, args.B, reply.C)
        time.Sleep(1e9)
    }
}
```

