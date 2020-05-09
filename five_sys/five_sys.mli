module Region2 : sig
  type t

  val create
    :  min_x:float
    -> min_y:float
    -> max_x:float
    -> max_y:float
    -> t
end

module Region3 : sig
  type t

  val create
    :  min_x:float
    -> min_y:float
    -> min_z:float
    -> max_x:float
    -> max_y:float
    -> max_z:float
    -> t
end

module Vec2 : sig
  type t

  val create : x:float -> y:float -> t
end

module Vec3 : sig
  type t

  val create : x:float -> y:float -> z:float -> t
end

module Tree : sig
  type t

  val x : unit -> t
  val y : unit -> t
  val z : unit -> t
  val const : float -> t
  val op_nonary : int -> t
  val op_unary : int -> t -> t
  val op_binary : int -> t -> t -> t
  val opcode : string -> int
end

val save_slice
  :  tree:Tree.t
  -> region:Region2.t
  -> z:float
  -> resolution:float
  -> filename:string
  -> unit

val save_mesh
  :  tree:Tree.t
  -> region:Region3.t
  -> resolution:float
  -> filename:string
  -> unit
