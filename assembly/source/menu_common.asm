// Common library used by menu enhancements

architecture wdc65816
include "_defs.asm"

// Use FF6 text mapping instead of ASCII.
map_ff6_menu()


reorg($F01821)

// Get the name of an attack.
// D+$38 = attack ID.
// output A = length of string.
// output X = offset of string (bank E6).
function Get_attack_name {
	lda.b $38
	stz.b $39
	// Spell?
	cmp.b #$36
	bcc get_spell_attack_name
	// Esper?
	cmp.b #$51
	bcc get_esper_attack_name
	// Skean?
	cmp.b #$55
	bcc to_get_other_attack_name
	// SwdTech?
	cmp.b #$5D
	bcc to_get_swdtech_name
to_get_other_attack_name:
	jmp Get_other_attack_name
to_get_swdtech_name:
	jmp Get_swdtech_name
	
	// Partially-deleted old code.
	//sbc.b #$51
	//rep #$20
	//and.w #$00FF
	//sta.b $38
	//asl
	//asl
	//adc.b $38
	//asl
	// Add offset to skill names table.
	adc.w #table_skill_names & $FFFF
	tax
	lda.w #10
	sep #$20
	rtl
	
get_esper_attack_name:
	// Optimization for later: use rep #$21
	sec
	sbc.b #$36
	rep #$20
	and.w #$00FF
	// 8 letters per name
	asl
	asl
	asl
	adc.w #table_esper_names & $FFFF
	tax
	lda.w #8
	sep #$20
	rtl

get_spell_attack_name:
	rep #$20
	and.w #$00FF
	sta.b $38
	// 7 letters per name
	asl
	asl
	asl
	adc.w #table_spell_names & $FFFF
	sec
	sbc.b $38
	tax
	lda.w #7
	sep #$20
	rtl
}


exactpc($F01871)
function jmp_write_attack_name {
	// Jump to the newer version of the code
	jmp write_attack_name
	nop
	// Old version of the code
	// Commented lines were overwritten by jmp
	//lda.b $35
	//sta.b $38
	jsl Get_attack_name
	stx.b $38
	sta.b $3D
	lda.b #$E6   // bank containing skill, etc. names
	sta.b $3A
	ldx.b $36
	stx.b $3B
	jsl old_Gui__WriteTextLength
	rtl
}


// Draws text to a VRAM shadow buffer.
// D+$20 = 24-bit source address - NUL terminated.
// D+$23 = 16-bit destination address (bank 7E).
exactpc($F0188A)
function WriteText {
	ldx.b $23
	ldy.w #0
loop:
	lda [$20],y
	beq return
	sta.l $7E0000,x
	lda.b #$20        // tile attributes
	sta.l $7E0001,x
	inx
	inx
	iny
	bra loop
return:
	rtl
}


exactpc($F018A3)
function old_Gui__WriteTextLength {
	jmp Print_attack_name
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
}


// Palette 4 draw text.
// D+$1C = 24-bit source address (NUL-terminated).
// D+$1F = 16-bit destination address (bank 7E).
exactpc($F018BC)
function unknown_F018BC {
	ldx.b $1F
	ldy.w #0
loop:
	lda [$1C],y
	beq return
	sta.l $7E0000,x
	lda.b #$30        // tile attributes
	sta.l $7E0001,x
	inx
	inx
	iny
	bra loop
return:
	rtl
}


// Arbitrary-attribute draw text.
// D+$24 = 24-bit source address (NUL-terminated).
// D+$27 = 16-bit destination address (bank 7E).
// D+$29 = 8-bit tile attribute byte for string.
exactpc($F018D5)
function unknown_F018D5 {
	ldx.b $27
	ldy.w #0
loop:
	lda [$24],y
	beq return
	sta.l $7E0000,x
	lda.b $29         // tile attributes
	sta.l $7E0001,x
	inx
	inx
	iny
	bra loop
return:
	rtl
}


// Badly named function.
// Arbitrary-attribute draw text.
// D+$12 = 24-bit source address.
// D+$15 = 16-bit destination address (bank 7E).
// D+$17 = 8-bit string length (0 means 256).
// D+$18 = 8-bit tile attribute byte for string.
exactpc($F018EE)
function WriteTextGreen {
	ldx.b $15
	ldy.w #0
loop:
	lda [$12],y
	sta.l $7E0000,x
	lda.b $18         // tile attributes
	sta.l $7E0001,x
	inx
	inx
	iny
	dec.b $17
	bne loop
	rtl
}


// More draw text functions!
exactpc($F01907)
function unknown_F01907 {
	clc
	ldx.b $1E
	ldy.b $1C
loop:
	sty.w reg_wrdivl
	lda.b #10
	sta.w reg_wrdivb
	lda.b $20
	sta.l $7E0001,x
	dex
	dex
	lda.b #$B4
	adc.w reg_rdmpyl
	sta.l $7E0002,x
	ldy.w reg_rddivl
	bne loop
	rtl
}


// Plays a sound effect
//exactpc($F0192B)
function unknown_F0192B {
	lda.b #$20
	sta.l reg_apuio0
	rtl
}
//exactpc($F01932)



reorg($F01C00)

// Draw 10-letter text.
// D+$38 = 24-bit source address.
// D+$3B = 16-bit destination address (bank 7E).
// D+$3D = 8-bit length of string.  Padded out to 10 if <10.
exactpc($F01C00)
function Print_attack_name {
	lda.b #10
	sta.b $3F
	ldx.b $3B
	ldy.w #0
loop:
	lda [$38],y
	sta.l $7E0000,x
	lda.b #$20        // tile attributes
	sta.l $7E0001,x
	inx
	inx
	iny
	dec.b $3F
	dec.b $3D
	bne loop
	
	lda.b $3F
	beq return
loop2:
	lda.b #$FF
	sta.l $7E0000,x
	lda.b #$20        // tile attributes
	sta.l $7E0001,x
	inx
	inx
	dec.b $3F
	bne loop2

return:
	rtl
}


exactpc($F01C35)
function write_attack_name {
	// Bank of $38 destination.
	lda.b #table_skill_names >> 16
	sta.b $3A
	// Get name of attack in $35.
	lda.b $35
	sta.b $38
	jsl Get_attack_name
	// Write offset and length.
	stx.b $38
	sta.b $3D
	// 
	ldx.b $36
	stx.b $3B
	jsl old_Gui__WriteTextLength
	rtl
}


exactpc($F01C4E)
function Get_other_attack_name {
	// Subtract off first skill ID.
	// Optimization for later: use rep #$21
	sec
	sbc.b #$51
	// Multiply by 10.
	rep #$20
	and.w #$00FF
	sta.b $38
	asl
	asl
	adc.b $38        // carry cleared by asl not overflowing
	asl
	adc.w #table_skill_names
	tax
	// Length.
	lda.w #10
	sep #$20
	rtl
}


exactpc($F01C67)
function Get_swdtech_name {
	// Write SwdTech name bank.
	// FIXME: Writes bank to 3A unlike every other routine!
	lda.b #table_swdtech_names >> 16
	sta.b $3A
	// Subtract off first SwdTech ID.
	// Optimization for later: use rep #$21
	// FIXME: Reloads, assuming it was in $35 the whole time.
	lda.b $35
	sec
	sbc.b #$55
	// Multiply by 12.
	rep #$20
	and.w #$00FF
	asl
	sta.b $38
	asl
	adc.b $38
	asl
	adc.w #table_swdtech_names
	tax
	// Length.
	// FIXME: Why not 12?
	lda.w #10
	sep #$20
	rtl
}
