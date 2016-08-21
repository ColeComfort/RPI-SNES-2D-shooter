/*
*  Draws the menu that appears after the start button is pressed
*	r3 is the option:
*		 0 is resume
*	     1 is restart
*        2 is quit
*/

.globl drawStartMenu
drawStartMenu:
	push {r4-r10, lr}
	mov r6, r3          

	mov r0, #320 // width 
	mov r1, #192 // height
	ldr r2, =0xC618
	bl drawMenuBox

	// draw vertical border
	mov r0, #320
	mov r1, #192
	ldr r2, =0xAFE5 
	bl drawVerticalBorder
	ldr r0, =640
	mov r1, #192
	ldr r2, =0xAFE5	
	bl drawVerticalBorder
	
	// draw horizontal border
	mov r0, #320
	mov r1, #192
	ldr r2, =0xAFE5
	bl drawHorizontalBorder
	mov r0, #320
	mov r1, #384
	ldr r2, =0xAFE5 
	bl drawHorizontalBorder

	mov r3, r6
	bl drawPointer

	mov r0, #400
    add r0, #50
	mov r1, #220
	ldr r2, =0x0000
	mov r5, #0
	ldr r4, =Name

loop:	
	ldrb r3, [r4,r5]
	cmp r3, #0x0
	beq resume
	add r5, #1
	bl DrawChar
	add r0, #16
	b loop


/*Draws resume game*/

resume:
	mov r0, #384
	mov r1, #300
	ldr r2, =0x0
	mov r5, #0
	ldr r4, =Resume

resumeLoop:
	ldrb r3, [r4,r5]
	cmp r3, #0x0
	beq restart
	add r5, #1
	bl DrawChar
	add r0, #16
	b resumeLoop

/* Draws restart game */

restart:
	mov r0, #384
	mov r1, #300
    add r1, #20
	ldr r2, =0x0
	mov r5, #0
	ldr r4, =Restart

restartLoop:	
	
	ldrb r3, [r4,r5]
	cmp r3, #0x0
	beq quit
	add r5, #1
	bl DrawChar
	add r0, #16
	b restartLoop

/* Draws quit game */

quit:
	mov r0, #384
	ldr r1, =340
	ldr r2, =0x0
	mov r5, #0
	ldr r4, =Quit
    
quitLoop:	
	ldrb r3, [r4,r5]
	cmp r3, #0x0
	beq endStart
	add r5, #1
	bl DrawChar
	add r0, #16
	b quitLoop
	
	
endStart:
	pop {r4-r10, lr}
	bx lr


.globl drawMenuBox
.section .text
drawMenuBox:							// draws menu box
	x  .req    r0
  	y  .req    r1
	color	.req	r2
	width 	.req 	r4
	height  .req	r6
	push {r4-r10, lr}
	mov r8, x
	mov r9, r8
	mov r10, y
	mov width, #320
	mov height, #192
	mov r5, #0
	mov r7, #0


drawLoop:
	mov x, r8
    bl DrawPixel16bpp2
    add r5, #1
    add r8, #1
       
	cmp r5, width
    blt drawLoop

	mov r8,r9
	mov r5, #0
	add y, #1
	add r7, #1
	cmp r7, height
	blt drawLoop

done:
mov y, r10
	pop {r4-r10, lr}
	bx lr

.globl drawHorizonalBorder
.section .text
drawHorizontalBorder:
	x  .req    r0
  	y  .req    r1
	color	.req	r2
	width 	.req 	r4
	height  .req	r6
	push {r4-r10, lr}
	mov r8, x
	mov r9, r8
	mov r10, y
	mov width, #320
	mov height, #2
	mov r5, #0
	mov r7, #0

horizontalLoop:
	mov x, r8
    bl DrawPixel16bpp2
    add r5, #1
    add r8, #1

	cmp r5, width
    blt horizontalLoop
	
	mov r8,r9
	mov r5, #0
	add y, #1
	add r7, #1
	cmp r7, height
	blt horizontalLoop

doneHorizontal:
    mov y, r10
	pop {r4-r10, lr}
	bx lr



.globl drawVerticalBorder
.section .text
drawVerticalBorder:
	
	x  .req    r0
  	y  .req    r1
	color	.req	r2
	width 	.req 	r4
	height  .req	r6
	push {r4-r10, lr}
	mov r8, x
	mov r9, r8
	mov r10, y
	mov width, #2
	mov height, #192
	mov r5, #0
	mov r7, #0


verticalLoop:
	mov x, r8
    bl DrawPixel16bpp2
    add r5, #1
    add r8, #1

       
	cmp r5, width
    blt verticalLoop
	
	mov r8,r9
	mov r5, #0
	add y, #1
	add r7, #1
	cmp r7, height
	blt verticalLoop

doneVertical:
	mov y, r10
	pop {r4-r10, lr}
	bx lr


/* Draw points */
.globl drawPointer
.section .text
drawPointer:


	x  .req    r0
  	y  .req    r1
	state   .req    r3
	width 	.req 	r4
	height  .req	r6
	push {r4-r10, lr}

    cmp state, #0   // if state == 0, then resume
    ldreq x, =375
    ldreq y, =305

    cmp state, #1   // if state == 1, then restart
    ldreq x, =375
    ldreq y, =325

    cmp state, #2   // if state == 2, then quit
    ldreq x, =375
    ldreq y, =345

	mov r8, x
	mov r9, r8
	mov r10, y
	mov width, #4
	mov height, #4
	mov r5, #0
	mov r7, #0


pointLoop:
	mov x, r8
    bl DrawPixel16bpp2
    add r5, #1
    add r8, #1

	cmp r5, width
    blt pointLoop
	
	mov r8,r9
	mov r5, #0
	add y, #1
	add r7, #1
	cmp r7, height
	blt pointLoop

    
donePoint:
mov y, r10
pop {r4-r10, lr}
bx lr

.section .data
.align 4
Name:           .asciz "Menu"
Resume:         .asciz "Resume Game"
Restart:        .asciz "Restart Game"
Quit:           .asciz "Quit Game"



