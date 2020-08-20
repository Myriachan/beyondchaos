// Show the original names of characters, to help players recognize which
// characters will join and leave according to the plot.

architecture wdc65816
include "_defs.asm"

// Use FF6 text mapping instead of ASCII.
map_ff6_menu()

reorg(original_name_table_start)
function table {
	// Exactly 8 bytes per entry
	db "TERRA   "
	db "LOCKE   "
	db "CYAN    "
	db "SHADOW  "
	db "EDGAR   "
	db "SABIN   "
	db "CELES   "
	db "STRAGO  "
	db "RELM    "
	db "SETZER  "
	db "MOG     "
	db "GAU     "
	db "GOGO    "
	db "UMARO   "
exactpc(original_name_table_start + original_name_table_size)
}
