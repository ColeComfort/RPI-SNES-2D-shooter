
/* 
Draw the character to a coordinate
	r0 - x
	r1 - y
	r2 - colour
	r3 - character
Some of this code taken from tutorial #9
Changes: takes inputs on characters and location
 */


.globl DrawChar

DrawChar:
	push	{r4-r10, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		// load the address of the font map
	
	add		chAdr,	r3, lsl #4	// char address = font base + (char * 16)
	mov r10, r1
	mov		py,		r10			// init the Y coordinate (pixel coordinate)
	mov		r9,		r0

charLoop$:
	mov		px,		r9			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	
	bl		DrawPixel16bpp2			// draw red pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$
Yaxis:
	add		py,		#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	mov r0, r9
	mov r1, r10
	pop		{r4-r10, pc}

.section .data
.align 4
font:		.incbin	"font.bin"



