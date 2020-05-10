include Bindings
module Expr = Five_expr

let rec conv = function
  | Expr.Global_x -> Bindings.Tree.x ()
  | Global_y -> Bindings.Tree.y ()
  | Global_z -> Bindings.Tree.z ()
  | Const f -> Bindings.Tree.const f
  | Nonary { op } ->
    Bindings.Tree.opcode op |> Bindings.Tree.op_nonary
  | Unary { op; arg } ->
    Bindings.Tree.op_unary (Bindings.Tree.opcode op) (conv arg)
  | Binary { op; left; right } ->
    Bindings.Tree.op_binary
      (Bindings.Tree.opcode op)
      (conv left)
      (conv right)
;;
