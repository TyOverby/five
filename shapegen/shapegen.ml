open Core_kernel

module Gen = struct
  type t =
    | X [@quickcheck.weight 5.0]
    | Y [@quickcheck.weight 5.0]
    | Z [@quickcheck.weight 5.0]
    | Min of (t * t) [@quickcheck.weight 3.0]
    | Max of (t * t) [@quickcheck.weight 3.0]
    | Add of (t * t) [@quickcheck.weight 2.0]
    | Sub of (t * t) [@quickcheck.weight 1.0]
    | Mul of (t * t) [@quickcheck.weight 2.0]
    | Div of (t * t) [@quickcheck.weight 0.0]
    | Sin of t [@quickcheck.weight 3.0]
    | Cos of t [@quickcheck.weight 3.0]
    | Tan of t [@quickcheck.weight 0.0]
    | Sqrt of t [@quickcheck.weight 2.0]
    | Square of t [@quickcheck.weight 3.0]
    | Shell of t [@quickcheck.weight 0.0]
  [@@deriving quickcheck, sexp]

  let rec t_to_shape =
    let open Five.Value in
    function
    | X -> Private.of_expr Five_expr.Global_x
    | Y -> Private.of_expr Five_expr.Global_y
    | Z -> Private.of_expr Five_expr.Global_z
    | Add (a, b) -> add (t_to_shape a) (t_to_shape b)
    | Sub (a, b) -> sub (t_to_shape a) (t_to_shape b)
    | Mul (a, b) -> mul (t_to_shape a) (t_to_shape b)
    | Div (a, b) -> div (t_to_shape a) (t_to_shape b)
    | Min (a, b) -> min (t_to_shape a) (t_to_shape b)
    | Max (a, b) -> max (t_to_shape a) (t_to_shape b)
    | Sin t -> sin (t_to_shape t)
    | Cos t -> cos (t_to_shape t)
    | Tan t -> t_to_shape t
    | Sqrt t -> sqrt (abs (t_to_shape t))
    | Square t -> square (t_to_shape t)
    | Shell t -> max (t_to_shape t) (sub (t_to_shape t) (const 1.0))
  ;;

  let rec pred ~f x =
    f x
    ||
    match x with
    | X | Y | Z -> false
    | Add (a, b)
    | Sub (a, b)
    | Mul (a, b)
    | Div (a, b)
    | Min (a, b)
    | Max (a, b) -> pred ~f a || pred ~f b
    | Shell t | Sin t | Cos t | Tan t | Sqrt t | Square t -> pred ~f t
  ;;

  let rec depth = function
    | X | Y | Z -> 1
    | Add (a, b)
    | Sub (a, b)
    | Mul (a, b)
    | Div (a, b)
    | Min (a, b)
    | Max (a, b) -> Int.max (depth a) (depth b)
    | Shell t | Sin t | Cos t | Tan t | Sqrt t | Square t ->
      1 + depth t
  ;;

  let rec size = function
    | X | Y | Z -> 1
    | Add (a, b)
    | Sub (a, b)
    | Mul (a, b)
    | Div (a, b)
    | Min (a, b)
    | Max (a, b) -> size a + size b
    | Shell t | Sin t | Cos t | Tan t | Sqrt t | Square t ->
      1 + size t
  ;;

  let is_interesting a =
    let var_count =
      let has_x =
        pred a ~f:(function
            | X -> true
            | _ -> false)
      in
      let has_y =
        pred a ~f:(function
            | Y -> true
            | _ -> false)
      in
      let has_z =
        pred a ~f:(function
            | Z -> true
            | _ -> false)
      in
      Bool.(to_int has_x + to_int has_y + to_int has_z) > 1
    in
    let has_trig =
      pred a ~f:(function
          | Sin _ | Cos _ | Tan _ -> true
          | _ -> false)
    in
    var_count && has_trig
  ;;
end

let make_shape a =
  let open Five.Space in
  Five.Space.eval
    (let* c =
       shape
         (Five.Shapes.sphere ~r:(Five.Value.const (Float.pi *. 2.0)))
     in
     return (Five.Value.max c a))
;;

let () =
  let l = ref [] in
  Quickcheck.iter Gen.quickcheck_generator ~trials:1000 ~f:(fun x ->
      if Gen.is_interesting x then l := x :: !l);
  let l =
    !l
    |> List.filter ~f:Gen.is_interesting
    |> List.filter ~f:(fun a -> Gen.size a > 5)
    |> List.sort ~compare:(fun a b -> Gen.size a - Gen.size b)
  in
  print_s [%message (List.length l : int)];
  let x = List.nth_exn l 60 in
  print_s (Gen.sexp_of_t x);
  let shape = make_shape (Gen.t_to_shape x) in
  Five_sys.save_mesh
    ~tree:(Five_sys.conv (Five.Value.Private.to_expr shape))
    ~region:
      (Five_sys.Region3.create
         ~min_x:(-7.0)
         ~max_x:7.0
         ~min_y:(-7.0)
         ~max_y:7.0
         ~min_z:(-7.0)
         ~max_z:7.0)
    ~resolution:10.0
    ~filename:"out.stl"
;;

(*
 sigsegv: 
 - (Sin (Mul ((Sin (Cos (Sqrt X))) (Max ((Tan (Sub (X Z))) Y)))))
 - (Mul
    ((Sub ((Cos (Sin (Cos (Div (X X))))) (Sin (Max ((Mul ((Sqrt Y) Y)) X)))))
     (Div
      ((Sub (Z (Cos (Sqrt (Add (X Y))))))
      (Min ((Mul ((Sin (Mul (Z Z))) (Tan (Tan Y)))) Z))))))
 - (Sub
    ((Cos (Mul ((Max ((Div ((Cos Y) (Sub (X Y)))) (Square X))) Z)))
    (Sin (Min ((Sub ((Sqrt (Div (Y Z))) Y)) X)))))       
  - (Sub
     ((Max ((Sub ((Square (Mul (Y Z))) Y)) (Add (X (Min ((Add (X Z)) Z))))))
      (Mul ((Sqrt (Sin (Add (Z Z)))) (Min ((Sub ((Add (Y Z)) (Cos Z))) Z))))))
   *)

(*
let () =
  Five_sys.save_mesh
    ~tree:final
    ~region:
      (Five_sys.Region3.create
         ~min_x:(-2.0)
         ~max_x:2.0
         ~min_y:(-2.0)
         ~max_y:2.0
         ~min_z:(-2.0)
         ~max_z:17.0)
    ~resolution:55.0
    ~filename:"out.stl"
;;*)
