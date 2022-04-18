(module
;; ;;    值类型
;;     (type $ft1 (func (param i32 i32) (result i32)))
    
;; ;; 外部导入
;;     (import "evn" "f1" (func $f1 (type $ft1)))

;;     (import "env" "f2" (func $f2 (param f64) (result f64 f64)))  ;; inline func type 
    
;;     (import "env" "t1" (table $t 1 8 funcref))

;;     (import "env" "m1" (memory $m 4 16))

;;     (import "evn" "g1" (global $g1 i32))   ;; immutable

;;     (import "evn" "g2" (global $g2 (mut i32))) ;; mutable

;; ;; 导入域内联
;;     (func $f3 (import "env" "f3" ) (param f32 f32 )(result f32)))

;; ;; 导出
;;     (export "f1" (func $f1))

;;     (export "m1" (memory $m1))
    
;;     (export "g1" (global $g1))


;; 函数域  
;; 定义函数的类型和局部变量，并给出函数的指令， wat编译器则会把函数域拆开，将类型索引放在函数段中，局部变量和字节码放到代码段中
;;     (type $ft1 (func (param  i32 i32)  (result i32)))

;;     (func $add (type $ft1)
;;         (local i64 i64)
;;         (i64.add (local.get 2) (local.get 3)) (drop)
;;         (i32.add (local.get  0 )(local.get 1))
;;     )
;; 上述函数等价于
    
    ;; (func $add (param $a i32) (param $b i32) (result i32)
    ;;     (local $c i64)  (local $d i64)
    
    ;;     (i64.add(local.get $c) (local.get $d)) (drop)
    ;;     (i32.add(local.get $a)(local.get $b))
    ;; )


;; 表域和元素域
;; 表域描述表的类型，包括限制和元素类型（目前只能为funcref）。 元素域可以指定若干函数索引，以及第一个索引的表内偏移量。
    ;; (func $f1) (func $f2) (func $f3)
    ;; (table 10 20 funcref)
    ;; (elem (offset (i32.const 5)) $f1 $f2 $f3 )

    ;; (table funcref (elem $f1 $f2 $f3)) ;;inline elem offset 0 min 3 max 3
    ;;  使用内联元素域的方式无法指定表的限制（只能由编译器根据内联元素推断）、元素的表内偏移量（只能从0开始）

;; 内存域和数据域
;; 模块最多只能导入或定义一块内存，因此内存域只能出现一次，数据域则可以多次出现。
;; 内存域需要描述内存的类型（即页数的上下限），数据域需要指定内存偏移量和初始数据。
    ;; (memory 4 16)
    ;; (data (offset (i32.const 100 ))"wasmer ")
    ;; (data (offset (i32.const 107))"text ")

    ;; inline memory  类似于表域和元素域 使用内联方式，但是不能指定内存页数、内存偏移量
    ;; (memory  ;; min 1  max 1
        ;; (data "wasmer text") ;; offset 0 
    ;; )


;; 全局域 定义全局变量，描述全局变量的类型和可变性，并给定初始值。全局域可以指定标识符，如此在变量指令中使用全局变量的名字而非索引。
    ;; (global $A (mut i32) (i32.const 5))
    ;; (global $B f32 (f32.const 3.14159))
    ;; (func $f1 (result i32)
    ;;         (global.get $A)
        
    ;; )

;; 起始域 指定一个起始函数名或索引
    
    ;; (func $f1 )
    ;; (start $f1)


;;  一个简单的用例
    
    ;; (func $answer (result i32)
    ;;     i32.const 78
    ;; )
    ;; (func $getans (result i32)
    ;;     call $answer
    ;;     i32.const 32
    ;;     i32.add
        
    ;; )
    ;; (export "getans" (func $getans))


;; 跳转标签
    ;; (func 
    ;;     (block
    ;;         (i32.const 100) (br 0) (drop)
    ;;     )

    ;;     (loop  ;;inline  
        
    ;;         (i32.const 200) (br 0) (drop)
    ;;     )    

    ;;     (if (i32.eqz (i32.const 300))

    ;;         (then (i32.const 400) (br 0 ) (drop))
    ;;         (else (i32.const 500) (br 0) (loop))
    ;;     )
    ;; )



    ;; (type $ft1 (func (param  i32 i32)  (result i32)))

    ;; (table  1 5 funcref)
    ;; (func $add (param i32 i32 i32) (result i32)
        ;; (local.get 0 ) (local.get 1) (local.get 2 )
        ;; (call_indirect (type $ft1))
        ;; )
    
    ;; (export "add" (func $add))
    
)

