open struct
  include Five.Shapes
  include Five.Csg
  include Five.Transform
  include Five.Value

  let c = Five.Value.const
end
let keycap =
  let open Five.Space in
  let height = 10.0 in
  let thick_2 = 10.00 in
  let uniform_wall_thickness = 1.00 in
  let* z = z in
  let dist_from_center = 
    let open Five.Value in 
    let+ x = x and+ y = y in 
    sqrt (square x + square y)
  in
  let scale_xy = interpolate ~domain:(0.0, height) ~range:(1.0, 0.75) z in
  let* scale_z =
    let+ x = x and+ dist_from_center = dist_from_center in
    let for_slant_x = interpolate ~domain:(-. thick_2, thick_2) ~range:(1.0, 0.7) x in 
    let for_dish = interpolate ~using:Five.Value.square ~domain:(0.0, thick_2) ~range:(0.7, 1.0) dist_from_center in 
    for_slant_x * for_dish
  in
  let* () = warp_space (Five.Transform.scale_x scale_xy) in
  let* () = warp_space (Five.Transform.scale_y scale_xy) in
  let* () = warp_space (Five.Transform.scale_z scale_z) in 
  let roundness = interpolate ~domain:(0.0, height) ~range:(0.10, 4.0) z in
  let main_shape ~is_outer = shape (rounded_box
    ~r:roundness
    ~min_x:(c (-.thick_2))
    ~min_y:(c (-.thick_2))
    ~min_z:(c (if is_outer then 0.0 else (-. uniform_wall_thickness *. 2.)))
    ~max_x:(c thick_2)
    ~max_y:(c thick_2)
    ~max_z:(c height)) 
  in
  let* outer = main_shape ~is_outer:true in
  let* inner = main_shape ~is_outer:false in
  let keycap = Five.Csg.difference outer [Five.Csg.offset inner ~by:(c (-. uniform_wall_thickness)) ] in 
  return keycap
;;


let final =
  Five.Space.eval
    (let open Five.Space in
    let* wand = isolated keycap in
    return wand)
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
         ~min_x:(-15.0)
         ~max_x:15.0
         ~min_y:(-15.0)
         ~max_y:15.0
         ~min_z:(-15.0)
         ~max_z:15.0)
    ~resolution:10.5
    ~filename:"out.stl"
;;
