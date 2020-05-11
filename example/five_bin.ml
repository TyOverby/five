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

let clamp ~low ~high v = v |> max low |> min high
let lerp x = x
let ease_in_out_sin v = neg ((cos (c Float.pi * v) - c 1.0) / c 2.0)
let ease_out_sin v = c 1.0 - (cos (c Float.pi * v) / c 2.0)
let ease_in_quad = square

let remap f ~i_low ~i_high ~o_low ~o_high v =
  let v = clamp ~low:i_low v ~high:i_high in
  let v = (v - i_low) / (i_high - i_low) in
  o_low + (f v * (o_high - o_low))
;;

let height = 15.0
let handle = 6.0
let thickness = 0.5

let final ~x ~y ~z =
  (* scale *)
  let s =
    remap
      lerp
      ~i_low:(c handle)
      ~i_high:(c height)
      ~o_low:(c 1.0)
      ~o_high:(c 0.35)
      z
  in
  let x = x / s in
  let y = y / s in
  (* rotation *)
  let rad =
    remap
      lerp
      ~i_low:(c handle)
      ~i_high:(c height)
      ~o_low:(c 0.0)
      ~o_high:(c Float.pi)
      z
  in
  let ca = cos rad in
  let sa = sin rad in
  let x = (ca * x) + (sa * y)
  and y = (neg sa * x) + (ca * y) in
  (* box *)
  let s =
    box
      ~min_x:(c (-0.25))
      ~min_y:(c (-0.25))
      ~min_z:(c 0.0)
      ~max_x:(c 0.25)
      ~max_y:(c 0.25)
      ~max_z:(c height)
  in
  s ~x ~y ~z
;;

let final = final

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
         ~min_x:(-1.0)
         ~max_x:1.0
         ~min_y:(-1.0)
         ~max_y:1.0
         ~min_z:(-1.0)
         ~max_z:16.0)
    ~resolution:10.0
    ~filename:"out/circle.stl"
;;
