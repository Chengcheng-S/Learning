### 问题类型

```shell
no override and no default toolchain set
```

原因 rust没有正确的安装，解决方式

```
rustup install stable
```

```
rustup default stable
```



### 问题类型

```
cargo build error: failed to run custom build command for `openssl-sys v0.9.39` 
```

问题描述： ssl 库升级导致，更新库即可解决

```
sudo apt install libssl-dev
```

删除之前编译留下的文件

```
sudo rm -rf Cargo.lock target/
```

