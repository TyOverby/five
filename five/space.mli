open! Import

type 'a t

include Base.Monad.S with type 'a t := 'a t

val eval : 'a t -> 'a
val isolated : 'a t -> 'a t
val x : v t
val y : v t
val z : v t
val set_x : v -> unit t
val set_y : v -> unit t
val set_z : v -> unit t

val interpolate'
  :  ?using:(v -> v)
  -> domain:v * v
  -> range:v * v
  -> v
  -> v

val interpolate
  :  ?using:(v -> v)
  -> domain:float * float
  -> range:float * float
  -> v
  -> v

val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
val warp_space : Transform.t -> unit t
val shape : Shapes.t -> v t
