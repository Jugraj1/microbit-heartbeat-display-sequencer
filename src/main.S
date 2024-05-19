.syntax unified
.global main

.type main, %function
main:
  nop
  ldr r0, =0
  ldr r1, =1
  ldr r2, =2
  ldr r3, =3
  push {r0 - r3}
  bl turn_on_col_led
  pop {r0 - r3}


  b main
.size main, .-main


.type turn_on_col_led, %function
@ changes the direction to ouput and sets 
@ the column specified as parameter
@ --parameters--
@ r0: index of column to display
@ r1: address of image to display ???????
turn_on_col_led:
  push {lr}
  push {r4 - r5} 
  push {r0} @ r1 ??
  bl init_leds
  pop {r0} @ r1 ??
  ldr r1, =OFS_GPIO_DIR
  ldr r2, =1
  push {r0}
  bl write_column_pin 
  pop {r0}
  ldr r1, =OFS_GPIO_OUT
  ldr r2, =0
  push {r0, r1}
  bl write_column_pin
  pop {r0, r1}

  lsl r0, 2
  ldr r2, =image @ r1 ??
  add r2, r2, r0
  ldr r2, [r2]
  ldr r4, =0 @ loop counter
  for:
    cmp r4, #5
    beq end
    ldr r5, =31
    sub r5, r4 
    push {r2}
    lsl r2, r5
    lsr r2, #31
    ldr r1, =OFS_GPIO_DIR
    mov r0, 0
    add r0, r4
    push {r0, r2}
    bl write_row_pin
    pop {r0, r2}
    ldr r1, =OFS_GPIO_OUT
    bl write_row_pin
    pop {r2}
    add r4, 1
    b for

  end: 
    pop {r4 - r5}
    pop {lr}
    bx lr
.size turn_on_col_led, .-turn_on_col_led   


.data
image:
  .word 0b10001 @ Column 1
  .word 0b11010 @ Column 2
  .word 0b10101 @ Column 3
  .word 0b11111 @ Column 4
  .word 0b00101 @ Column 5
hello:
.word 0x424242