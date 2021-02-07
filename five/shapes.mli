open! Import

(** A shape is defined as a function from a point in 3d space to the
    distance to the edge of the shape.  A returned value of [0] means 
    that the queried point is on the edge of the shape, while a positive 
    value indicates that it was outside of the shape.  Negative values 
    signify that the point is inside the shape.

    A 2d shape is simply a 3d shape that ignores the "Z" dimension.  This
    means that if you attempt to use a 2d shape as a 3d shape, it will
    behave like an infinitely high column. *)
type t = x:v -> y:v -> z:v -> v

(** Creates a 2d cirle centered at the origin with radius [r] *)
val circle : r:v -> t

(** Creates a 2d ring centered at the origin with an inner radius of [ri] and
    an outer radius of [ro] *)
val ring : ro:v -> ri:v -> t

(** Creates a 2d rectangle with the given bounds *)
val rect : min_x:v -> min_y:v -> max_x:v -> max_y:v -> t

(** Creates a 3d sphere centered at the origin with radius [r] *)
val sphere : r:v -> t

(** Creates a 3d box with the given bounds *)
val box
  :  min_x:v
  -> min_y:v
  -> min_z:v
  -> max_x:v
  -> max_y:v
  -> max_z:v
  -> t

(** Creates a 3d box with the given bounds.  The box has rounded 
    edges that have a round-radius of [r] *)
val rounded_box
  :  r:v
  -> min_x:v
  -> min_y:v
  -> min_z:v
  -> max_x:v
  -> max_y:v
  -> max_z:v
  -> t

val squircle_box : p:v -> size:v -> t

(** Converts a 2d shape to a 3d shape by extruding it along the z
    direction *)
val extrude_z : t -> min_z:v -> max_z:v -> t

(** Converts a 2d shape to a 3d shape by slicing it on the z axis 
    on the position [at]. *)
val slice : t -> at:v -> t
