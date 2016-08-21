.section .init

.section .data
.equ	monsterNumber, 17
.equ	wallNumber, 15

.align 2
.globl oldScore
oldScore:
	.hword 0x00		// score
	.hword 0x00		// monsters
	
.globl	player
player:
	.hword	0x04,	0x10	//x,y coords
	.hword	0x01		//health
	.hword	0b00		//direction
	.hword	0x00		//points
	.hword	0x00,	0x00	//x,y coords of bullet
	.hword	0b0		//Is bullet alive
	.hword	0x00		//bullet direction
	
.align 2
.globl	monster
monster:
.rept monsterNumber
	.hword	0x12,	0x26	//x,y coords
	.hword	0x0F		//health
	.hword	0b00		//direction
	.hword	0x01		//hitpoints
	.hword	0x00,	0x00	//x,y coords of bullet
	.hword	0b1		//Is bullet alive
	.hword	0x00		//bullet direction
	.hword	0x00		//type	(1=pawn,2,3)
.endr


.globl	wall
wall:
.rept wallNumber
	.hword	0x00,	0x00	//x,y coords
	.hword	0x02		//health
.endr

.globl counter
counter:
	.hword	0

.globl	FrameBufferPointer
FrameBufferPointer:
	.int	0

.globl	noButtons
noButtons:
	.int	0b111111111111

.globl	scoreInt
scoreInt:
	.hword	48, 48, 48

.globl monstersLeft
monstersLeft:
	.hword	monsterNumber
	
.section .text
