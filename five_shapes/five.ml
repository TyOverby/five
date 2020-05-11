open! Base

type t =
  x:Five_expr.t -> y:Five_expr.t -> z:Five_expr.t -> Five_expr.t

module Value = struct
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
end

open Value

module Csg = struct
  let rec union shapes ~x ~y ~z =
    match shapes with
    | [] -> failwith "union with zero arguments!"
    | [ a ] -> a ~x ~y ~z
    | a :: rest -> min (a ~x ~y ~z) (union ~x ~y ~z rest)
  ;;

  let rec intersection shapes ~x ~y ~z =
    match shapes with
    | [] -> failwith "intersection with zero arguments!"
    | [ a ] -> a ~x ~y ~z
    | a :: rest -> max (a ~x ~y ~z) (intersection rest ~x ~y ~z)
  ;;

  let inverse shape ~x ~y ~z = neg (shape ~x ~y ~z)

  let difference a = function
    | [] -> a
    | l -> intersection [ a; inverse (union l) ]
  ;;

  let offset shape ~by ~x ~y ~z = shape ~x ~y ~z - by
  let clearance a b ~by = difference a [ offset b ~by ]
  let shell shape ~thickness = clearance shape shape ~by:thickness

  let blend_expt a b ~amount ~x ~y ~z =
    let a = a ~x ~y ~z in
    let b = b ~x ~y ~z in
    let m = amount in
    neg (log (exp (neg m * a) + exp (neg m * b))) / m
  ;;

  let blend_expt_unit a b ~amount =
    blend_expt a b ~amount:(const 2.75 / (amount * amount))
  ;;

  let blend_rough a b ~amount ~x ~y ~z =
    let a = a ~x ~y ~z in
    let b = b ~x ~y ~z in
    let c = sqrt (abs a) + sqrt (abs b) - amount in
    min a (min b c)
  ;;

  let real_offset = offset

  let blend_difference ?(offset = const 0.0) a b ~amount =
    inverse
      (blend_expt_unit (inverse a) (real_offset b ~by:offset) ~amount)
  ;;

  let morph a b ~by ~x ~y ~z =
    let a = a ~x ~y ~z in
    let b = b ~x ~y ~z in
    let m = by |> min (const 0.0) |> max (const 1.0) in
    (a * (const 1.0 - m)) + (b * m)
  ;;

  (* loft *)
end

module Transform = struct
  let move
      ?(dx = const 0.0)
      ?(dy = const 0.0)
      ?(dz = const 0.0)
      shape
      ~x
      ~y
      ~z
    =
    shape ~x:(x - dx) ~y:(y - dy) ~z:(z - dz)
  ;;

  let reflect_x ?(pos = const 0.0) shape ~x ~y ~z =
    shape ~x:((const 2.0 * pos) - x) ~y ~z
  ;;

  let reflect_y ?(pos = const 0.0) shape ~x ~y ~z =
    shape ~x ~y:((const 2.0 * pos) - y) ~z
  ;;

  let reflect_z ?(pos = const 0.0) shape ~x ~y ~z =
    shape ~x ~y ~z:((const 2.0 * pos) - z)
  ;;

  let reflect_xy shape ~x ~y ~z = shape ~x:y ~y:x ~z
  let reflect_yz shape ~x ~y ~z = shape ~x ~y:z ~z:y
  let reflect_xz shape ~x ~y ~z = shape ~x:z ~y ~z:x
  let sym_x shape ~x ~y ~z = shape ~x:(abs x) ~y ~z
  let sym_y shape ~x ~y ~z = shape ~x ~y:(abs y) ~z
  let sym_z shape ~x ~y ~z = shape ~x ~y ~z:(abs z)

  (* TODO: scaling functions *)

  let rotate_x ~rad shape ~x ~y ~z =
    let ca = cos rad in
    let sa = sin rad in
    shape ~x ~y:((ca * y) + (sa * z)) ~z:((neg sa * y) + (ca * z))
  ;;

  let rotate_y ~rad shape ~x ~y ~z =
    let ca = cos rad in
    let sa = sin rad in
    shape ~x:((ca * x) + (sa * z)) ~y ~z:((neg sa * x) + (ca * z))
  ;;

  let rotate_z ~rad shape ~x ~y ~z =
    let ca = cos rad in
    let sa = sin rad in
    shape ~x:((ca * x) + (sa * y)) ~y:((neg sa * x) + (ca * y)) ~z
  ;;

  (* TODO: distortion functions *)

  (* TODO: revolve *)
  (* TODO: twirls *)
end

module Dim2 = struct
  let circle ~r ~x ~y ~z:_ = sqrt ((x ^ 2) + (y ^ 2)) - r
  let ring ~ro ~ri = Csg.difference (circle ~r:ro) [ circle ~r:ri ]

  let rect ~min_x ~min_y ~max_x ~max_y ~x ~y ~z:_ =
    let bx = max_x in
    let by = max_y in
    let ax = min_x in
    let ay = min_y in
    ax - x |> max (x - bx) |> max (ay - y) |> max (y - by)
  ;;

  let rounded_rect ~r ~min_x ~min_y ~max_x ~max_y =
    Csg.union
      [ rect ~min_x:(min_x + r) ~min_y ~max_x:(max_x - r) ~max_y
      ; rect ~min_x ~min_y:(min_y + r) ~max_x ~max_y:(max_y - r)
      ; circle ~r |> Transform.move ~dx:(min_x + r) ~dy:(min_y + r)
      ; circle ~r |> Transform.move ~dx:(max_x - r) ~dy:(min_y + r)
      ; circle ~r |> Transform.move ~dx:(min_x + r) ~dy:(max_y - r)
      ; circle ~r |> Transform.move ~dx:(max_x - r) ~dy:(max_y - r)
      ]
  ;;

  (* TODO: rest of the rectangle and triangle functions *)
end

let extrude_z shape ~min_z ~max_z ~x ~y ~z =
  max (shape ~x ~y ~z) (max (min_z - z) (z - max_z))
;;

module Dim3 = struct
  let sphere ~r ~x ~y ~z = sqrt ((x ^ 2) + (y ^ 2) + (z ^ 2)) - r

  let box ~min_x ~min_y ~min_z ~max_x ~max_y ~max_z =
    extrude_z (Dim2.rect ~min_x ~min_y ~max_x ~max_y) ~min_z ~max_z
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

  let rounded_box ~r ~min_x ~min_y ~min_z ~max_x ~max_y ~max_z =
    let width = ((max_x - min_x) / const 2.0) - r
    and height = ((max_y - min_y) / const 2.0) - r
    and depth = ((max_z - min_z) / const 2.0) - r in
    let dx = width + min_x + r
    and dy = height + min_y + r
    and dz = depth + min_z + r in
    rounded_box ~r ~width ~height ~depth |> Transform.move ~dx ~dy ~dz
  ;;

  (* vec3 q = abs(p) - b;
     return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r; *)
end

let slice shape ~at ~x ~y ~z:_ = shape ~x ~y ~z:at
