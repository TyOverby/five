open struct
  include Five.Shapes
  include Five.Csg
  include Five.Transform
  include Five.Value

  let c = Five.Value.const
end

let wand =
  let open Five.Space in
  let height = 15.0 in
  let handle = 4.0 in
  let thick_2 = 0.25 in
  let* z = z in
  let scale =
    interpolate ~domain:(handle, height) ~range:(1.0, 0.35) z
  in
  let rad =
    interpolate
      ~using:Five.Interpolate.ease_in_quad
      ~domain:(handle, height)
      ~range:(Float.pi *. 2.5, 0.0)
      z
  in
  let* () = warp_space (Five.Transform.scale_x scale) in
  let* () = warp_space (Five.Transform.scale_y scale) in
  let* () = warp_space (Five.Transform.rotate_z ~rad) in
  let roundness =
    interpolate
      ~using:(fun a -> a * a * a)
      ~domain:(handle, height)
      ~range:(0.10, 0.25)
      z
  in
  shape
    (rounded_box
       ~r:roundness
       ~min_x:(c (-.thick_2))
       ~min_y:(c (-.thick_2))
       ~min_z:(c 0.0)
       ~max_x:(c thick_2)
       ~max_y:(c thick_2)
       ~max_z:(c height))
;;

let box =
  let open Five.Space in
  let height = 15.0 in
  let* y = y in
  let roundness =
    interpolate
      ~using:(fun a -> a)
      ~domain:(-0.3, 0.0)
      ~range:(0.0, 0.1)
      y
  in
  let f = y / c 2.0 in
  shape
    (rounded_box
       ~r:roundness
       ~min_x:(c (-0.5) + f)
       ~min_y:(c (-0.3))
       ~min_z:(c (-1.0) + f)
       ~max_x:(c 0.5 - f)
       ~max_y:(c 0.0)
       ~max_z:(c (height +. 1.0) - f))
;;

let final =
  Five.Space.eval
    (let open Five.Space in
    let* wand = isolated wand in
    let* box = isolated box in
    return (Five.Csg.difference box [ wand ]))
;;

let final =
  let expr = Five.Value.Private.to_expr final in
  print_endline (Five_expr.to_string expr);
  Five_sys.conv expr
;;

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
;;
