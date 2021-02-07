open struct
  include Five.Shapes
  include Five.Csg
  include Five.Transform
  include Five.Value

  let c = Five.Value.const
end
let keycap =
  let open Five.Space in
  let* squircle = 
    shape (Five.Shapes.squircle_box ~size:(c 5.) ~p:(c 4.0)) in  
  let+ round_rect = 
    let* () = warp_space (Five.Transform.move ~dx:(c 5.0) ~dy:(c 5.0) ~dz:(c 5.0) ()) in
    shape (Five.Shapes.rounded_box ~r:(c 2.0) ~min_x:(c (-5.0)) ~min_y:(c (-5.0)) ~max_x:(c 5.0) ~max_y:(c 5.0) ~min_z:(c (-5.0)) ~max_z:(c 5.0) ) in 
  Five.Csg.smooth_union ~amount:(c 1.) 
  squircle round_rect
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
    ~resolution:15.5
    ~filename:"out.stl"
;;
