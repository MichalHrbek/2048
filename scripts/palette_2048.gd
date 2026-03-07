class_name Palette2048
extends RefCounted

const PALETTE = {
	-1: Color("BBADA0"), # Bg
	0: Color("CCC0B3"), # Empty
	2: Color("EEE4DA"),
	4: Color("EDE0C8"),
	8: Color("F2B179"),
	16: Color("F59563"),
	32: Color("F67C5F"),
	64: Color("F65E3B"),
	128: Color("EDCF72"),
	256: Color("EDCC61"),
	512: Color("EDC850"),
	1024: Color("EDC53F"),
	2048: Color("EDC22E"),
	4096: Color("3E3933"),
}

static func get_color(n: int):
	if PALETTE.has(n):
		return PALETTE[n]
	
	return Color("3E3933")
