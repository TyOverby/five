open! Import

val union : v list -> v
val intersection : v list -> v
val inverse : v -> v
val difference : v -> v list -> v
val offset : v -> by:v -> v
val clearance : v -> v -> by:v -> v
val shell : v -> thickness:v -> v
val blend_expt : v -> v -> amount:v -> v
val blend_expt_unit : v -> v -> amount:v -> v
val blend_rough : v -> v -> amount:v -> v
val real_offset : v -> by:v -> v
val morph : v -> v -> by:v -> v
val blend_difference : ?offset:v -> v -> v -> amount:v -> v
