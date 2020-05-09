open! Base

module Value : sig
  type t = Five_expr.t =
    | Global_x
    | Global_y
    | Global_z
    | Const of Base.float
    | Nonary of { op : Base.string }
    | Unary of
        { op : Base.string
        ; arg : t
        }
    | Binary of
        { op : Base.string
        ; left : t
        ; right : t
        }

  val to_string : t -> Base.string
  val of_string : Base.string -> t
  val const : Base.float -> t
  val unary : Base.string -> t -> t
  val binary : Base.string -> t -> t -> t
  val square : t -> t
  val sqrt : t -> t
  val neg : t -> t
  val sin : t -> t
  val cos : t -> t
  val tan : t -> t
  val asin : t -> t
  val acos : t -> t
  val atan : t -> t
  val exp : t -> t
  val abs : t -> t
  val log : t -> t
  val recip : t -> t
  val add : t -> t -> t
  val mul : t -> t -> t
  val min : t -> t -> t
  val max : t -> t -> t
  val sub : t -> t -> t
  val div : t -> t -> t
  val atan2 : t -> t -> t
  val pow : t -> t -> t
  val nth_root : t -> t -> t
  val mod_ : t -> t -> t
  val ( + ) : t -> t -> t
  val ( - ) : t -> t -> t
  val ( * ) : t -> t -> t
  val ( / ) : t -> t -> t
  val ( ^ ) : t -> Base.Int.t -> t
end

type t = x:Value.t -> y:Value.t -> z:Value.t -> Value.t

module Csg : sig
  val union : t list -> t
  val intersection : t list -> t
  val inverse : t -> t
  val difference : t -> t list -> t
  val offset : t -> by:Value.t -> t
  val clearance : t -> t -> by:Value.t -> t
  val shell : t -> thickness:Value.t -> t
  val blend_expt : t -> t -> amount:Value.t -> t
  val blend_expt_unit : t -> t -> amount:Value.t -> t
  val blend_rough : t -> t -> amount:Value.t -> t
  val real_offset : t -> by:Value.t -> t
  val morph : t -> t -> by:Value.t -> t

  val blend_difference
    :  t
    -> t
    -> ?offset:Value.t
    -> amount:Value.t
    -> t
end

module Transform : sig
  val move : ?dx:Value.t -> ?dy:Value.t -> ?dz:Value.t -> t -> t
  val reflect_x : ?pos:Value.t -> t -> t
  val reflect_y : ?pos:Value.t -> t -> t
  val reflect_z : ?pos:Value.t -> t -> t
  val reflect_xy : t -> t
  val reflect_yz : t -> t
  val reflect_xz : t -> t
  val sym_x : t -> t
  val sym_y : t -> t
  val sym_z : t -> t
  val rotate_x : rad:Value.t -> t -> t
  val rotate_y : rad:Value.t -> t -> t
  val rotate_z : rad:Value.t -> t -> t
end

module Dim2 : sig
  val circle : r:Value.t -> t
  val ring : ro:Value.t -> ri:Value.t -> t

  val rect
    :  min_x:Value.t
    -> min_y:Value.t
    -> max_x:Value.t
    -> max_y:Value.t
    -> t

  val rounded_rect
    :  r:Value.t
    -> min_x:Value.t
    -> min_y:Value.t
    -> max_x:Value.t
    -> max_y:Value.t
    -> t
end

module Dim3 : sig
  val sphere : r:Value.t -> t

  val box
    :  min_x:Value.t
    -> min_y:Value.t
    -> min_z:Value.t
    -> max_x:Value.t
    -> max_y:Value.t
    -> max_z:Value.t
    -> t
end

val extrude_z : t -> min_z:Value.t -> max_z:Value.t -> t
val slice : t -> at:Value.t -> t
