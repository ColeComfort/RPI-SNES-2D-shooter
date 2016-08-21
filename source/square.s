.section .text
/*
 *	r0 - pixel X coord
 *	r1 - pixel Y coord
 *	r2 - colour (use low half-word)
*/

.globl DrawPixel16bpp2
DrawPixel16bpp2:
	push	{r4-r10}

	ldr	r3, =FrameBufferPointer
	ldr	r3, [r3]           // loading the frame buffer pointer from the data structure.

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	strh	r2,		[r3, offset]

	pop	{r4-r10}
	bx	lr

/* draws line
 * r0, size
 * r1: x
 * r2: y
 * r3: color
 */
Line:
	push	{r4-r8}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	mov	r7, r3

	mov	r8, #0
LineLoop:
	cmp	r8, r4
	beq	LineLoopEnd

	mov	r0, r5
	mov	r1, r6
	mov	r2, r7
	
	push	{ lr }
	bl	DrawPixel16bpp2
	pop	{ lr }

	add	r8, #1
	add	r5, #1
	b	LineLoop

LineLoopEnd:
	pop	{r4-r8}
	bx	lr



//Let r0 be the parameter for type
//r1 be x, r2 be y
//r0=0 is human
//r0=1 pawn
//r0=2 second monster
//r0=3 third monster
//r0=4 Bullet
//r0=5 Refresh
//r0=6	Wall half health
//r0=7	Wall full health

.globl render
render:
	push	{r4-r8}
	
	lsl	r5, r1,	#4
	lsl	r6, r2,	#4

	cmp	r0,	#4
	addeq	r5,	#4
	addeq	r6,	#4
	ldreq	r7,	=0xFFFF // color
	moveq	r4,	#8
	beq	gotoBuffer

	cmp	r0,	#6
	addeq	r5,	#4
	addeq	r6,	#4
	ldreq	r7,	=0x0FF0 // color
	moveq	r4,	#8
	beq	gotoBuffer


	mov	r4,	#16

	cmp	r0,	#0
	ldreq	r7,	=0xF000 // color
	beq	gotoBuffer
	cmp	r0,	#1
	ldreq	r7,	=0x0B00 // color
	beq	gotoBuffer
	cmp	r0,	#2
	ldreq	r7,	=0xFF00 // color
	beq	gotoBuffer
	cmp	r0,	#3
	ldreq	r7,	=0x555F // color
	beq	gotoBuffer
	cmp	r0,	#5
	ldreq	r7,	=0x0000 // color
	cmp	r0,	#7
	ldreq	r7,	=0x0FF0 // color

	gotoBuffer:

	mov	r8, #0

SquareLoop:
	cmp	r8, r4
	beq	SquareLoopEnd
	
	mov	r0, r4
	mov	r1, r5
	mov	r2, r6
	mov	r3, r7

	push	{ lr }
	bl	Line
	pop	{ lr }

	add	r8, #1
	add	r6, #1
	b	SquareLoop

SquareLoopEnd:
	
	pop	{r4-r8}
	bx	lr





