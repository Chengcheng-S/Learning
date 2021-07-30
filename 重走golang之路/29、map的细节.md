# map

映射键：Go可比较的类型都可以作为key(除slice，map，func)    

具体包括： bool,number,string,pointer,chan,interface,struct。

这些类型的共同特征都是支持`==`以及`!=`

当`k1==k2`时，认为k1和k2是同一个key，如果是结构体，只有hash后边的值以及字面值相等，才被认为是相同的key。

value 无限制

map在**扩容之后**，会发生**key的迁移**，而遍历的过程，就是按顺序遍历 **bucket**，同时按顺序遍历 bucket 中的 key。搬迁后，key 的位置发生了重大的变化，有些 key 飞上高枝，有些 key 则原地不动。这样，遍历 map 的结果就不可能按原来的顺序了。

在遍历 map 时，并不是固定地从 0 号 bucket 开始遍历，每次都是从一个随机值序号的 bucket 开始遍历，并且是从这个 bucket 的一个随机序号的 cell 开始遍历。这样，即使你是一个写死的 map，仅仅只是遍历它，也不太可能会返回一个固定序列的 key/value 对了。

map无序遍历，从1.0开始

map并**不是线程安全**的，

> 在查找、赋值、遍历、删除的过程中都会检测写标志，一旦发现写标志置位（等于1），则直接 panic。赋值和删除函数在检测完写标志是复位之后，先将写标志位置位，才会进行之后的操作。

## map的删除过程

写操作底层的执行函数是`mapdelete`

```go
func mapdelete(t *maptype, h *hmap, key unsafe.Pointer)
```

根据key类型的不同，删除操作会被优化成更具体的函数

计算 key 的哈希，找到落入的 bucket。检查此 map 如果正在扩容的过程中，直接触发一次搬迁操作。

删除操作同样是两层循环，核心还是找到 key 的具体位置。寻找过程都是类似的，在 bucket 中挨个 cell 寻找。

找到对应位置后，对 key 或者 value 进行“清零”操作。

## Map的底层原理

在计算机科学里，被称为相关数组、map、符号表或者字典，是由一组 `<key, value>` 对组成的抽象数据结构，，并且同一个 key 只会出现一次。

Map扩容：需要将原有的 key/value **重新搬迁**到新的内存地址。

大量搬迁，影响性能，Go map 采用一种**渐进式**的方式,原有的key不会一次搬迁，而是每次搬迁2个bucket

特殊情况： key为math.NaN()是float64 类型，每次计算得到的结果都不相同，可以向一个 map 插入任意数量`math.NaN()` 作为 key。

无法对map中的key进行取址操作

### map深度相等的条件

- 都为nil
- 非空，长度相等，指向同一个map实体对象
- 相应的key指向value”深度”相等























