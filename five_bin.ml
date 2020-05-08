open Five

let x = Tree.x ()
let y = Tree.y ()
let x2 = Tree.op_unary (Five.Tree.opcode "square") x
let y2 = Tree.op_unary (Five.Tree.opcode "square") y
let s = Tree.op_binary (Five.Tree.opcode "add") x2 y2
let one = Tree.const 1.0
let final = Tree.op_binary (Five.Tree.opcode "sub") s one

let () =
  save_slice
    ~tree:final
    ~region:
      (Region2.create
         ~min_x:(-2.0)
         ~max_x:2.0
         ~min_y:(-2.0)
         ~max_y:2.0)
    ~z:0.0
    ~resolution:10.0
    ~filename:"circle.svg"
;;

let () =
  save_mesh
    ~tree:final
    ~region:
      (Region3.create
         ~min_x:(-2.0)
         ~max_x:2.0
         ~min_y:(-2.0)
         ~max_y:2.0
         ~min_z:(-2.0)
         ~max_z:2.0)
    ~resolution:10.0
    ~filename:"circle.stl"
;;
