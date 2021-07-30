# json序列化

## json.Marshal签名

```go
func Marshal(v interface{}) ([]byte, error) 
```

其返回v的json编码,

```makefile
bool===>json bolean 
float point,int,number value =====> json numbers
string====> json strings coerced to valid UTF-8
replacing invalid bytes with the Unicode replacement rune.
Array,slice ===>json arrays 
nil slice ==> nil json value
[]byte ===> base64-encoded string
```



## 结构体Tag

Tag是结构体的元信息，可以在运行的时候通过发射的机制读取出来，Tag在结构体字段的后方定义，为一对"``"包裹的key:value

使用json Tag指定序列化与反序列化时的行为：

```go
type Person struct{
	Name string `json:"name"` // 指定json序列化/反序列化时对于Name字段使用name
	Age  int64
	Weight float64  `json:"_",omitempty` // 指定json序列化/反序列化时忽略Weight字段, 而omitempty则是忽略无值时的该字段
}
```

 omitempty”选项指定如果字段具有空值（定义为 false，0，nil指针，nil接口值和任何空数组、切片），则应从编码中省略该字段，地图或字符串。作为一种特殊情况，如果字段标记为“-”，则始终忽略该字段。

注意，仍可以使用标签“-”来生成名称为“-”的字段。 

注：当struct字段未设置值时,json.Marshal() 序列化的时候不会忽略该字段,默认使用该字段对应的数据类型的零值例如int和float类型零值是 0，string类型零值是""，对象类型零值是 nil）

struct==> json

```go
struct ===>json object //"each exported struct field becomes a member of the object, using the field name as the object key,"

```

将一个go语言类型movies的结构体slice转为json的过程称为编组，编组通过调用json.Marshal函数完成：

```go
data, err := json.Marshal(movies)
if err != nil {
    log.Fatalf("JSON marshaling failed: %s", err)
}
fmt.Printf("%s\n", data)
```

json==>struct

```go
err:=json.Unmarshal(var,interface{})
```

使用结构体嵌套时，忽略空字段，对于嵌套的结构体，需要使用字段的指针

```go
type Person struct {
	Name string  `json:"people_name"`
	Age  int     `json:"people_age"`
	Weight int    `json:"_,omitempty"`
	Hoob []string    `json:"hobby,omitempty"`
    *Adress    `json:"adress,omitempty"`
}
type Adress struct {
	City string `json:"city"`
	Num int     `json:"num"`
}
```

使用json序列化的结构体，个别字段又不可能序列化需要额外定义一个结构体。匿名嵌套原来的结构体，通知指定非序列化的字段为匿名结构体指针类型，并添加tag "omitempty"。(与其说是序列化部分的字段,倒不如说是重写结构体的非序列化字段且为指针类型的空结构体)

```go
type Adress struct {
	City string `json:"city"`
	Num int     `json:"num"`
}
type pNum struct {
	*Adress  //匿名嵌套
	Num  *struct{}  `json:"num,omitempty"`
}
```

```go
var ad Adress
ad.Num=2
ad.City="齐齐哈尔"
var pis pNum
pis.Adress=&ad
b1,err3:=json.Marshal(pis)
```

结果为：

```go
{"city":"齐齐哈尔"}
```

使用匿名结构体内嵌给原有结构体 添加额外字段

```go
b,err:=json.Marshal(struct{
    *Walker
    Age int `json:"age"`
}{
    &w1,
    16,
})
```







### 处理string格式数据

json数据中可能会使用字符串类型的数字，这个时候可以在结构体tag中添加string来告诉json包从字符串中解析相应字段的数据

```go
type Card struct {
	ID    int64   `json:"id,string"`    // 添加string tag
	Score float64 `json:"score,string"` // 添加string tag
}
jsonStr1 := `{"id": "1234567","score": "88.50"}`
var c1 Card
if err := json.Unmarshal([]byte(jsonStr1), &c1); err != nil {
	fmt.Printf("json.Unmarsha jsonStr1 failed, err:%v\n", err)
	return
}
c1:=Card{ID=1,Sorce=3.55}
b,err:=json.Marshal(c1)
```

## 反序列化

```go
func Unmarshal(data []byte, v interface{}) error 
```

> represents JSON data structure using native Go types: booleans, floats, // strings, arrays, and maps.

`Unmarshal`解析json编码的数据，并将结果存储在v指向的值中，若v为nil而不是指针,则返回`invalidUnmarshalError`错误，必要时分配map、slice、pointer。遵循以下规则：

```tex
将json解组为指针,JSON为JSON常量null的情况。在这种情况下，Unmarshal将指针设置为nil，否则Unmarshal会将json解组为指针所指向的值。如果指针为nil，则Unmarshal将分配一个新值以使其指向
```

json====> array/slice

```
将json数组解到切片中，Unmarshal会将切片的长度重置为零，然后将每个元素附加到切片中，作为一个特殊的情况，要将空的Josn数组结组为一个片，解组用一个新的空片替换该片。要将json数组解为Go数组，Unmarshal会将Json数组元素解码为对应的Go数组元素。如果Go数组小于Json数组，其他的数组元素将被丢弃，若json数组小于Go数组，则将其他的数组元素设置为零值
```

json=====> map

```
将json对象结组到map中，首先需要创建一个要使用的map。若map为nil，Unmarshal将分配一个新的map,否则解组重用现有的map，保留现有的条目，然后结组来自json对象的key,value 将存储到map中，map的key必须为string,int
```

```
如果json值不适用于给定的目标类型，或者json数字溢出目标类型，则Unmarshal会跳过该字段并进最大的可能完成解组。若遇到更多的错误，则Unmarshal返回'UnmarshalTypeError'，通过将Go值设置为nil，JSON空值将解组到接口，映射，指针或切片中。因为JSON中通常使用null来表示不存在，所以将JSON null编组到任何其他Go类型中不会对值产生影响也不产生错误。
```

json===>string

```
解组带引号的字符串时，无效的UTF-8或无效的UTF-16代理对不会被视为错误。而是将它们替换为Unicode替换字符U + FFFD。
```





