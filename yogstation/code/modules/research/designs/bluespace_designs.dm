/datum/design/bluespace_pipe
	name = "Bluespace Pipe"
	desc = "A pipe that teleports gases."
	id = "bluespace_pipe"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1000, MAT_DIAMOND = 750, MAT_URANIUM = 250, MAT_BLUESPACE = 2000)
	build_path = /obj/item/pipe/bluespace
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/disposal_bluespace
	name = "Machine Design (Bluespace Disposal Attachment Board)"
	desc = "The circuit board for a bluespace disposal attachment."
	id="disposal_bluespace"
	build_path = /obj/item/circuitboard/machine/disposal_bluespace
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING
