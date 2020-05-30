open! Import
open Value

let rec union shapes =
  match shapes with
  | [] -> failwith "union with zero arguments!"
  | [ a ] -> a
  | a :: rest -> min a (union rest)
;;

let rec intersection shapes =
  match shapes with
  | [] -> failwith "intersection with zero arguments!"
  | [ a ] -> a
  | a :: rest -> max a (intersection rest)
;;

let inverse = neg

let difference a = function
  | [] -> a
  | l -> intersection [ a; inverse (union l) ]
;;

let offset shape ~by = shape - by
let clearance a b ~by = difference a [ offset b ~by ]
let shell shape ~thickness = clearance shape shape ~by:thickness

let blend_expt a b ~amount =
  let m = amount in
  neg (log (exp (neg m * a) + exp (neg m * b))) / m
;;

let blend_expt_unit a b ~amount =
  blend_expt a b ~amount:(const 2.75 / (amount * amount))
;;

let blend_rough a b ~amount =
  let c = sqrt (abs a) + sqrt (abs b) - amount in
  min a (min b c)
;;

let real_offset = offset

let blend_difference ?(offset = const 0.0) a b ~amount =
  inverse
    (blend_expt_unit (inverse a) (real_offset b ~by:offset) ~amount)
;;

let morph a b ~by =
  let m = by |> min (const 0.0) |> max (const 1.0) in
  (a * (const 1.0 - m)) + (b * m)
;;

(* loft *)
