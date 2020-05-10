open struct
  include Five.Dim3
  include Five.Csg
  include Five.Transform
  include Five.Value

  let c = Five.Value.const
end

(*
let final =
  blend_difference
    ~amount:(c 1.0)
    (sphere ~r:(c 1.0))
    (sphere ~r:(c 1.0) |> move ~dx:(c 1.0))

    *)

let final =
  intersection
    [ sphere ~r:(c 2.0)
    ; (fun ~x ~y ~z ->
        let x = x * c 5.0 in
        let y = y * c 5.0 in
        let z = z * c 5.0 in
        sin x + sin y + sin z)
    ]
;;

let expr =
  final
    ~x:Five.Value.Global_x
    ~y:Five.Value.Global_y
    ~z:Five.Value.Global_z
;;

let () = print_endline (Five_expr.to_string expr)

open Five_sys

let final = conv expr

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
    ~filename:"out/circle.svg"
;;

let () =
  save_mesh
    ~tree:final
    ~region:
      (Region3.create
         ~min_x:(-3.0)
         ~max_x:3.0
         ~min_y:(-3.0)
         ~max_y:3.0
         ~min_z:(-3.0)
         ~max_z:3.0)
    ~resolution:20.0
    ~filename:"out/circle.stl"
;;
