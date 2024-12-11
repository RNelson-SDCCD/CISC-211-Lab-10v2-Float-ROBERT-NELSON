/*** asmFmax.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data  
.align

@ Define the globals so that the C code can access them

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Robert Nelson"  
 
.align

/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global f0,f1,fMax,signBitMax,storedExpMax,realExpMax,mantMax
.type f0,%gnu_unique_object
.type f1,%gnu_unique_object
.type fMax,%gnu_unique_object
.type sbMax,%gnu_unique_object
.type storedExpMax,%gnu_unique_object
.type realExpMax,%gnu_unique_object
.type mantMax,%gnu_unique_object

.global sb0,sb1,storedExp0,storedExp1,realExp0,realExp1,mant0,mant1
.type sb0,%gnu_unique_object
.type sb1,%gnu_unique_object
.type storedExp0,%gnu_unique_object
.type storedExp1,%gnu_unique_object
.type realExp0,%gnu_unique_object
.type realExp1,%gnu_unique_object
.type mant0,%gnu_unique_object
.type mant1,%gnu_unique_object
 
.align
@ use these locations to store f0 values
f0: .word 0
sb0: .word 0
storedExp0: .word 0  /* the unmodified 8b exp value extracted from the float */
realExp0: .word 0
mant0: .word 0
 
@ use these locations to store f1 values
f1: .word 0
sb1: .word 0
realExp1: .word 0
storedExp1: .word 0  /* the unmodified 8b exp value extracted from the float */
mant1: .word 0
 
@ use these locations to store fMax values
fMax: .word 0
sbMax: .word 0
storedExpMax: .word 0
realExpMax: .word 0
mantMax: .word 0

.global nanValue 
.type nanValue,%gnu_unique_object
nanValue: .word 0x7FFFFFFF            

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
 function name: initVariables
    input:  none
    output: initializes all f0*, f1*, and *Max varibales to 0
********************************************************************/
.global initVariables
 .type initVariables,%function
initVariables:
    /* YOUR initVariables CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    ldr r2, =f0
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =sb0
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =storedExp0
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =realExp0
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =mant0
    mov r3, 0
    str r3, [r2]
    
    
    ldr r2, =f1
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =sb1
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =storedExp1
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =realExp1
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =mant1
    mov r3, 0
    str r3, [r2]
    
    
    ldr r2, =fMax
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =sbMax
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =storedExpMax
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =realExpMax
    mov r3, 0
    str r3, [r2]
    
    ldr r2, =mantMax
    mov r3, 0
    str r3, [r2]
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR initVariables CODE ABOVE THIS LINE! Don't forget to push and pop! */

    
/********************************************************************
 function name: getSignBit
    input:  r0: address of mem containing 32b float to be unpacked
            r1: address of mem to store sign bit (bit 31).
                Store a 1 if the sign bit is negative,
                Store a 0 if the sign bit is positive
                use sb0, sb1, or signBitMax for storage, as needed
    output: [r1]: mem location given by r1 contains the sign bit
********************************************************************/
.global getSignBit
.type getSignBit,%function
getSignBit:
    /* YOUR getSignBit CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    /* Load 32b float and LSR to isolate the sign bit, then store */
    ldr r3, [r0]
    lsr r3, 31
    
    str r3, [r1]    // Store SB in provided address
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR getSignBit CODE ABOVE THIS LINE! Don't forget to push and pop! */
    

    
/********************************************************************
 function name: getExponent
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the unpacked original STORED exponent bits,
                shifted into the lower 8b of the register. Range 0-255.
            r1: always contains the REAL exponent, equal to r0 - 127.
                It is a signed 32b value. This function doesn't
                check for +/-Inf or +/-0, so r1 always contains
                r0 - 127.
                
********************************************************************/
.global getExponent
.type getExponent,%function
getExponent:
    /* YOUR getExponent CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    /***
     * Load given 32b float, shift left to remove sign bit
     * LSR right to isolate exponent
     * Store the exponent
    ***/
    ldr r3, [r0]
    lsl r3, 1
    lsr r3, 23
    
    /* Calculate the real exponent */
    mov r0, r3
    sub r1, r3, 127
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR getExponent CODE ABOVE THIS LINE! Don't forget to push and pop! */
   

    
/********************************************************************
 function name: getMantissa
    input:  r0: address of mem containing 32b float to be unpacked
      
    output: r0: contains the mantissa WITHOUT the implied 1 bit added
                to bit 23. The upper bits must all be set to 0.
            r1: contains the mantissa WITH the implied 1 bit added
                to bit 23. Upper bits are set to 0. 
********************************************************************/
.global getMantissa
.type getMantissa,%function
getMantissa:
    /* YOUR getMantissa CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    
    /***
     * Load 32b float and LSL to remove sign + exponent
     * LSR to isolate mantissa without implied bit
    ***/
    ldr r3, [r0]
    ldr r4, [r0]
    lsl r3, 9
    lsr r3, 9
    
    mov r0, r3
    
    /***
     * Load 32b float and LSL to remove sign + exponent
     * ORR with 0x80000000 to add implied 1 bit
    ***/    
    lsl r4, 9
    orr r4, r4, 0x80000000    
    mov r1, r4
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR getMantissa CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
 function name: asmIsZero
    input:  r0: address of mem containing 32b float to be checked
                for +/- 0
      
    output: r0:  0 if floating point value is NOT +/- 0
                 1 if floating point value is +0
                -1 if floating point value is -0
      
********************************************************************/
.global asmIsZero
.type asmIsZero,%function
asmIsZero:
    /* YOUR asmIsZero CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    /***
     * Load 32b float and sign bit mask
     * Compare float with bit mask
     * If 0, branch to check for +0
    ***/
    ldr r1, [r0]
    
    mov r2, 0x80000000
    cmp r1, 0
    beq is_pos
    
    /***
     * Check for sign bit being set
     * If set but not 0, value is not valid
    ***/
    ands r3, r1, r2
    bne not_zero
    
    /***
     * Test if value has sign bit set
     * If not set, not zero
    ***/
    tst r1, r2
    beq not_zero
    
    mov r0, -1	// All other checks failed, must be -0
    
    pop {r4-r11, LR}
    bx lr
    
    /* Return 1 for +0 */
    is_pos:
    mov r0, 1
    pop {r4-r11, LR}
    bx lr
    
    /* Return 0 for not zero */
    not_zero:
    mov r0, 0
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR asmIsZero CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
 function name: asmIsInf
    input:  r0: address of mem containing 32b float to be checked
                for +/- infinity
      
    output: r0:  0 if floating point value is NOT +/- infinity
                 1 if floating point value is +infinity
                -1 if floating point value is -infinity
      
********************************************************************/
.global asmIsInf
.type asmIsInf,%function
asmIsInf:
    /* YOUR asmIsInf CODE BELOW THIS LINE! Don't forget to push and pop! */
    
    push {r4-r11, LR}
    
    /***
     * Load 32b float
     * Load bit pattern for +inf
     * Load sign bit mask
    ***/
    ldr r1, [r0]
    mov r2, 0x7f800000
    mov r3, 0x80000000
    
    /* Compare float with +inf */
    cmp r1, r2
    beq is_pos_inf
    
    /* Combine +inf with sb to get -inf */
    orr r2, r2, r3
    cmp r1, r2
    beq is_neg_inf
    
    /* Return 0 if value is not inf */
    not_inf:
    mov r0, 0
    
    pop {r4-r11, LR}
    bx LR
    
    /* Return 1 if value is +inf */
    is_pos_inf:
    mov r0, 1
    
    pop {r4-r11, LR}
    bx LR
    
    /* Return -1 for -inf */
    is_neg_inf:
    mov r0, -1
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR asmIsInf CODE ABOVE THIS LINE! Don't forget to push and pop! */
   


    
/********************************************************************
function name: asmFmax
function description:
     max = asmFmax ( f0 , f1 )
     
where:
     f0, f1 are 32b floating point values passed in by the C caller
     max is the ADDRESS of fMax, where the greater of (f0,f1) must be stored
     
     if f0 equals f1, return either one
     notes:
        "greater than" means the most positive number.
        For example, -1 is greater than -200
     
     The function must also unpack the greater number and update the 
     following global variables prior to returning to the caller:
     
     signBitMax: 0 if the larger number is positive, otherwise 1
     realExpMax: The REAL exponent of the max value, adjusted for
                 (i.e. the STORED exponent - (127 o 126), see lab instructions)
                 The value must be a signed 32b number
     mantMax:    The lower 23b unpacked from the larger number.
                 If not +/-INF and not +/- 0, the mantissa MUST ALSO include
                 the implied "1" in bit 23! (So the student's code
                 must make sure to set that bit).
                 All bits above bit 23 must always be set to 0.     

********************************************************************/    
.global asmFmax
.type asmFmax,%function
asmFmax:   

    /* YOUR asmFmax CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    
    push {r4-r11, LR}
    
    bl initVariables	// Initialize all values to zero
    
    /* Load fMax and inputs */
    ldr r2, =fMax
    ldr r3, [r0]
    ldr r4, [r1]
    
    /***
     * Compare f0 and f1
     * Branch to handle whichever is maximum
     * If f0 == f1, either is maximum
    ***/
    cmp r3, r4
    bgt f0_is_max
    blt f1_is_max
    b equal_values
    
    /* Store f0 as fMax, update r0 */
    f0_is_max:
    str r3, [r2]
    mov r0, r3
    b unpack_update
    
    /* Store f1 as fMax, update r0 */
    f1_is_max:
    str r4, [r2]
    mov r0, r4
    b unpack_update
    
    /* Values are equal, store either one */
    equal_values:
    str r3, [r2]
    mov r0, r3
    b unpack_update
    
    /***
     * Load sbMax and update sb of fMax
     * Reload fMax for getExponent
     * Load address of real exponent
     * Call getExponent to calc and store exp
     * Store biased exponent
    ***/
    unpack_update:
    ldr r1, =sbMax
    bl getSignBit
    
    ldr r0, =fMax
    ldr r1, =realExpMax
    bl getExponent
    ldr r2, =storedExpMax
    str r0, [r2]
    
    /* Load fMax and get mantissa to store */
    ldr r0, =fMax
    ldr r1, =mantMax
    bl getMantissa
    
    pop {r4-r11, LR}
    bx LR
    
    /* YOUR asmFmax CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           



