open! Import
open Value

type t = x:v -> y:v -> z:v -> v

let circle ~r ~x ~y ~z:_ = sqrt ((x ^ 2) + (y ^ 2)) - r

let ring ~ro ~ri ~x ~y ~z =
  Csg.difference (circle ~r:ro ~x ~y ~z) [ circle ~r:ri ~x ~y ~z ]
;;

let rect ~min_x ~min_y ~max_x ~max_y ~x ~y ~z:_ =
  let bx = max_x in
  let by = max_y in
  let ax = min_x in
  let ay = min_y in
  ax - x |> max (x - bx) |> max (ay - y) |> max (y - by)
;;

let extrude_z shape ~min_z ~max_z ~x ~y ~z =
  let open Value in
  max (shape ~x ~y ~z) (max (min_z - z) (z - max_z))
;;

let sphere ~r ~x ~y ~z = sqrt ((x ^ 2) + (y ^ 2) + (z ^ 2)) - r

let box ~min_x ~min_y ~min_z ~max_x ~max_y ~max_z =
  extrude_z (rect ~min_x ~min_y ~max_x ~max_y) ~min_z ~max_z
;;

let rounded_box
    ~r
    ~width:b_x
    ~height:b_y
    ~depth:b_z
    ~x:p_x
    ~y:p_y
    ~z:p_z
  =
  let q_x = abs p_x - b_x
  and q_y = abs p_y - b_y
  and q_z = abs p_z - b_z in
  let dx = max q_x (const 0.0) in
  let dy = max q_y (const 0.0) in
  let dz = max q_z (const 0.0) in
  sqrt (square dx + square dy + square dz)
  + min (max q_x (max q_y q_z)) (const 0.0)
  - r
;;

let rounded_box ~r ~min_x ~min_y ~min_z ~max_x ~max_y ~max_z ~x ~y ~z =
  let width = ((max_x - min_x) / const 2.0) - r
  and height = ((max_y - min_y) / const 2.0) - r
  and depth = ((max_z - min_z) / const 2.0) - r in
  let dx = width + min_x + r
  and dy = height + min_y + r
  and dz = depth + min_z + r in
  let x, y, z = Transform.move ~dx ~dy ~dz () ~x ~y ~z in
  rounded_box ~r ~width ~height ~depth ~x ~y ~z
;;

let slice shape ~at ~x ~y ~z:_ = shape ~x ~y ~z:at
