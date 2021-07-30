# struct to map

```makefile
map values encode as json objects 
the map's key type must either be a string,an integer type or implement encoding.TextMarshaler. The map keys are sorted and used as json object keys by applying the following rules:
 'subject to the UTF-8 coercion described for string values above:  - keys of any string type are used directly - encoding.TextMarshalers are marshaled - integer keys are converted to strings'
```

```go
Pointer values encode as the value pointed to: A nil pointer encodes as the null json value,
interface values encode as the value contained in the interface 
nil interface value encodes as the null json value 
channel, complex,function cannot be encode in json 
```

使用json序列化的方式

```go
u1 := User{Name: "BANI", Age: 16}
	b, _ := json.Marshal(&u1)

var m map[string]interface{}
_ = json.Unmarshal(b, &m)
fmt.Println("struct——>map", m)
fmt.Printf("%T\n", m["age"])
```

反射

```go
func ToMap(in interface{}, tagName string) (out map[string]interface{}, err error) {
	out = make(map[string]interface{})
	// 反射获取值
	v := reflect.ValueOf(in)

	if v.Kind() == reflect.Ptr {
		v = v.Elem()
	}

	if v.Kind() != reflect.Struct { // 非结构体时返回错误
		return nil, fmt.Errorf("ToMap only accepts struct or struct pointer; got %T", v)

	}

	t := v.Type()
	for i := 0; i < v.NumField(); i++ {
		fi := t.Field(i)
		if tagValue := fi.Tag.Get(tagName); tagValue != "" {
			out[tagValue] = v.Field(i).Interface()
		}
	}
	return out, nil
}

```

