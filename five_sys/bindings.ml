open! Ctypes

let () =
  let os_name =
    let ic = Unix.open_process_in "uname" in
    let uname = input_line ic in
    let () = close_in ic in
    uname
  in
  ignore
    (match os_name with
     | "Darwin" -> Dl.dlopen ~filename:"libfive.dylib" ~flags:[]
     | _ -> Dl.dlopen ~filename:"libfive.so" ~flags:[]
      : _)
;;

module Interval = struct
  type s

  let t : s structure typ = structure "interval"
  let f_lower = field t "lower" float
  let f_upper = field t "upper" float
  let () = seal t

  let create ~lower ~upper =
    let r = make t in
    setf r f_lower lower;
    setf r f_upper upper;
    r
  ;;
end

module Region2 = struct
  type s
  type t = s structure

  let t : s structure typ = structure "region2"
  let f_x = field t "X" Interval.t
  let f_y = field t "Y" Interval.t
  let () = seal t

  let create ~min_x ~min_y ~max_x ~max_y =
    let r = make t in
    setf r f_x (Interval.create ~lower:min_x ~upper:max_x);
    setf r f_y (Interval.create ~lower:min_y ~upper:max_y);
    r
  ;;
end

module Region3 = struct
  type s
  type t = s structure

  let t : s structure typ = structure "region3"
  let f_x = field t "X" Interval.t
  let f_y = field t "Y" Interval.t
  let f_z = field t "Z" Interval.t
  let () = seal t

  let create ~min_x ~min_y ~min_z ~max_x ~max_y ~max_z =
    let r = make t in
    setf r f_x (Interval.create ~lower:min_x ~upper:max_x);
    setf r f_y (Interval.create ~lower:min_y ~upper:max_y);
    setf r f_z (Interval.create ~lower:min_z ~upper:max_z);
    r
  ;;
end

module Vec2 = struct
  type s
  type t = s structure

  let t : s structure typ = structure "vec2"
  let f_x = field t "x" float
  let f_y = field t "y" float
  let () = seal t

  let create ~x ~y =
    let r = make t in
    setf r f_x x;
    setf r f_y y;
    r
  ;;
end

module Vec3 = struct
  type s
  type t = s structure

  let t : s structure typ = structure "vec3"
  let f_x = field t "x" float
  let f_y = field t "y" float
  let f_z = field t "z" float
  let () = seal t

  let create ~x ~y ~z =
    let r = make t in
    setf r f_x x;
    setf r f_y y;
    setf r f_z z;
    r
  ;;
end

module Tree = struct
  type s
  type t = s structure ptr

  let t : s structure typ = structure "tree"
  let x = Foreign.foreign "libfive_tree_x" (void @-> returning (ptr t))
  let y = Foreign.foreign "libfive_tree_y" (void @-> returning (ptr t))
  let z = Foreign.foreign "libfive_tree_z" (void @-> returning (ptr t))

  let const =
    Foreign.foreign "libfive_tree_const" (float @-> returning (ptr t))
  ;;

  let op_nonary =
    Foreign.foreign "libfive_tree_nonary" (int @-> returning (ptr t))
  ;;

  let op_unary =
    Foreign.foreign
      "libfive_tree_unary"
      (int @-> ptr t @-> returning (ptr t))
  ;;

  let op_binary =
    Foreign.foreign
      "libfive_tree_binary"
      (int @-> ptr t @-> ptr t @-> returning (ptr t))
  ;;

  let opcode =
    Foreign.foreign "libfive_opcode_enum" (string @-> returning int)
  ;;

  let opcode name =
    match opcode name with
    | -1 -> failwith (Printf.sprintf "%s is not an opcode" name)
    | other -> other
  ;;
end

let save_slice =
  Foreign.foreign
    "libfive_tree_save_slice"
    (ptr Tree.t
    @-> Region2.t
    @-> float
    @-> float
    @-> string
    @-> returning void)
;;

let save_slice ~tree ~region ~z ~resolution ~filename =
  save_slice tree region z resolution filename
;;

let save_mesh =
  Foreign.foreign
    "libfive_tree_save_mesh"
    (ptr Tree.t @-> Region3.t @-> float @-> string @-> returning void)
;;

let save_mesh ~tree ~region ~resolution ~filename =
  save_mesh tree region resolution filename
;;
