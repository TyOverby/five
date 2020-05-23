open! Base
open! Import

val clamp : low:v -> high:v -> v -> v
val lerp : 'a -> 'a
val ease_in_out_sin : v -> v
val ease_out_sin : v -> v
val ease_in_quad : v -> v

val remap
  :  (v -> v)
  -> i_low:v
  -> i_high:v
  -> o_low:v
  -> o_high:v
  -> v
  -> v
