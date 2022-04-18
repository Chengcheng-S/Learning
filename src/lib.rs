
// #[no_mangle]
// pub extern "C" fn prints() {
//     println!("prints func!");
// }

// #[no_mangle]
// pub extern "C" fn print_env(n: i32) {
//     for x in 0..n{
//         if x%2 ==0{
//             // unsafe{print_i32(x);}
//             println!("{:?}",x);
//         }
//     }
// }

// #[no_mangle]
// pub extern "C" fn print_ascii(n :i32){

//     match n {
//         0x61 =>print!(" {:?}",'a' as u8),
//         _=>print!("another"),
//     }

// }

// #[no_mangle]
// pub extern "C" fn max (a:i32,b:i32)->i32{
//     if a >b {a} else {b}
// }

extern "C" {fn random_i32()->i32;}
#[no_mangle]
pub extern "C" fn discard (){
    unsafe {let _=random_i32();}
}