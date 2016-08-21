/*
*   Purpose of the code below is to draw the win and lose messages
*	r3 is the state
*		1 = win
*		0 = lose
*/	
.globl drawEndingScreen
drawEndingScreen:
	push    {r4-r6, lr}
	mov     r6, r3				
	cmp     r6, #0				// check whether game was won or lost
	bne     drawWin
	beq     drawLose

drawWin:						// draw win
	ldr			r0,	=408
	mov 		r1, #500
	ldr 		r2, =0xC618
	mov 		r5, #0
	ldr 		r4, =WinStr

drawingWin:						
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		doneEnd
	add 		r5, #1
	bl          DrawChar
	add 		r0, #16
	b           drawingWin

drawLose:						// draw lose
	ldr			r0,	=408
	mov 		r1, #500
	ldr 		r2, =0xC618
	mov 		r5, #0
	ldr 		r4, =LoseStr

drawingLose:
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		doneEnd
	add 		r5, #1
	bl          DrawChar
	add 		r0, #16
	b           drawingLose


doneEnd:
	pop     {r4-r6, lr}
    bx      lr

.section .data
.align 4
WinStr:         .asciz "YOU WIN!!"
LoseStr:        .asciz "YOU LOSE!!"
