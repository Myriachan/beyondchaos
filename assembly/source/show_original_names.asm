// Show the original names of characters, to help players recognize which
// characters will join and leave according to the plot.

architecture wdc65816
include "_defs.asm"

// Use FF6 text mapping instead of ASCII.
map_ff6_menu()


// Various entry points.
reorg($C33311)
function entry_C33311 {
	jsl hook_C33311
	nop
}
exactpc($C33316)

reorg($C3335D)
function entry_C3335D {
	jsl hook_C3335D
	nop
}
exactpc($C33362)

reorg($C333A9)
function entry_C333A9 {
	jsl hook_C333A9
	nop
}
exactpc($C333AE)

reorg($C333F5)
function entry_C333F5 {
	jsl hook_C333F5
	nop
}
exactpc($C333FA)

reorg($C37973)
function entry_C37973 {
	jsl hook_C37973
}
exactpc($C37977)


// Targets of hooks.
reorg(show_original_names_start)

function hook_C33311 {
	ldx.w #$3731
	stx.b $F1
	phx
	phy
	ldx.b $6D
	ldy.w #$3959
	bra hook_thunk
}

function hook_C3335D {
	ldx.w #$3735
	stx.b $F1
	phx
	phy
	ldx.b $6F
	ldy.w #$3AD9
	bra hook_thunk
}

function hook_C333A9 {
	ldx.w #$3739
	stx.b $F1
	phx
	phy
	ldx.b $71
	ldy.w #$3C59
	bra hook_thunk
}

function hook_C333F5 {
	ldx.w #$373D
	stx.b $F1
	phx
	phy
	ldx.b $73
	ldy.w #$3DD9
	bra hook_thunk
}

function hook_C37973 {
	// Switch to palette 1 temporarily.
	lda.b #$20
	sta.b $29
	jsl local_thunk
	// Restore palette.
	lda.b #$24
	sta.b $29
	rtl
local_thunk:
	phx
	phy
	ldx.b $67
	ldy.w #$3A5F
	bra hook_thunk
}

// Yet another thunk layer.
function hook_thunk {
	// Switch to direct page 1500 for the main routine.
	tdc
	phd
	pea $1500
	pld
	// Write parameters to memory locations.
	stx.b $08
	sty.b $0A
	jsl main_routine
	// Restore registers and return.
	pld
	ply
	plx
	rtl
}


// Finally, the main routine.
function main_routine {
	// Subtract $1600 from the character data address to get the offset.
	lda.b $09
	sec
	sbc.b #$16
	sta.b $09
	// Divide by the size of the character data (37) to get character number.
	ldx.b $08
	stx.w reg_wrdivl
	lda.b #37
	sta.w reg_wrdivb
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	// If it's not one of the ordinary 14 characters, bail.
	ldx.w reg_rddivl
	cpx.w #14
	bcs bail
	// Get offset into table.
	rep #$20
	txa
	asl
	asl
	asl
	adc.w #original_name_table_start & 0xFFFF
	// Write source offset.
	sta.b $12
	// Copy destination offset.
	lda.b $0A
	sta.b $15
	// Write source bank.
	lda.w #0
	sep #$20
	lda.b #original_name_table_start >> 16
	sta.b $14
	// Length
	lda.b #6
	sta.b $17
	// Tile attribute byte.
	lda.w $0029
	sta.b $18
	jsl $F018EE
bail:
	rtl
}

warnpc(show_original_names_start + show_original_names_size)
