.syntax unified
.global main

.type main, %function
main:
  nop
  @ ldr r0, =4
  @ ldr r1, =image
  @ bl turn_on_col_led

  ldr r0, =0x2000
  ldr r1, =full_heart
  bl show_image

  @ loop:
    
  @   ldr r0, =0
  @   ldr r1, =empty
  @   bl turn_on_col_led

  @   ldr r0, =1
  @   ldr r1, =empty
  @   bl turn_on_col_led

  @   ldr r0, =2
  @   ldr r1, =empty
  @   bl turn_on_col_led

  @   ldr r0, =3
  @   ldr r1, =empty
  @   bl turn_on_col_led

  @   ldr r0, =4
  @   ldr r1, =empty
  @   bl turn_on_col_led

  @   b loop


  b main
.size main, .-main


.type turn_on_col_led, %function
@ changes the direction to ouput and sets 
@ the column specified as parameter
@ --parameters--
@ r0: index of column to display
@ r1: address of image to display
turn_on_col_led:
  push {lr}
  push {r4 - r5} 
  push {r1}
  push {r0, r1}
  bl init_leds
  pop {r0, r1}
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
  pop {r1}
  mov r2, 0
  add r2, r1
  @ ldr r2, r1
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

.type show_image, %function
@ shows the image using the given address with the delay
@ --parameters--
@ r0: delay
@ r1: address of image to display
show_image:
  push {lr}
  show_image_loop:
    cmp r0, 0
    push {r0}
    beq stop_show_image

    ldr r0, =0
    push {r1}
    bl turn_on_col_led
    pop {r1}

    ldr r0, =1
    push {r1}
    bl turn_on_col_led
    pop {r1}

    ldr r0, =2
    push {r1}
    bl turn_on_col_led
    pop {r1}

    ldr r0, =3
    push {r1}
    bl turn_on_col_led
    pop {r1}

    ldr r0, =4
    push {r1}
    bl turn_on_col_led
    pop {r1}

    pop {r0}
    sub r0, 1
    bl show_image_loop

  stop_show_image:
    bl init_leds
    pop {lr}
    bx lr
.size show_image, .-show_image 


.data
full_heart:
  .word 0b00110 @ Column 1
  .word 0b01111 @ Column 2
  .word 0b11110 @ Column 3
  .word 0b01111 @ Column 4
  .word 0b00110 @ Column 5

small_heart:
  .word 0b00000 @ Column 1
  .word 0b00110 @ Column 2
  .word 0b01100 @ Column 3
  .word 0b00110 @ Column 4
  .word 0b00000 @ Column 5

partial_heart:
  .word 0b00110 @ Column 1
  .word 0b01001 @ Column 2
  .word 0b10110 @ Column 3
  .word 0b01001 @ Column 4
  .word 0b00110 @ Column 5

small_wave:
  .word 0b00100 @ Column 1
  .word 0b00010 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b01000 @ Column 4
  .word 0b00100 @ Column 5

line:
  .word 0b00100 @ Column 1
  .word 0b00100 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b00100 @ Column 4
  .word 0b00100 @ Column 5

peak:
  .word 0b00100 @ Column 1
  .word 0b00010 @ Column 2
  .word 0b00001 @ Column 3
  .word 0b00010 @ Column 4
  .word 0b00100 @ Column 5

trough:
  .word 0b00100 @ Column 1
  .word 0b01000 @ Column 2
  .word 0b10000 @ Column 3
  .word 0b01000 @ Column 4
  .word 0b00100 @ Column 5

empty:
  .word 0b00000 @ Column 1
  .word 0b00000 @ Column 2
  .word 0b00000 @ Column 3
  .word 0b00000 @ Column 4
  .word 0b00000 @ Column 5

start:
  .word 0b00000 @ Column 1
  .word 0b00000 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b00000 @ Column 4
  .word 0b00000 @ Column 5

hello:
.word 0x424242