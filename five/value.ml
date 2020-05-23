open! Base
include Five_expr

let const v = Const v
let unary op arg = Unary { op; arg }
let binary op left right = Binary { op; left; right }
let square = unary "square"
let sqrt = unary "sqrt"
let neg = unary "neg"
let sin = unary "sin"
let cos = unary "cos"
let tan = unary "tan"
let asin = unary "asin"
let acos = unary "acos"
let atan = unary "atan"
let exp = unary "exp"
let abs = unary "abs"
let log = unary "log"
let recip = unary "recip"
let add = binary "add"
let mul = binary "mul"
let min = binary "min"
let max = binary "max"
let sub = binary "sub"
let div = binary "div"
let atan2 = binary "atan2"
let pow = binary "pow"
let nth_root = binary "nth_root"
let mod_ = binary "mod"
let ( + ) = add
let ( - ) = sub
let ( * ) = mul
let ( / ) = div

let rec ( ^ ) v i =
  match i with
  | 0 -> const 1.0
  | 1 -> v
  | 2 -> square v
  | n -> v * (v ^ Int.(n - 1))
;;

module Private = struct
  let to_expr = Fn.id
  let of_expr = Fn.id
end
