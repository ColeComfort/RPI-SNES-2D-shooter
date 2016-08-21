.section .text
.equ	points, 8
.equ	monsterNumber, 17
.equ	health, 4

.globl gameCondition
gameCondition:
	push {lr, r4-r10}
	
    mov        r0,    #0           		 // initialize offset
    mov        r1,    #0           		 // counter
    mov        r2,    #monsterNumber      
monsterLoop:
    ldr        r4,    =monster    		// get address of monster array
    add     r4, #health        			// offset for health attribute 
    ldrh    r4,    [r4, r0]    			// r4 = health   
    cmp        r4,    #0          		// check if health <= 0
    suble    r2,    #1           		// decrement number of monsters if health <= 0
    add        r0,    #20            	// next monster's health
	add		r1,	#1
	cmp r1,	#monsterNumber
	blt	monsterLoop
	
										// check if game is won
	cmp		r2,	#0						// check if no monsters left
	bne		monstersAreNotDead
	mov	r3,	#1
	bleq 	drawEndingScreen			// display appropriate message if no monsters left\
	bleq	delay
	beq		checkButtons

monstersAreNotDead:						// check if game is lost
	ldr	r4,	=player
	ldrh	r6,	[r4, #4] 				// health = player + 4
	cmp		r6,	#0						// check if player health is 0
	moveq	r3,	#0
	bleq 	drawEndingScreen
	bleq	delay
	beq		checkButtons
	pop {lr, r4-r10}
	bx lr

checkButtons:							//check buttons to see if user wants  continue after win/lose
	ldr	r7,	=noButtons
	ldr	r7,	[r7]
	push {lr, r7}
	bl	getButtons	
	pop	{lr, r7}

    // check if buttons were pushed
    and r0, r7
	cmp	r0,	r7							//check for user input
	bne 	restartGam					//restart game if there is
	
	b checkButtons

restartGam:
	bl resetData						//reset data
	mov	r3, #1
	bl clearScreen						//clear screen
	b _start							//go back to start

.globl endScreen	
endScreen:
	bl	drawEndingScreen
	bx lr
	
endGame:
	b	haltLoop$
