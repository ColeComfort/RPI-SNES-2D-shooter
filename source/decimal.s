.globl	digits
digits:

	//multiply by 5
	add	r6,	r0,	r0, lsl #2	

	mov	r5,	#0

	ldr	r7,	=scoreInt
	digitLoop:

	mov	r4,	r6

	//take the result mod 10 (ie the first digit)
	topMod:
	cmp	r4,	#10
	subge	r4,	#10
	bge	topMod

	add	r4,	#48
	strh	r4,	[r7],	#2

	//divide by 10, shifting the number one to the right in base 10
	//http://www.sciencezero.org/index.php?title=ARM:_Division_by_10
	add 	r1,r6,r6,lsl #1
	add 	r6,r6,r1,lsl  #2
	add 	r6,r6,r1,lsl #6
	add 	r6,r6,r1,lsl #10
	mov	r6,r6,lsr #15
	//

	//do this for all 4 digits of score
	cmp	r5,	#3
	add	r5,	#1
	ble	digitLoop

	bx	lr

	
.globl	printScore
printScore:
	mov         r0, #0	     	// x coordinate
	mov 		r1, #0	    	// y coordinate
	ldr 		r2, =0xFFFF 	// white
	mov 		r5, #0      	// offset
	ldr 		r4, =CurrentScore
	
/* Draws game score */	
drawingScore:
	ldrb 		r3, [r4,r5]
	cmp 		r3, #0x0
	beq 		print
	add 		r5, #1
	push {lr}
	bl         	DrawChar
	pop {lr}
	add 		r0, #16
	b          	drawingScore
		
print:
	//Cheezy score to write black
	ldr	r4,	=scoreInt
	mov	r5,	#0
	mov	r6,	#20
	printScoreTop1:

	//write black over score
	mov	r0,	r6
	mov	r1,	#20
	ldr	r2,	=0x0000

	ldrh	r3,	[r4],	#2
	push	{ lr, r4-r12 }
	bl	DrawChar
	pop	{ lr, r4-r12 }


	add	r5,	#1
	cmp	r5,	#3
	
	suble	r6,	#10
	//loop for each character
	blo	printScoreTop1


	//Update score
	ldr	r4,	=player
	ldrh	r0,	[r4, #4]
	push	{ lr }
	bl	digits
	pop	{ lr }

	//write score in white
	ldr	r4,	=scoreInt
	mov	r5,	#0
	mov	r6,	#20
	//loop for each character
	printScoreTop:

	mov	r0,	r6
	mov	r1,	#20
	ldr	r2,	=0xFFFF

	ldrh	r3,	[r4],	#2
	push	{ lr, r4-r12 }
	bl	DrawChar
	pop	{ lr, r4-r12 }


	add	r5,	#1
	cmp	r5,	#3
	
	suble	r6,	#10
	blo	printScoreTop
	
	

	bx	lr
	
.section .data
.align 4    
CurrentScore:   .asciz "SCORE: "
