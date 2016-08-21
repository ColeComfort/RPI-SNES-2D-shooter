/* Draws game introduction screen game name, authors, and option to start game
 * Will continue displaying introduction screen until a button is pressed
 */
.globl introduction
introduction:
	push 	{r4-r6, lr}
    b drawIntro

.globl introductionLoop
introductionLoop:
	ldr	r7,	=noButtons
	ldr	r7,	[r7]
	
	push {lr, r7}
	bl	getButtons
	pop	{lr, r7}

    // check if buttons were pushed

    and r0, r7
	cmp	r0,	r7
	beq	introductionLoop
	
endIntro:
	mov	r3,	#1
	
	push {lr}
	bl clearScreen
	pop {lr}
	bl top
	pop {r4-r6, lr}
	b	main
	
/* Draw game introduction at the start of the game */

drawIntro:
	push {r4-r10, lr}
	mov 		r6, r3
	mov         r0, #340    // x coordinate
	mov 		r1, #250    // y coordinate
	ldr 		r2, =0xAFE5 // colour
	mov 		r5, #0      // offset
	ldr 		r4, =GameName

/* Draws game name */	

drawingName:
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		authors
	add 		r5, #1
	bl         	DrawChar
	add 		r0, #16
	b          	drawingName

/* Draws the names of the authors */

authors:
    mov         r0, #300
	mov 		r1, #300
	ldr         r2, =0xAFE5
	mov 		r5, #0
	ldr 		r4, =authorNames

drawingAuthors:	
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		drawStart
	add 		r5, #1
	bl          DrawChar
	add 		r0, #16
	b           drawingAuthors

/* Draws the Start Game option */

drawStart:
	mov 		r0, #400
    add         r0, #8
	mov 		r1, #500
	ldr 		r2, =0xC618
	mov 		r5, #0
	ldr 		r4, =Start

drawingStart:
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		endStart
	add 		r5, #1
	bl          DrawChar
	add 		r0, #16
	b           drawingStart
	
endStart:
	mov 		r3, r6
	b 		    drawStartPointer

	

/* Pointer */
.section .text
drawStartPointer:
	x  	.req    r0
  	y  	.req    r1
	color	.req	r2
	width 	.req 	r4
	height  .req	r6

	ldr 	x, =390
	ldr 	y, =506

	mov 	r8, x
	mov 	r9, r8
	mov 	r10, y
	mov 	width, #4
	mov 	height, #4
	mov 	r5, #0
	mov 	r7, #0

pointLoop:
	mov 	x, r8
	ldr 	r2, =0xAFE5 // green
	bl 	    DrawPixel16bpp2
	add 	r5, #1
	add 	r8, #1


	cmp 	r5, width
	blt 	pointLoop
	
	mov 	r8,r9
	mov 	r5, #0
	add 	y, #1
	add 	r7, #1
	cmp 	r7, height
	blt 	pointLoop
    

donePoint:
    mov 	y, r10
	b introductionLoop

.section .data
.align 4
font:   .incbin "font.bin"
GameName:       .asciz "Generic Shooting Game"
authorNames: 	.asciz "By Cole, Gee, & Elizabeth"
Start:          .asciz "START GAME"
