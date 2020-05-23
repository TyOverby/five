open struct
  include Five.Dim3
  include Five.Csg
  include Five.Transform
  include Five.Value

  let c = Five.Value.const
end

(*
let final =
  blend_difference
    ~amount:(c 1.0)
    (sphere ~r:(c 1.0))
    (sphere ~r:(c 1.0) |> move ~dx:(c 1.0))

    *)

let clamp ~low ~high v = v |> max low |> min high
let lerp x = x
let ease_in_out_sin v = neg ((cos (c Float.pi * v) - c 1.0) / c 2.0)
let ease_out_sin v = c 1.0 - (cos (c Float.pi * v) / c 2.0)
let ease_in_quad = square

let remap f ~i_low ~i_high ~o_low ~o_high v =
  let v = clamp ~low:i_low v ~high:i_high in
  let v = (v - i_low) / (i_high - i_low) in
  o_low + (f v * (o_high - o_low))
;;

let remap'
    ?(using = lerp)
    ~on
    ~domain:(i_low, i_high)
    ~range:(o_low, o_high)
    ~f
    ()
    ~x
    ~y
    ~z
  =
  let v = on ~x ~y ~z in
  let r = remap using ~i_low ~i_high ~o_low ~o_high v in
  f r ~x ~y ~z
;;

let height = 15.0
let handle = 6.0
let thickness = 0.5
let ( => ) a b = a, b

let ( ||> ) a b ~x ~y ~z =
  let x, y, z = a ~x ~y ~z in
  b ~x ~y ~z
;;

let just_z ~x:_ ~y:_ ~z = z

module Space = struct
  type v = Five.Value.t

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
      ?(using = lerp)
      ~domain:(i_low, i_high)
      ~range:(o_low, o_high)
      on
    =
    remap using ~i_low ~i_high ~o_low ~o_high on
  ;;

  let interpolate
      ?using
      ~domain:(i_low, i_high)
      ~range:(o_low, o_high)
      on
    =
    interpolate'
      ?using
      ~domain:(c i_low, c i_high)
      ~range:(c o_low, c o_high)
      on
  ;;

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
end

let wand =
  let open Space in
  let narrow_down ~x ~y ~z =
    let scale =
      interpolate ~domain:(handle => height) ~range:(1.0 => 0.35) z
    in
    x / scale, y / scale, z
  in
  let spin ~x ~y ~z =
    let rad =
      interpolate
        ~using:(fun a -> a * a)
        ~domain:(handle => height)
        ~range:(0.0 => Float.pi *. 1.5)
        z
    in
    let ca = cos rad in
    let sa = sin rad in
    (ca * x) + (sa * y), (neg sa * x) + (ca * y), z
  in
  let* () = warp_space narrow_down in
  let* () = warp_space spin in
  let* roundness =
    let+ z = z in
    interpolate
      ~using:(fun a -> a * a * a)
      ~domain:(handle => height)
      ~range:(0.10 => 0.25)
      z
  in
  shape
    (rounded_box
       ~r:roundness
       ~min_x:(c (-0.25))
       ~min_y:(c (-0.25))
       ~min_z:(c 0.0)
       ~max_x:(c 0.25)
       ~max_y:(c 0.25)
       ~max_z:(c height))
;;

let _final =
  (* scale *)
  remap'
    ~on:just_z
    ~domain:(c handle => c height)
    ~range:(c 1.0 => c 0.35)
    ~f:(fun s ~x ~y ~z -> x / s, y / s, z)
    ()
  ||> remap'
        ~on:just_z
        ~using:(fun a -> a * sqrt a)
        ~domain:(c handle => c height)
        ~range:(c 0.0 => c (Float.pi *. 1.5))
        ~f:(fun rad ~x ~y ~z ->
          let ca = cos rad in
          let sa = sin rad in
          let x = (ca * x) + (sa * y)
          and y = (neg sa * x) + (ca * y) in
          x, y, z)
        ()
  ||> remap'
        ~on:just_z
        ~using:(fun a -> a * a * a)
        ~domain:(c handle => c height)
        ~range:(c 0.09 => c 0.25)
        ~f:(fun r ->
          rounded_box
            ~r
            ~min_x:(c (-0.25))
            ~min_y:(c (-0.25))
            ~min_z:(c 0.0)
            ~max_x:(c 0.25)
            ~max_y:(c 0.25)
            ~max_z:(c height))
        ()
;;

let final ~x ~y ~z =
  let r, _, _, _ = Space.eval wand ~x ~y ~z in
  r
;;

let expr =
  final
    ~x:Five.Value.Global_x
    ~y:Five.Value.Global_y
    ~z:Five.Value.Global_z
;;

let () = print_endline (Five_expr.to_string expr)

open Five_sys

let final = conv expr

let () =
  save_slice
    ~tree:final
    ~region:
      (Region2.create
         ~min_x:(-2.0)
         ~max_x:2.0
         ~min_y:(-2.0)
         ~max_y:2.0)
    ~z:0.0
    ~resolution:10.0
    ~filename:"out.svg"
;;

let () =
  save_mesh
    ~tree:final
    ~region:
      (Region3.create
         ~min_x:(-1.0)
         ~max_x:1.0
         ~min_y:(-1.0)
         ~max_y:1.0
         ~min_z:(-1.0)
         ~max_z:16.0)
    ~resolution:35.0
    ~filename:"out.stl"
;;
