open! Base
open! Import

type 'a t

val eval : 'a t -> 'a
val bind : 'a t -> f:('a -> 'b t) -> 'b t
val return : 'a -> 'a t
val map : 'a t -> f:('a -> 'b) -> 'b t
val both : 'a t -> 'b t -> ('a * 'b) t
val isolated : 'a t -> 'a t
val x : v t
val y : v t
val z : v t
val set_x : v -> Base.unit t
val set_y : v -> Base.unit t
val set_z : v -> Base.unit t

val interpolate'
  :  ?using:(v -> v)
  -> domain:v * v
  -> range:v * v
  -> v
  -> v

val interpolate
  :  ?using:(v -> v)
  -> domain:Base.float * Base.float
  -> range:Base.float * Base.float
  -> v
  -> v

val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
val warp_space : (x:v -> y:v -> z:v -> v * v * v) -> unit t
val shape : (x:v -> y:v -> z:v -> 'a) -> 'a t
