open! Base
open! Import
open Value

let c = const
let clamp ~low ~high v = v |> max low |> min high
let lerp x = x
let ease_in_out_sin v = neg ((cos (c Float.pi * v) - c 1.0) / c 2.0)
let ease_in_sin v = c 1.0 - (cos (c Float.pi * v) / c 2.0)
let ease_in_quad = square
let ease_in_circ v = c 1.0 - sqrt (c 1.0 - square v)

let remap f ~i_low ~i_high ~o_low ~o_high v =
  let v = clamp ~low:i_low v ~high:i_high in
  let v = (v - i_low) / (i_high - i_low) in
  o_low + (f v * (o_high - o_low))
;;
