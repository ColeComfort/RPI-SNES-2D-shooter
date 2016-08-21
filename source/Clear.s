.globl clearScreen
clearScreen:
	push {r4-r10, lr}
	x       .req    r0
  	y       .req    r1
	color	.req	r2
	width 	.req 	r4
	height  .req	r6

	cmp r3, #0				//compare value to determine state to draw
	beq	ResumeGame

	cmp	r3, #1
	beq RestartGame

RestartGame:				//draw entire screen to black if user selected restart
	ldr x, =0
	ldr y, =0
	ldr color, =0x0000
	mov r8, x
	mov r9, r8
	mov r10, y
	ldr width, =1024
	ldr height, =768
	mov r5, #0
	mov r7, #0
	b clearLoop


ResumeGame:					//continue as normal if user selected resume
	ldr x, =320
	ldr y, =192
	ldr color, =0x0000
	mov r8, x
	mov r9, r8
	mov r10, y
	ldr width, =322
	ldr height, =194
	mov r5, #0
	mov r7, #0

clearLoop:					//loop for drawing over colors
    mov x, r8
    bl DrawPixel16bpp2
    add r5, #1
    add r8, #1
   
    cmp r5, width
    blt clearLoop

    mov r8,r9
    mov r5, #0
	add y, #1
	add r7, #1
    cmp r7, height
    blt clearLoop

done:
    mov y, r10
	pop {r4-r10, pc}
	bx lr
