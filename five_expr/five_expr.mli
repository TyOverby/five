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

val to_string : t -> string
val of_string : string -> t
