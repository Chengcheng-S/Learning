(module

;;    数值指令 前缀为0x0F + 子操作码
;;    (func
;;        (f32.const 12.3) (f32.const 46.53) (f32.add)
;;        (i32.trunc_sat_f32_s) (drop)
;;    )

;;  变量指令
;;    (global $g1 (mut i32)(i32.const 15 ))
;;    (global $g2 (mut i32)(i32.const 20 ))
;;
;;
;;    (func(param $a i32) (param $b i32)
;;        (global.get $g1) (global.set $g2)
;;        (local.get $a) (local.set $b)
;;
;;    )

;;    内存指令
;;    (memory 1 8)
;;    (data (offset (i32.const 100)) "hello")
;;    (func
;;
;;        (i32.const 1) (i32.const 2)
;;        (i32.load offset=100)
;;        (i32.store offset=100)
;;        (memory.size) (drop)
;;        (i32.const 4 ) (memory.grow) (drop)
;;    )

;;结构化指令  block 0x02 loop 0x03  if 0x04 end 0x0b else 0x05
;;    (func (result i32)
;;        (block (result i32)
;;         (i32.const 1)
;;         (loop (result i32)
;;         (if (result i32)(i32.const 2 )
;;            (then (i32.const 3 ))
;;            (else (i32.const 4))
;;         )
;;
;;        )
;;        (drop)
;;        )
;;
;;    )

;; 跳转指令   br 0x0c br_if 0x0d  br_table 0x0e  return 0x0f
;;    (func
;;        (block (block (block
;;            (br 1)
;;            (br_if 2 (i32.const 100) )
;;            (br_table 0 1 2 3 )
;;            (return)
;;        )))
;;
;;    )

;;函数调用指令
;; call 0x10 直接调用   call_indirect 0x11 间接调用在运行时确定调用的函数，函数签名的索引由立即数指定
    (type $ft1 (func))
    (type $ft2 (func))
    (table funcref (elem $f1 $f1 $f1))
    (func $f1
        (call $f1)
        (call_indirect (type $ft2) (i32.const 2))
    )

)
