.section .text
.equ	monsterNumber, 17
.equ	monsterOffset, 20
.equ	wallNumber, 15
.equ	wallOffset, 6
.equ	x, 0
.equ	y, 2
.equ	health, 4
.equ	dir, 6
.equ	bulletX, 10
.equ	bulletY, 12
.equ	bulletAlive, 14
.equ	bulletDir, 16
.equ	type, 18

//Take buttons in r0
.globl playerRefresh
playerRefresh:

	//move buttons to r9
	mov	r9,	r0

	//Check if it is the turn of the player to move
	ldr	r0, =counter
	ldrh	r1, [r0]
	and	r1, #1
	cmp	r1, #1
	bne	doNotShoot


	ldr	r0,	=player
	ldrh	r5,	[r0, #x]
	ldrh	r6,	[r0, #y]
	ldrh	r10,	[r0, #dir]

	//Render black over player
	mov	r0,	#5
	mov	r1,	r5
	mov	r2,	r6 
	push	{ lr, r5-r10 }
	bl	render // calling render function
	pop	{ lr, r5-r10 }


	//Check if player is dead
	ldr	r0,	=player
	ldrh	r4,	[r0, #health]
	cmp	r4,	#0
	ble	doNotShoot


	//change direction based on inputs
	mov	r0,	r9


	//Bitmask buttons so that we can check if buttons were exclusively pressed.
	lsr	r0,	#4

	mov	r7,	#0

	and	r0,	#0b1111


	//change direction and position
	cmp	r0,	#0b0001
	addeq	r6,	#-1
	moveq	r10,	#0b00
	moveq	r7,	#1

	cmp	r0,	#0b0010
	addeq	r6,	#1
	moveq	r10,	#0b10
	moveq	r7,	#1

	cmp	r0,	#0b0100
	addeq	r5,	#-1
	moveq	r10,	#0b11
	moveq	r7,	#1

	cmp	r0,	#0b1000
	addeq	r5,	#1
	moveq	r10,	#0b01
	moveq	r7,	#1


	//Check collisions
	mov	r0,	r5
	mov	r1,	r6
	push	{ lr , r5-r10 }
	bl	checkCollisions
	pop	{ lr , r5-r10 }

	//Revert movement changes if there was a collision
	cmp	r0,	#1
	ldreq	r0,	=player
	ldreqh	r5,	[r0, #x]
	ldreqh	r6,	[r0, #y]
	beq	collisionsWithPlayer

	//Otherwise make them permanent
	ldr	r0,	=player
	strh	r5,	[r0, #x]
	strh	r6,	[r0, #y]
	strh	r10,	[r0, #dir]

	collisionsWithPlayer:

	//Render player
	mov	r0,	#0 //size of the render
	mov	r1,	r5
	mov	r2,	r6 
	push	{ lr }
	bl	render // calling render function
	pop	{ lr }

	//Don't shoot if player has moved
	cmp	r7,	#0
	bne	doNotShoot

	//Don't shoot if player hasn't decided to shoot
	lsr	r9,	#8
	and	r9,	#1
	cmp	r9,	#1
	bne	doNotShoot

	//Otherwise shoot
	ldr	r0,	=player
	push	{ lr }
	bl	createBullet // calling render function
	pop	{ lr }

	doNotShoot:

	//Update bullet
	ldr	r0,	=player
	push	{ lr }
	bl	updateBullet // calling render function
	pop	{ lr }

	//Increment clock in memory
	ldr	r0, =counter
	ldrh	r1, [r0]
	cmp	r1,	#9
	moveq	r1,	#0
	addlo	r1,	#1
	strh	r1, [r0]

	bx	lr


//Send parent object in r0
createBullet:
	//move address of object to r8
	mov	r8,	r0

	//Continue only if bullet is dead
	ldrh	r1, [r8, #bulletAlive]
	cmp	r1,	#1
	beq	endCreateBullet

	//Compare address of player and parent object
	ldr	r4,	=player
	cmp	r4,	r8

	mov	r0,	#0

	//If player shot bullet evade
	bne	skipEvade


	//Update monster with evade flag set
	mov	r0,	#1
	push {lr, r8}
	bl	monsterLoop
	pop {lr, r8}

	//wait
	ldr r0, =0x20003004	// address of CLO
	ldr r1, [r0]		// read CLO
	ldr r2, =0x30000	//time to wait
	add r1,	r2			// add x many microseconds
	waitLoop:
	ldr r2, [r0]
	cmp r1, r2			// stop when CLO = r1
	bhi waitLoop

	//Update monster with evade flag set
	mov	r0,	#1
	push {lr, r8}
	bl	monsterLoop
	pop {lr, r8}

	//Otherwise do not evade
	skipEvade:

	//set direction and position of bullet to that of parent one coord ahead
	ldrh	r5, [r8, #dir]
	ldrh	r6, [r8, #x]
	ldrh	r7, [r8, #y]	

	cmp	r5,	#0b01
	addeq	r6,	#1
	cmp	r5,	#0b11
	addeq	r6,	#-1
	cmp	r5,	#0b10
	addeq	r7,	#1
	cmp	r5,	#0b00
	addeq	r7,	#-1

	//make sure that there is nothing where the bullet will be spawned
	mov	r0,	r6
	mov	r1,	r7
	push	{ lr , r5-r10 }
	bl	checkCollisions
	pop	{ lr , r5-r10 }
	cmp	r0,	#0
	
	//if there is then do not make the bullet
	bne	endCreateBullet


	//Otherwise, update the bullet
	strh	r6, [r8, #bulletX]
	strh	r7, [r8, #bulletY]
	strh	r5, [r8, #bulletDir]
	mov	r4,	#1
	strh	r4, [r8, #bulletAlive]

	endCreateBullet:

	bx	lr



//If r0=0, do not evade, else evade
.globl monsterLoop
monsterLoop:
	mov	r7,	r0

	mov	r5,	#0
	mov	r6,	#0

	//Loop through all monsters to update them
	monsterLoopTop:

	ldr	r0,	=monster
	add	r0,	r6

	//remark that the evasion flag is sent as an argument
	mov	r1,	r7
	push	{ lr, r5-r8}
	bl	monsterRefresh
	pop	{ lr, r5-r8 }

	add	r6,	#monsterOffset
	add	r5,	#1
	cmp	r5,	#monsterNumber
	blo	monsterLoopTop

	bx	lr

.globl wallLoop
//draws walls
wallLoop:
	mov	r5,	#0
	mov	r6,	#0

	//loop though all walls to update them
	wallLoopTop:

	ldr	r0,	=wall
	add	r0,	r6

	push	{ lr, r5-r7}
	bl	wallRefresh
	pop	{ lr, r5-r7 }

	add	r6,	#wallOffset
	add	r5,	#1
	cmp	r5,	#wallNumber
	blo	wallLoopTop


	bx	lr

// refreshes walls and checks if they were hit
// takes wall address in r0
.globl wallRefresh
wallRefresh:
	
	mov	r4,	r0

	//check if wall is alive
	ldrh	r6,	[r4,	#health]
	cmp	r6,	#0
	ble	endWallRefresh

	ldrh	r7,	[r4,	#x]
	ldrh	r8,	[r4,	#y]

	//render black
	mov	r0,	#5
	mov	r1,	r7
	mov	r2,	r8
	push	{ lr ,r4-r8}
	bl	render // calling render function
	pop	{ lr ,r4-r8}

	//render the type of wall (since the offsets line up perfectly)
	mov	r0,	r6
	add	r0,	#5
	mov	r1,	r7
	mov	r2,	r8
	push	{ lr }
	bl	render // calling render function
	pop	{ lr }


	endWallRefresh:
	bx	lr


//If r1=0, do not evade, else evade
//Let r0 be the address of the monster
monsterRefresh:

	mov	r12,	r0
	mov	r7,	r1

	//Check if monster is alive
	ldrh	r1,	[r12, #health]
	cmp	r1,	#0
	ble	deadMonster

	ldrh	r9,	[r12, #x]
	ldrh	r10,	[r12, #y]

	//If they can evade, the monster will move
	cmp	r7,	#1
	beq	skipTimer

	//Check if it is the monster's turn to move
	ldr	r4, =counter
	ldrh	r4, [r4]
	cmp	r4,	#0
	bne	monsterSkip


	skipTimer:

	//Draw black render over monster
	mov	r0,	#5
	mov	r1,	r9	
	mov	r2,	r10	
	push	{ lr, r9-r12 }
	bl	render // calling render function
	pop	{ lr, r9-r12 }

	ldr	r4,	=player
	ldrh	r5,	[r4, #x]
	ldrh	r6,	[r4, #y]

	//This is the code to change coords and direction based on relative player direction
	cmp	r7,	#0
	beq	doNotEvade

	//if they evade, load clcok
	ldr	r0, =0x20003004	// address of CLO
	ldr	r4, [r0]		// read CLO
	and	r4,	#0b11

	//set bitmask and decide direction based on first two bits of clock 

	tst	r4,	#0b01

	addne	r9,	#1
	movne	r11,	#0b11
	addeq	r9,	#-1
	moveq	r11,	#0b01

	tst	r4,	#0b10
	addne	r10,	#1
	movne	r11,	#0b00
	addeq	r10,	#-1
	moveq	r11,	#0b10

	b	evadeEnd
	doNotEvade:

	//Otherwise, move toward the player
	cmp	r9,	r5
	addhi	r9,	#-1
	movhi	r11,	#0b11
	addlo	r9,	#1
	movlo	r11,	#0b01

	cmp	r10,	r6
	addhi	r10,	#-1
	movhi	r11,	#0b00
	addlo	r10,	#1
	movlo	r11,	#0b10
	
	evadeEnd:

	//Store the direction
	strh	r11,	[r12, #dir]

	//Check if there are any collisions
	mov	r0,	r9
	mov	r1,	r10
	push	{lr,	r4-r12}
	bl	checkCollisions
	pop	{lr,	r4-r12}

	//If there are none, skip the collision code
	cmp	r0,	#0
	beq	moveMonster

	//Move the address of the collided with object into r4, send as argument to find what object was collided with
	mov	r4,	r1
	mov	r0,	r1

	// Check what object caused the collision
	push	{lr,	r4-r12}
	bl	whatObject
	pop	{lr,	r4-r12}

	//If not player, skip this code and just don't move monster
	cmp	r0,	#0
	bne	monsterSkip

	//Otherwise, subract monster's health from player health
	ldrh	r6,	[r12,	#health]
	ldrh	r5,	[r4,	#health]
	cmp	r5,	r6
	sub	r5,	r6
	movlo	r5,	#0
	strh	r5,	[r4,	#health]

	//If player is dead, render black over player
	cmp	r5,	#0
	ldrleh	r1,	[r4, #x]
	ldrleh	r2,	[r4, #y]
	movle	r0, #5 //size of the render
	pushle	{ lr, r9-r12 }
	blle	render // calling render function
	pople	{ lr, r9-r12 }

	//Kill monster
	mov	r5,	#0
	strh	r5,	[r12,	#health]

	//Render black over monster
	ldrh	r1,	[r12, #x]
	ldrh	r2,	[r12, #y]
	mov	r0, #5 //size of the render
	push	{ lr, r9-r12 }
	bl	render // calling render function
	pop	{ lr, r9-r12 }

	b	monsterSkip

	//If there were no collisions, move monster
	moveMonster:
	strh	r9,	[r12, #x]
	strh	r10,	[r12, #y]


	monsterSkip:

	//draw updated monster (coordinates may not have changed)
	ldrh	r0,	[r12, #type]
	ldrh	r1,	[r12, #x]
	ldrh	r2,	[r12, #y]

	push	{ lr,	r12 }
	bl	render // calling render function
	pop	{ lr, r12 }
	

	//Try to make new bullet
	mov	r0,	r12
	push	{ lr, r12 }
	bl	createBullet // calling render function
	pop	{ lr, r12 }

	deadMonster:
	
	//Update the bullet (Remark that a bullet can keep on moving after the deah)
	mov	r0,	r12
	push	{ lr }
	bl	updateBullet // calling render function
	pop	{ lr }


	bx lr

//take address in r0
updateBullet:	
	mov	r6,	r0

	//Skip all of this code if the bullet is not active
	ldrh	r4,	[r6, #bulletAlive]
	cmp	r4,	#0
	beq	deadBullet

	ldrh	r7, [r6, #bulletX]
	ldrh	r8, [r6, #bulletY]


	//Write black over previous bullet
	mov	r0,	#5
	mov	r1,	r7
	mov	r2,	r8	

	push	{ lr, r6-r9 }
	bl	render // calling render function
	pop	{ lr, r6-r9 }

	//Check if bullet has collided with anything
	mov	r0,	r6
	mov	r1,	r7
	mov	r2,	r8

	//check for collisions
	push	{ lr, r4-r12 }
	bl	bulletCollsionCheck
	pop	{ lr, r4-r12 }

	//If something moved into the bullet, kill the bullet
	cmp	r0,	#0
	bne	deadBullet

	//This code moves the bullet
	ldrh	r9, [r6, #bulletDir]

	cmp	r9,	#0b01
	addeq	r7,	#1
	cmp	r9,	#0b11
	addeq	r7,	#-1
	cmp	r9,	#0b10
	addeq	r8,	#1
	cmp	r9,	#0b00
	addeq	r8,	#-1


	//Check if bullet moved into anything
	mov	r0,	r6
	mov	r1,	r7
	mov	r2,	r8
	push	{ lr, r4-r12 }
	bl	bulletCollsionCheck
	pop	{ lr, r4-r12 }
	cmp	r0,	#0
	bne	deadBullet

	//Store updated bullet coordinates
	strh	r7, [r6, #bulletX]
	strh	r8, [r6, #bulletY]


	//Render bullet
	mov	r0,	#4 //size of the render 
	mov	r1,	r7
	mov	r2,	r8
	push	{ lr }
	bl	render // calling render function
	pop	{ lr }

	deadBullet:

	bx lr
