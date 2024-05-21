.syntax unified
.global main

.type main, %function
main:
  nop
  @ ldr r0, =200
  @ ldr r2, =brightness_low
  @ ldr r1, =full_heart
  @ bl show_image_with_brightness

  @ ldr r0, =200
  @ ldr r2, =brightness_default
  @ ldr r1, =partial_heart
  @ bl show_image_with_brightness

  ldr r0, =200
  ldr r1, =small_heart
  ldr r2, =full_heart
  ldr r3, =brightness_high
  bl loop_switch_images

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
    @ ldr r1, =OFS_GPIO_DIR
    mov r0, 0
    add r0, r4
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

.type show_image_with_brightness, %function
@ shows the image using the given address with the delay and brightness
@ --parameters--
@ r0: delay (display time)
@ r1: address of image to display
@ r2: address storing brightness (brightness is represented in a way of delay)
show_image_with_brightness:
  push {lr}
  show_image_loop:
    cmp r0, 0
    push {r0}
    beq stop_show_image

    ldr r0, =0
    push {r1, r2}
    bl turn_col_with_brightness
    pop {r1, r2}

    ldr r0, =1
    push {r1, r2}
    bl turn_col_with_brightness
    pop {r1, r2}

    ldr r0, =2
    push {r1, r2}
    bl turn_col_with_brightness
    pop {r1, r2}

    ldr r0, =3
    push {r1, r2}
    bl turn_col_with_brightness
    pop {r1, r2}

    ldr r0, =4
    push {r1, r2}
    bl turn_col_with_brightness
    pop {r1, r2}

    pop {r0}
    sub r0, 1
    bl show_image_loop

  stop_show_image:
    bl init_leds
    pop {r0}
    pop {lr}
    bx lr
.size show_image_with_brightness, .-show_image_with_brightness 


.type turn_col_with_brightness, %function 
@ sets the column specified as parameter with a brightness
@ read from memory
@ --parameters--
@ r0: index of column to display
@ r1: address of image to display
@ r2: address storing brightness (brightness is represented in a way of delay)
turn_col_with_brightness:
  push {lr}
  push {r4, r5}
  cmp r0, 2

  push {r2}
  ldr r2, [r2]
  push {r2}
  bl turn_on_col_led
  pop {r2}
  mov r0, 0
  add r0, r2
  bl delay
  bl init_leds
  pop {r2}
  mov r0, 0
  add r2, 4
  ldr r2, [r2]
  add r0, r2
  bl delay
  
  pop {r4, r5}
  pop {lr}
  bx lr
.size turn_col_with_brightness, .-turn_col_with_brightness  

.type loop_switch_images, %function 
@ loops around two images
@ --parameters--
@ r0: delay (display time for each image)
@ r1: memory address for the first image
@ r2: memory address for the second image
@ r3: address storing brightness (brightness is represented in a way of delay)
loop_switch_images:

  push {lr}
  push {r0 - r3} 
  mov r2, 0
  add r2, r3
  bl show_image_with_brightness
  pop {r0 - r3}

  mov r1, 0
  add r1, r2

  mov r2, 0
  add r2, r3
  bl show_image_with_brightness

  pop {lr}
  bx lr
.size loop_switch_images, .-loop_switch_images

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

brightness_low:
  .word 100
  .word 10000

brightness_default:
  .word 2050
  .word 8050

brightness_high:
  .word 10000
  .word 100

