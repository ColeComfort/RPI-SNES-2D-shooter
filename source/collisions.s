.section .text

.equ	maxX, 55
.equ	minX, 0
.equ	maxY, 45
.equ	minY, 0

.equ	monsterNumber, 17
.equ	monsterOffset, 20

.equ	wallNumber, 15
.equ	wallOffset, 6

.equ	x, 0
.equ	y, 2
.equ	health, 4
.equ	bulletAlive, 14
.equ	type, 18

//Take address into r0
//Take supposed x,y coords into r1, r2 respectively
.globl bulletCollsionCheck
bulletCollsionCheck:
	mov	r6,	r0
	mov	r7,	r1
	mov	r8,	r2

	mov	r12,	#0	//Suppose that bullet has not collided with anything


	//check collisions
	mov	r0,	r7
	mov	r1,	r8
	push	{ lr, r4-r12 }
	bl	checkCollisions
	pop	{ lr, r4-r12 }

	//If there were none, skip the following code
	cmp	r0,	#0
	beq	noBullet
	mov	r12,	#1	//Record collision

	//Else, kill bullet
	mov	r5,	r1	//Move collided with address to r5

	mov	r4,	#0
	strh	r4, [r6, #bulletAlive]

	//Check who shot he bullet and who was shot
	mov	r0,	r5
	push	{ lr, r4-r12 }
	bl	whatObject
	pop	{ lr, r4-r12 }
	mov	r10,	r0

	mov	r0,	r6
	push	{ lr, r4-r12 }
	bl	whatObject
	pop	{ lr, r4-r12 }
	mov	r11,	r0

	// r0=0 as player, r0=1 as monster, r0=2 as wall, r0=3 as edge
	//r10 is signature of collided with object with adress r5
	//r11 is signature of parent object with adress r6

	cmp	r10,	#3
	beq	noBullet

	cmp	r11,	#0
	beq	shotByPlayer
	//<Else> shot by a monster
	cmp	r10,	#1
	beq	noBullet	//Because a monster shot a monster
	//Else everything is cool

	cmp	r10,	#2
	bne	monsterDidNotShootWall
	ldrh	r4,	[r5,	#health]
	cmp	r4,	#1
	sub	r4,	#1
	movlo	r4,	#0
	strh	r4,	[r5,	#health]

    cmp     r4, #0
    

	bhi	noBullet

	mov	r1,	r7
	mov	r2,	r8
	mov	r0,	#5 //size of the render 
	push	{ lr, r4-r12 }
	bl	render // calling render function
	pop	{ lr, r4-r12 }

	b	noBullet

	monsterDidNotShootWall:	


	ldrh	r7,	[r6,	#type]
	cmp	r7,	#1
	moveq	r9,	#2	
	cmp	r7,	#2
	moveq	r9,	#4
	cmp	r7,	#3
	moveq	r9,	#20

	ldrh	r8,	[r5,	#health]
	cmp	r8,	r9
	sub	r8,	r9	
	movlo	r8,	#0
	strh	r8,	[r5,	#health]


	b	noBullet

	shotByPlayer:
	cmp	r10,	#0
	beq	noBullet	//Because player shot himself
	//Else everything is cool
	
	cmp	r10,	#2
	bne	playerDidNotShootWall
	ldrh	r4,	[r5,	#health]
	cmp	r4,	#1
	sub	r4,	#1
	movlo	r4,	#0
	strh	r4,	[r5,	#health]
	bhi	noBullet	

	mov	r1,	r7
	mov	r2,	r8
	mov	r0,	#5 //size of the render 
	push	{ lr, r4-r12 }
	bl	render // calling render function
	pop	{ lr, r4-r12 }

	b	noBullet

	playerDidNotShootWall:	

	ldrh	r8,	[r5,	#health]
	cmp	r8,	#0
	sub	r8,	#1
	movlo	r8,	#0
	strh	r8,	[r5,	#health]

	ldrh	r1,	[r5,	#x]
	ldrh	r2,	[r5,	#y]
	mov	r0,	#5 //size of the render 
	push	{ lr, r4-r12 }
	bl	render // calling render function
	pop	{ lr, r4-r12 }

	ldrh	r8,	[r5,	#type]
	ldrh	r9,	[r5,	#health]
	cmp	r9,	#0
	bhi	noBullet

	ldrh	r9,	[r6,	#health]
	cmp	r9,	#0
	ble	noBullet
	
	cmp	r8,	#1
	addeq	r9,	#1

	cmp	r8,	#2
	addeq	r9,	#2

	cmp	r8,	#3
	addeq	r9,	#20

	strh	r9,	[r6,	#health]

	noBullet:

	//Send collision status back
	mov	r0,	r12

	bx lr


//Send the adress of what is hit in r0
//Return r0=0 as player, r0=1 as monster, r0=2 as wall, r0=3 as edge
.globl whatObject
whatObject:
	mov	r4,	r0
	mov	r6,	#3
	

	//This simply checks if the address is in the range of any of these bases adresses since they are contiguous
	ldr	r5,	=player
	cmp	r4,	r5
	movge	r6,	#0
	ldr	r5,	=monster
	cmp	r4,	r5
	movge	r6,	#1
	ldr	r5,	=wall
	cmp	r4,	r5
	movge	r6,	#2


	mov	r0,	r6
	bx lr

//Send c,y coords into r0,r1
.globl checkCollisions
checkCollisions:
	mov	r4,	r0
	mov	r5,	r1
	mov	r7,	#0		//Let r7 be the index of the loop
	ldr	r8,	=monster	//Let r8 be the offset
	//start checking for monster collisions, since they are lower in memory

	collisionLoop:
	//Only count collision if object is alive
	ldrh	r9,	[r8,	#health]
	cmp	r9,	#0
	beq	nextCollision

	mov	r6,	#0		//The x,y coords are initially not equal
	//Get coords of object
	mov	r0,	r8
	push	{ lr, r4-r8 }
	bl	getCoords
	pop	{ lr, r4-r8 }

	//Add 1 to r6 when x coords and y coords are equal
	cmp	r0,	r4
	addeq	r6,	#1

	cmp	r1,	r5
	addeq	r6,	#1

	//Check if in bounds
	cmp	r4,	#maxX
	movhi	r0,	#1
	movhi	r1,	#0
	bhi	returnCollisions
	cmp	r4,	#minX
	movlo	r0,	#1
	movlo	r1,	#0
	blo	returnCollisions

	cmp	r5,	#maxY
	movhi	r0,	#1
	movhi	r1,	#0
	bhi	returnCollisions
	cmp	r5,	#minY
	movlo	r0,	#1
	movlo	r1,	#0
	blo	returnCollisions

	//If x,y coords are equal, there is a collision
	cmp	r6,	#2
	moveq	r0,	#1
	moveq	r1,	r8
	beq	returnCollisions

	nextCollision:

	//This code just changes which object we check, ie. if we have surpassed the memory offset occupied by some object

	cmp	r7,	#monsterNumber
	addlo	r8,	#monsterOffset
	cmp	r7,	#monsterNumber+1
	ldreq	r8,	=player
	cmp	r7,	#monsterNumber+1+1
	ldreq	r8,	=wall
	cmp	r7,	#monsterNumber+1+1
	addhi	r8,	#wallOffset
	cmp	r7,	#monsterNumber+1+1+wallNumber

	//This is just the index of the loop
	add	r7,	#1
	
	//If index is sufficiently small continue collision detection
	ble	collisionLoop

	//There have been no collisions, so return 0
	mov	r0,	#0

	returnCollisions:
	

	bx	lr

//send address in r0
//Maybe this doesn't have to be a whole function
getCoords:
	ldrh	r1,	[r0,	#y]
	ldrh	r0,	[r0,	#x]
	bx	lr
