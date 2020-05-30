open! Import
open Value

type t =
  x:Value.t -> y:Value.t -> z:Value.t -> Value.t * Value.t * Value.t

let shape ~x ~y ~z = x, y, z

let move
    ?(dx = const 0.0)
    ?(dy = const 0.0)
    ?(dz = const 0.0)
    ()
    ~x
    ~y
    ~z
  =
  shape ~x:(x - dx) ~y:(y - dy) ~z:(z - dz)
;;

let reflect_x ?(pos = const 0.0) () ~x ~y ~z =
  shape ~x:((const 2.0 * pos) - x) ~y ~z
;;

let reflect_y ?(pos = const 0.0) () ~x ~y ~z =
  shape ~x ~y:((const 2.0 * pos) - y) ~z
;;

let reflect_z ?(pos = const 0.0) () ~x ~y ~z =
  shape ~x ~y ~z:((const 2.0 * pos) - z)
;;

let reflect_xy ~x ~y ~z = shape ~x:y ~y:x ~z
let reflect_yz ~x ~y ~z = shape ~x ~y:z ~z:y
let reflect_xz ~x ~y ~z = shape ~x:z ~y ~z:x
let sym_x ~x ~y ~z = shape ~x:(abs x) ~y ~z
let sym_y ~x ~y ~z = shape ~x ~y:(abs y) ~z
let sym_z ~x ~y ~z = shape ~x ~y ~z:(abs z)
let scale_x how_much ~x ~y ~z = shape ~x:(x / how_much) ~y ~z
let scale_y how_much ~x ~y ~z = shape ~x ~y:(y / how_much) ~z
let scale_z how_much ~x ~y ~z = shape ~x ~y ~z:(z / how_much)

(* TODO: scaling functions *)

let rotate_x ~rad ~x ~y ~z =
  let ca = cos rad in
  let sa = sin rad in
  shape ~x ~y:((ca * y) + (sa * z)) ~z:((neg sa * y) + (ca * z))
;;

let rotate_y ~rad ~x ~y ~z =
  let ca = cos rad in
  let sa = sin rad in
  shape ~x:((ca * x) + (sa * z)) ~y ~z:((neg sa * x) + (ca * z))
;;

let rotate_z ~rad ~x ~y ~z =
  let ca = cos rad in
  let sa = sin rad in
  shape ~x:((ca * x) + (sa * y)) ~y:((neg sa * x) + (ca * y)) ~z
;;

(* TODO: distortion functions *)

(* TODO: revolve *)
(* TODO: twirls *)
