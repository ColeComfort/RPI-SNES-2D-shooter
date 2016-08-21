//heavily used snes tutorial slides 

.section .text

.globl getButtons
getButtons:
	push	{r4-r8}
	//mov	sp, #0x8000	
	//bl	EnableJTAG
	//mov	r0,	#42

	//INITIALISATION
	//clock output
	ldr r0, =0x20200004	// Function Select 1 Address
	ldr r1, [r0]		// Load value into register
	mov r2, #0b111		// Set up clear mask
	bic r1, r2, lsl #3	// Clear bits 18-20
	mov r2, #0b001		// Value mask (output = 001)
	orr r1, r2, lsl #3	// OR-mask into bits 18-20
	str r1, [r0] 

	//latch output
	ldr r0, =0x20200000	// Function Select 1 Address
	ldr r1, [r0]		// Load value into register
	mov r2, #0b111		// Set up clear mask
	bic r1, r2, lsl #27	// Clear bits 18-20
	mov r2, #0b001		// Value mask (output = 001)
	orr r1, r2, lsl #27	// OR-mask into bits 18-20
	str r1, [r0]

	//data input
	ldr r0, =0x20200004	// Function Select 1 Address
	ldr r1, [r0]		// Load value into register
	mov r2, #0b111		// Set up clear mask
	bic r1, r2, lsl #0	// Clear bits 18-20
	mov r2, #0b000		// Value mask (output = 001)
	orr r1, r2, lsl #0	// OR-mask into bits 18-20
	str r1, [r0] 

	//9 latch 10 data 11 timer
	//	#0x00000000 
	//latch	#0x00000200
	//data	#0x00000400
	//timer	#0x00000800
	//Set Register 0 (0x2020001C)
	//Clear Register 0 (0x20200028)

	//Now for the code to read the data

	//Write 1 to clock
	ldr r0, =0x2020001C
	mov r1, #0x00000800
	str r1, [r0]

	//write 1 to latch
	ldr r0, =0x2020001C
	mov r1, #0x00000200
	str r1, [r0]

	//wait
	mov	r0,	#12
	push	{lr, r4-r7}
	bl	wait
	pop	{lr, r4-r7}


	//write 0 to latch
	ldr r0, =0x20200028
	mov r1, #0x00000200
	str r1, [r0] 

	mov	r4,	#0
	mov	r6,	#0
	pulseLoop:

	//wait
	mov	r0,	#6
	push	{lr, r4-r7}
	bl	wait
	pop	{lr, r4-r7}

	//Write 0 to clock
	ldr r0, =0x20200028
	mov r1, #0x00000800
	str r1, [r0]

	//read from data pin
	ldr r0, =0x20200034	// Level Register 1 Address
	ldr r1, [r0] 		// Read value of register
	tst r1, #0x00000400	// AND with 1 << (45 – 32)
	moveq	r0,	#0	//if bit is 1
	movne	r0,	#1	//if bit is 0

	lsl	r0,	r4
	orr r6,	r0		//If it was, set appropriate bit

	//wait
	mov	r0,	#6
	push	{lr, r4-r7}
	bl	wait
	pop	{lr, r4-r7}

	//write 1 to clock
	ldr r0, =0x2020001C
	mov r1, #0x00000800
	str r1, [r0]

	add	r4,	#1

	cmp	r4,	#16
	bcc pulseLoop
	
	mov	r0,	r6

	pop	{r4-r8}
	bx	lr

wait:
	mov	r4,	r0
	ldr r5, =0x20003004	// address of CLO
	ldr r6, [r5]		// read CLO
	add r6, r4		// add x many microseconds
	waitLoop:
	ldr r7, [r5]
	cmp r6, r7		// stop when CLO = r1
	bhi waitLoop

	bx	lr
