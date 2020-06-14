open! Import

(** A transformation is represented as a function from a point 
    in 3d space to another point in 3d space.  Shapes that are
    evaluated after a transformation will use the transformed
    for distance queries.

    For example, a transformation that warps space by moving
    x coordinates by a constant value could be defined like so:
    [ fun ~x ~y ~z -> (x + constant 5), y, z ] *)
type t = x:v -> y:v -> z:v -> v * v * v

(** Translates space by [dx, dy, dz]. *)
val move : ?dx:v -> ?dy:v -> ?dz:v -> unit -> t

(** Reflects space by inverting the x coordinate.
    [pos] defaults to 0.  *)
val reflect_x : ?pos:v -> unit -> t

(** Reflects space by inverting the y coordinate.
    [pos] defaults to 0.  *)
val reflect_y : ?pos:v -> unit -> t

(** Reflects space by inverting the z coordinate.
    [pos] defaults to 0.  *)
val reflect_z : ?pos:v -> unit -> t

(** Reflects space by swapping the [x] and [y] coordinates. *)
val reflect_xy : t

(** Reflects space by swapping the [y] and [z] coordinates. *)
val reflect_yz : t

(** Reflects space by swapping the [x] and [z] coordinates. *)
val reflect_xz : t

(** Mirrors space on the x axis at the x-position [pos].  
    [pos] defaults to 0. *)
val sym_x : ?pos:v -> unit -> t

(** Mirrors space on the y axis at the y-position [pos].  
    [pos] defaults to 0. *)
val sym_y : ?pos:v -> unit -> t

(** Mirrors space on the z axis at the z-position [pos].  
    [pos] defaults to 0. *)
val sym_z : ?pos:v -> unit -> t

(** Rotates space on the x axis by a given radius. *)
val rotate_x : rad:v -> t

(** Rotates space on the y axis by a given radius. *)
val rotate_y : rad:v -> t

(** Rotates space on the z axis by a given radius. *)
val rotate_z : rad:v -> t

(* Scales space on the x axis *)
val scale_x : v -> t

(* Scales space on the y axis *)
val scale_y : v -> t

(* Scales space on the z axis *)
val scale_z : v -> t
