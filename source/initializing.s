.section .text

.equ	x, 0
.equ	y, 2
.equ	health, 4
.equ	type, 18
.equ	monsterNumber, 17
.equ	monsterOffset, 20
.equ	wallNumber, 15
.equ	wallOffset, 6


//This code serves to initialize the game on the first execution faster than the other init code on say a restart
.globl initializing
initializing:

	push	{ lr }
	bl	InitFrameBuffer
	pop	{ lr }

	ldr	r1, =FrameBufferPointer
	str	r0, [r1] // storing the frame buffer pointer into the data structure.

	push	{ lr }
	bl	initialiseMonsters // calling render function
	pop	{ lr }

	push	{ lr }
	bl	initialiseWalls // calling render function
	pop	{ lr }

	ldr	r7,	=noButtons
	ldr	r7,	[r7]

	push	{ lr, r7 }
	bl	playerRefresh // calling render function
	pop	{ lr, r7 }
	
	bx lr

.globl initialiseMonsters
initialiseMonsters:

	mov	r2,	#0
	mov	r3,	#0
	mov	r4,	#1
	ldr	r0,	=monster


	//Set x,y coords and health and type of monster
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

	add	r0,	#monsterOffset
	add	r3,	#3
	add	r2,	#1
	cmp	r2,	#monsterNumber
	
	
	blo	initLoop

	bx	lr

.globl initialiseWalls
initialiseWalls:
	
	mov	r2,	#0
	mov	r3,	#10

	ldr	r0,	=wall

	//Init walls and their positions
	initLoop1:

	strh	r3,	[r0,	#x]
	mov	r1,	#10
	strh	r1,	[r0,	#y]

	add	r0,	#wallOffset
	add	r3,	#1
	add	r2,	#1
	cmp	r2,	#wallNumber
	blo	initLoop1

	bx	lr
