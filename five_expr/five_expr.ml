open! Base

type t =
  | Global_x
  | Global_y
  | Global_z
  | Const of float
  | Nonary of { op : string }
  | Unary of
      { op : string
      ; arg : t
      }
  | Binary of
      { op : string
      ; left : t
      ; right : t
      }

let to_string t =
  let buffer = Buffer.create 64 in
  let rec loop = function
    | Global_x -> Buffer.add_string buffer "x "
    | Global_y -> Buffer.add_string buffer "y "
    | Global_z -> Buffer.add_string buffer "z "
    | Const f ->
      Buffer.add_string buffer "c ";
      Buffer.add_string buffer (Float.to_string f);
      Buffer.add_char buffer ' '
    | Nonary { op } ->
      Buffer.add_string buffer "0 ";
      Buffer.add_string buffer op;
      Buffer.add_char buffer ' '
    | Unary { op; arg } ->
      loop arg;
      Buffer.add_string buffer "1 ";
      Buffer.add_string buffer op;
      Buffer.add_char buffer ' '
    | Binary { op; left; right } ->
      loop left;
      loop right;
      Buffer.add_string buffer "2 ";
      Buffer.add_string buffer op;
      Buffer.add_char buffer ' '
  in
  loop t;
  Buffer.contents buffer
;;

let of_string s =
  (* tokens, stack *)
  let rec loop tokens stack =
    match tokens, stack with
    | [], [ x ] -> x
    | "x" :: tokens, stack -> loop tokens (Global_x :: stack)
    | "y" :: tokens, stack -> loop tokens (Global_y :: stack)
    | "z" :: tokens, stack -> loop tokens (Global_z :: stack)
    | "0" :: op :: tokens, stack ->
      loop tokens (Nonary { op } :: stack)
    | "1" :: op :: tokens, arg :: stack ->
      loop tokens (Unary { op; arg } :: stack)
    | "2" :: op :: tokens, left :: right :: stack ->
      loop tokens (Binary { op; left; right } :: stack)
    (* Failure cases *)
    | [], [] -> failwith "One shape expected, found nothing!"
    | [], _ -> failwith "One shape expected, found more than one!"
    | [ "0" ], _ ->
      failwith "Opcode for nonary operator expected, found EOF!"
    | "1" :: _ :: _, [] ->
      failwith "Unary operator expects arguments, found none!"
    | [ "1" ], _ ->
      failwith "Opcode for unary operator expected, found EOF!"
    | "2" :: _ :: _, [ _ ] ->
      failwith "Binary operator expects arguments, found only one!"
    | "2" :: _ :: _, [] ->
      failwith "Binary operator expects arguments, found none!"
    | [ "2" ], _ ->
      failwith "Opcode for binary operator expected, found EOF!"
    | s :: _, _ -> failwith (Printf.sprintf "unexpected token %s" s)
  in
  loop (String.split s ~on:' ') []
;;
