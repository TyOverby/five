open! Base
open! Import

type t = x:v -> y:v -> z:v -> v * v * v

val move : ?dx:v -> ?dy:v -> ?dz:v -> unit -> t
val reflect_x : ?pos:v -> unit -> t
val reflect_y : ?pos:v -> unit -> t
val reflect_z : ?pos:v -> unit -> t
val reflect_xy : t
val reflect_yz : t
val reflect_xz : t
val sym_x : t
val sym_y : t
val sym_z : t
val rotate_x : rad:v -> t
val rotate_y : rad:v -> t
val rotate_z : rad:v -> t
val scale_x : v -> t
val scale_y : v -> t
val scale_z : v -> t
