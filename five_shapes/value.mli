open! Base

type t

val to_string : t -> string
val of_string : string -> t
val const : float -> t
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
val ( ^ ) : t -> int -> t

module Private : sig
  val to_expr : t -> Five_expr.t
  val of_expr : Five_expr.t -> t
end
