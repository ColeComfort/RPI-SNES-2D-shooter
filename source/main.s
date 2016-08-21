//Written by
//  Cole Comfort (10129397)
//  Gee Lin (10096521)
//  Elizabeth Nanthavong (00326374)
.section    .init
.globl     _start

_start:
    b       main
    
.section .text

.globl main
main:
	mov	sp, #0x8000	
	bl	EnableJTAG
	mov	r0,	#42

	.globl mainTag
	mainTag:
	
	bl initializing
	push {lr}
	bl introduction
	pop {lr}
	
.globl top
top:
	push	{ lr }
	bl	InitFrameBuffer
	pop	{ lr }

	ldr	r1, =FrameBufferPointer
	str	r0, [r1] // storing the frame buffer pointer into the data structure.

	bl gameCondition


	push	{ lr, r7 }
	bl	getButtons
	pop	{ lr, r7 }

	cmp	r0,	r7
	beq	top

	mov	r8,	r0

	//Check if start was pressed for the menu

	eor	r4,	r8
	lsr	r4,	#3
	and	r4,	#1
	cmp	r4,	#0
	bne	skipMenu
	push	{ lr , r7, r8}
	bl	menu

.globl skipMenu
	skipMenu:

	eor	r0,	r7
	mov	r7,	r8	


	push	{ lr , r7, r8}
	bl	playerRefresh
	pop	{ lr , r7, r8}

	mov	r0,	#0
	push	{ lr, r7, r8}
	bl	monsterLoop
	pop	{ lr , r7, r8}

	push	{ lr, r7, r8}
	bl	wallLoop
	pop	{ lr , r7, r8}
	
	push	{ lr, r7, r8 }
	bl	printScore
	pop	{ lr, r7, r8 }

	b top



.globl haltLoop$
haltLoop$:
	b	haltLoop$



