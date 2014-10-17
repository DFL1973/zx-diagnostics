;
;	ZX Diagnostics - fixing ZX Spectrums in the 21st Century
;	https://github.com/brendanalford/zx-diagnostics
;
;	Original code by Dylan Smith
;	Modifications and 128K support by Brendan Alford
;
;	This code is free software; you can redistribute it and/or
;	modify it under the terms of the GNU Lesser General Public
;	License as published by the Free Software Foundation;
;	version 2.1 of the License.
;
;	This code is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;	Lesser General Public License for more details.
;
;	testcard.asm
;	

testcard

; Relocate the test card attribute string

	ld hl, str_testcardattr
	ld de, v_testcard
	ld bc, 5
	ldir

	ld a, BORDERWHT
	out (ULA_PORT), a

	call cls
	xor a
	ld (v_row), a
	ld (v_column), a
	ld (v_attr), a

	ld b, 24

testcard_print


; Draw top third of testcard

	ld b, 8

testcard_row

	ld a, b
	dec a
	ld (v_testcard + 3), a
	push bc
	ld b, 8

testcard_col

	ld a, b
	dec a
	ld (v_testcard + 1), a

	push bc
	ld hl, v_testcard
	call print
	ld hl, str_year
	call print

	pop bc
	djnz testcard_col

	pop bc
	djnz testcard_row

	; Top third done, copy the attributes down

	ld hl, 0x5800
	ld de, 0x5900
	ld bc, 0x100
	ldir
	ld hl, 0x5900
	ld de, 0x5a00
	ld bc, 0x100
	ldir

	; Do the Diagnostics banner
	ld hl, str_testcard_banner
	call print
	ld hl, str_pageout_msg
	call print

	; Start the tone

tone_start

	call brk_check
	ld b, 1
	call testcard_tone
	jp tone_start


;
;	end of main program
;	local subroutines
;

brk_check

	ld a, 0x7f
	in a, (0xfe)
	rra
	ret c					; Space not pressed
	ld a, 0xfe
	in a, (0xfe)
	rra
	ret c					; Caps shift not pressed

	jp restart				; Page out and restart the machine	

; Sounds a tone followed by a pause
; Mimics the tone generated by the ROM test card routine in +2/+3 machines

testcard_tone
;	L register contains border colour to use
	ld l, 7
	BEEP 0x98, 0x380
	ld a, 0xff
	ld b, a
	xor a
	ld c, a
testcard_tone_delay
	nop
	nop
	nop
	nop
	nop
	dec bc
	ld a, b
	or c
	jr nz, testcard_tone_delay
	ret
	  
;	The ZX Spectrum Diagnostics Banner 

str_testcardattr
	defb	PAPER, 0, INK, 0, 0
str_year
	defb	BRIGHT, 0, "20", BRIGHT, 1, "14", 0

str_testcard
	defb	PAPER, 0, "    ", PAPER, 1, "    ", PAPER, 2, "    ", PAPER, 3, "    "
	defb	PAPER, 4, "    ", PAPER, 5, "    ", PAPER, 6, "    ", PAPER, 7, "    ", 0
str_pageout_msg
	defb	AT, 22, 6, PAPER, 0, INK, 7, BRIGHT, 1, " Hold BREAK to exit ", 0
str_testcard_banner
	defb	AT, 18, 0, PAPER, 0, INK, 7, BRIGHT, 1
	defb    "                          " 
	defb	TEXTNORM, PAPER, 0, INK, 2, "~", PAPER, 2, INK, 6, "~", PAPER, 6, INK, 4, "~"
	defb	PAPER, 4, INK, 5, "~", PAPER, 5, INK, 0, "~", PAPER, 0, INK, 7, " "
	defb    TEXTBOLD, " ZX Spectrum Diagnostics "
	defb	TEXTNORM, PAPER, 0, INK, 2, "~", PAPER, 2, INK, 6, "~", PAPER, 6, INK, 4, "~"
	defb	PAPER, 4, INK, 5, "~", PAPER, 5, INK, 0, "~", PAPER, 0,"  "
	defb    "                        "
	defb	TEXTNORM, PAPER, 0, INK, 2, "~", PAPER, 2, INK, 6, "~", PAPER, 6, INK, 4, "~"
	defb	PAPER, 4, INK, 5, "~", PAPER, 5, INK, 0, "~", PAPER, 0,"   "

	defb	ATTR, 56, 0
      