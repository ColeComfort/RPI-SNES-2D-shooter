.section .text

.equ	x, 0
.equ	y, 2
.equ	health, 4
.equ	dir, 6
.equ	points, 8
.equ	bulletX, 10
.equ	bulletY, 12
.equ	bulletAlive, 14
.equ	bulletDir, 16
.equ	type, 18
.equ	maxX, 55
.equ	minX, 0
.equ	maxY, 45
.equ	minY, 0
.equ	monsterNumber, 17
.equ	monsterOffset, 20
.equ	wallNumber, 15
.equ	wallOffset, 6

.globl menu
menu:
	mov r3, #0				
	push	{lr}	
	bl	drawStartMenu			//draw initial menu
	pop	{lr}

	ldr r7, =state				//set the state
	mov r8, #0
	str r8, [r7]

	mov	r6,	#0

menuTop:
	bl delay					//delay for pointer
	
	push	{lr, r4-r6}
	bl	getButtons				//check which buttons were pressed
	pop	{lr, r4-r6}
	mov	r4,	r0

	//check if down was pushed
	mov	r5,	r4
	lsr	r5,	#5
	and	r5,	#1
	cmp	r5,	#0
	moveq	r3, #-1				//if down was pushed, r3=-1
	bleq check					
	
	//check if up was pushed
	mov	r5,	r4
	lsr	r5,	#4
	and	r5,	#1
	cmp	r5,	#0
	moveq r3, #1				//if up was pushed, r3=1
	bleq check

//check if A was pushed
checkA:
	mov	r5,	r4
	lsr	r5,	#8
	and	r5,	#1
	cmp	r5,	#0
	bne	menuTop					//if not, stay in the menu
	beq exitMenu				//if yes, exit menu
	
//if A was pushed, exit menu with appropriate state
exitMenu:
	ldr r5, =state
	ldr r6, [r5]
	
	cmp r6, #0					//resume game
	moveq	r3, #0
	bleq clearScreen
	popeq {lr, r7, r8}
	bleq delay
	beq skipMenu
	
	cmp r6, #1					// restart game
	moveq	r3, #1
	bleq clearScreen
	bleq resetData
	beq mainTag
	
	cmp r6, #2					//end game
	moveq	r3, #1
	bleq clearScreen
	moveq r3, #0
	bleq endScreen
	
check:
	push {lr, r4-r10}

	ldr r5, =state
	ldr r6, [r5]
	
	sub r6, r3
	
	cmp r6, #-1				//if less than -1, change state pointer to resume
	moveq r6, #0
	
	cmp r6, #3				//i more than 3, change state pointer to exit
	moveq r6, #2
	
	mov r3, r6
	ldr r5, =state			//store state back into memory
	str r3, [r5]
	
	bl drawStartMenu

	pop {lr, r4-r10}
	bx lr

.globl delay	
delay:						//delay for pointer
	push {lr, r4-r10}

	ldr r0, =0x20003004 	// address of CLO 
	ldr r1, [r0]        	// read CLO
	ldr r10, =0x20000
	add r1, r10          	// add

delayLoop: 
	ldr r2, [r0] 
	cmp r1, r2          	// stop when CLO = r1
	bhi delayLoop 
	
	pop {lr, r4-r10}
	
	bx lr

.globl resetData
resetData:								//resets the data if user wants to restart
	push {lr, r4-r10}

	ldr	r0,	=player
	ldr r5, =0x04
	strh	r5,	[r0, #x]
	ldr r5, =0x10
	strh	r5,	[r0, #y]
	ldr r5, =0x01
	strh	r5,	[r0, #health]
	ldr r5, =0b00
	strh	r5, [r0, #dir]
	ldr r5, =0x00
	strh	r5,	[r0, #bulletX]
	ldr r5, =0x00
	strh	r5,	[r0, #bulletY]
	ldr r5, =0b0
	strh	r5,	[r0, #bulletAlive]
	ldr r5, =0x00
	strh	r5,	[r0, #bulletDir]

initialiseMonsters:							//reinitializes monster data

	mov	r2,	#0
	mov	r3,	#0
	mov	r4,	#1
	ldr	r0,	=monster

initLoop:
	cmp	r2,	#10
	moveq	r4,	#2
	cmp	r2,	#15
	moveq	r4,	#3

	mov	r5,	#1
	cmp	r4,	#2
	moveq	r5,	#2
	cmp	r4,	#3
	moveq	r5,	#20

	strh	r4,	[r0,	#type]
	strh	r5,	[r0,	#health]

	strh	r3,	[r0,	#x]
	mov	r1,	#1
	strh	r1,	[r0,	#y]

	ldrh	r6,	=0x00
	strh	r6,	[r0, #bulletX]
	strh	r6,	[r0, #bulletY]
	ldrh	r6, =0b1
	strh	r6,	[r0, #bulletAlive]
	ldrh	r6, =0x00
	strh	r6,	[r0, #bulletDir]

	add	r0,	#monsterOffset
	add	r3,	#3
	add	r2,	#1
	cmp	r2,	#monsterNumber
	
	blo	initLoop

	mov r6, #0
	mov r5, #2
	mov r4, #0
	ldrh r0, =wall
	
wallLoopRefresh:							//reinitialize wall data
	strh	r6,	[r0,	#x]
	strh	r6,	[r0,	#y]
	strh	r5,	[r0,	#health]
	add r0, #6

	add	r4, #1

	cmp r4,	#wallNumber
	blt wallLoopRefresh

	push {lr, r4-r10}
	bl wallRefresh
	pop {lr, r4-r10}

	pop {lr, r4-r10}
	bx lr

.section .data
.align 4
state:
	.int	0
endstate:
