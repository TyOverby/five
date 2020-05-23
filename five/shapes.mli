open! Base
open! Import

type t = x:v -> y:v -> z:v -> v

val circle : r:v -> t
val ring : ro:v -> ri:v -> t
val rect : min_x:v -> min_y:v -> max_x:v -> max_y:v -> t
val sphere : r:v -> t

val box
  :  min_x:v
  -> min_y:v
  -> min_z:v
  -> max_x:v
  -> max_y:v
  -> max_z:v
  -> t

val rounded_box
  :  r:v
  -> min_x:v
  -> min_y:v
  -> min_z:v
  -> max_x:v
  -> max_y:v
  -> max_z:v
  -> t

val extrude_z : t -> min_z:v -> max_z:v -> t
val slice : t -> at:v -> t
