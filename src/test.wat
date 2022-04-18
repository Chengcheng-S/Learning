(module
  (type (;0;) (func))
  (type (;1;) (func (result i32)))
  (import "env" "random_i32" (func $random_i32 (type 1)))
  (func $discard.command_export (type 0)
    (drop
      (call $random_i32)))
  (memory (;0;) 16)
  (global (;0;) i32 (i32.const 1048576))
  (global (;1;) i32 (i32.const 1048576))
  (export "memory" (memory 0))
  (export "__heap_base" (global 0))
  (export "__data_end" (global 1))
  (export "discard" (func $discard.command_export)))
