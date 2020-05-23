open! Base
open! Import
open Value

type _ t =
  | Return : 'a -> 'a t
  | Bind :
      { t : 'a t
      ; f : 'a -> 'b t
      }
      -> 'b t
  | Isolated : 'a t -> 'a t
  | Map :
      { t : 'a t
      ; f : 'a -> 'b
      }
      -> 'b t
  | Both :
      { a : 'a t
      ; b : 'b t
      }
      -> ('a * 'b) t
  | X : v t
  | Y : v t
  | Z : v t
  | Set_x : v -> unit t
  | Set_y : v -> unit t
  | Set_z : v -> unit t

let rec eval : type a. a t -> x:v -> y:v -> z:v -> a * v * v * v =
 fun v ~x ~y ~z ->
  match v with
  | Return a -> a, x, y, z
  | Bind { t; f } ->
    let o, x, y, z = eval t ~x ~y ~z in
    eval (f o) ~x ~y ~z
  | Map { t; f } ->
    let o, x, y, z = eval t ~x ~y ~z in
    f o, x, y, z
  | Both { a; b } ->
    let a, x, y, z = eval a ~x ~y ~z in
    let b, x, y, z = eval b ~x ~y ~z in
    (a, b), x, y, z
  | Isolated t ->
    let o, _, _, _ = eval t ~x ~y ~z in
    o, x, y, z
  | X -> x, x, y, z
  | Y -> y, x, y, z
  | Z -> z, x, y, z
  | Set_x x -> (), x, y, z
  | Set_y y -> (), x, y, z
  | Set_z z -> (), x, y, z
;;

let eval a =
  let r, _, _, _ =
    eval
      a
      ~x:(Value.Private.of_expr Five_expr.Global_x)
      ~y:(Value.Private.of_expr Five_expr.Global_y)
      ~z:(Value.Private.of_expr Five_expr.Global_z)
  in
  r
;;

let bind t ~f = Bind { t; f }
let return x = Return x
let map t ~f = Map { t; f }
let both a b = Both { a; b }
let isolated t = Isolated t
let x = X
let y = Y
let z = Z
let set_x a = Set_x a
let set_y a = Set_y a
let set_z a = Set_z a

let interpolate'
    ?(using = fun x -> x)
    ~domain:(i_low, i_high)
    ~range:(o_low, o_high)
    on
  =
  Interpolate.remap using ~i_low ~i_high ~o_low ~o_high on
;;

let interpolate
    ?using
    ~domain:(i_low, i_high)
    ~range:(o_low, o_high)
    on
  =
  interpolate'
    ?using
    ~domain:(const i_low, const i_high)
    ~range:(const o_low, const o_high)
    on
;;

include Base.Monad.Make (struct
  type nonrec 'a t = 'a t

  let map = `Custom map
  let bind = bind
  let return = return
end)

let ( let+ ) a f = map a ~f
let ( let* ) a f = bind a ~f
let ( and+ ) a b = both a b

let warp_space f =
  let* x = x in
  let* y = y in
  let* z = z in
  let x, y, z = f ~x ~y ~z in
  let* () = set_x x in
  let* () = set_y y in
  let* () = set_z z in
  return ()
;;

let shape f =
  let* x = x in
  let* y = y in
  let* z = z in
  return (f ~x ~y ~z)
;;
