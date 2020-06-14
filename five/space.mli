open! Import

(** The Space monad is a monad that tracks the transformation of 
    3d space. 

    example:
    [{
      let* () = warp_space (Transform.rotate_x ~rad:(Value.const 5.0)) in
      let* () = warp_space (Transform.move ~dx:(Value.const 2.0) () in 
      shape (Shapes.box ...)
    }] *)

type 'a t

include Base.Monad.S with type 'a t := 'a t

(** Evaluates the space monad returning the value that 
    has been computed.  This function should only be used when 
    passing the final [value] off to [Five_sys].  *)
val eval : v t -> v

(** Takes a computation and prevents the spatial warping effects
    from effecting anything else. 

    [{
      let* a = isolated (...) in
      (* spatial warping computed during [a] will not affect [b] *)
      let* b = ...
    }] *)
val isolated : 'a t -> 'a t

(** Reads the current [x] value from space. *)
val x : v t

(** Reads the current [y] value from space. *)
val y : v t

(** Reads the current [z] value from space. *)
val z : v t

(** Sets the current [x] value. *)
val set_x : v -> unit t

(** Sets the current [y] value. *)
val set_y : v -> unit t

(** Sets the current [z] value. *)
val set_z : v -> unit t

(** Given a domain: [(domain_start, domain_end)] 
    and range: [(range_start, range_end)]
    [interpolate] transforms a value [v] according to the following:

    {v
       v <= domain_start -> range_start
       v >= domain_end   -> range_end
       otherwise         -> inbetween range_start and range_end
    v}

    When inbetween [domain_start] and [domain_end], the output is 
    computed via the [using] optional parameter.

    [using] should be a smooth function where 
    [using (const 0.0) = const 0.0] and 
    [using (const 1.0) = const 1.0]

    [using] defaults to [fun x -> x], but all of the functions from
    the [Interpolate] module can be used instead.

    Using this function, [interpolate] will interpolate its input value
    from [range_start] to [range_end]. *)
val interpolate
  :  ?using:(v -> v)
  -> domain:float * float
  -> range:float * float
  -> v
  -> v

(** Same as [interpolate] but the domain and 
    range are parameterizable. *)
val interpolate'
  :  ?using:(v -> v)
  -> domain:v * v
  -> range:v * v
  -> v
  -> v

(** Syntax helpers for using the Space monad. *)
val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t

(** Applies the transformation to the space, returning unit. *)
val warp_space : Transform.t -> unit t

(** Evaluates the shape in current space. *)
val shape : Shapes.t -> v t
