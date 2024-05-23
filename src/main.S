.syntax unified
.global main

@ GPIOTE Constants
.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_EVENTS_IN1, 0x40006104
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set GPIOTE_CONFIG1, 0x40006514

@ NVIC Constants
.set NVIC_ISER0, 0xE000E100

.type main, %function
main:

  ldr r0, =500
  ldr r1, =start
  ldr r2, =start
  ldr r3, =brightness_end_stage_high
  bl fade_images

  bl init_prop_display_image
  bl enable_buttons
  ldr r0, =display_time
  ldr r1, =small_heart
  ldr r2, =full_heart
  ldr r3, =current_brightness
  bl loop_switch_images

  ldr r0, =500
  ldr r1, =full_heart
  ldr r2, =full_heart
  ldr r3, =brightness_end_stage_high
  bl fade_images

  ldr r0, =500
  ldr r1, =small_heart
  ldr r2, =full_heart
  ldr r3, =brightness_end_stage_high
  bl fade_images

  ldr r0, =500
  ldr r1, =partial_heart
  ldr r2, =full_heart
  ldr r3, =brightness_end_stage_high
  bl fade_images

  ldr r0, =500
  ldr r1, =partial_heart
  ldr r2, =partial_heart
  ldr r3, =brightness_end_stage_high
  bl fade_images

  ldr r0, =500
  ldr r1, =empty
  ldr r2, =empty
  ldr r3, =brightness_end_stage_high
  bl fade_images

  ldr r0, =boolean_show_higher_lower
  ldr r0, [r0]
  ldr r1, =1
  cmp r0, r1
  beq higher_show
  ldr r0, =31
  ldr r1, =heart_beat_slow
  bl slide_image_show
  b main
  higher_show: 
    ldr r0, =16
    ldr r1, =heart_beat_fast
    bl slide_image_show
    b main



  
  @ ldr r0, =100
  @ bl delay
  
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

.type slide_image_show, %function 
@ displays images in a way that one image is slowly moving out while the another one entering 
@ --parameters--
@ r0: number of frames (total number of images * 5 - 4)
@ r1: memory address which stores references to the images that needs to be displayed
slide_image_show:
  push {lr}
  ldr r4, =0
  ldr r5, =4
  slide_image_show_loop:
    cmp r4, r0
    beq stop_slide_image_show
    push {r4}
    mul r4, r5
    push {r0 - r3}
    add r1, r4
    ldr r2, =brightness_default
    ldr r0, =200
    bl show_image_with_brightness

    pop {r0 - r3}
    pop {r4}
    add r4, 1
    b slide_image_show_loop
    
  stop_slide_image_show:
    pop {lr}
    bx lr  
.size slide_image_show, .-slide_image_show


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

.type init_prop_display_image, %function 
@ Initilizes the values stored in memory to default values
@ so that other functions work well
init_prop_display_image:
  push {lr}
  ldr r0, =display_time
  ldr r1, =200
  str r1, [r0]

  ldr r0, =exit_loop_condition
  ldr r1, =0
  str r1, [r0]

  ldr r0, =current_brightness
  ldr r1, =brightness_default
  str r1, [r0]

  ldr r0, =boolean_show_higher_lower
  ldr r1, =0
  str r1, [r0]
  pop {lr}
  bx lr
.size init_prop_display_image, .-init_prop_display_image 





.type loop_switch_images, %function 
@ loops around two images
@ --parameters--
@ r0: address of delay (display time for each image)
@ r1: memory address for the first image
@ r2: memory address for the second image
@ r3: address of the address storing brightness (brightness is represented in a way of delay)
loop_switch_images:
  push {lr}
  push {r4}
  ldr r4, =exit_loop_condition
  ldr r4, [r4]
  cmp r4, 0
  bne end_loop_switch_images
  push {r0 - r3} 

  push {r0 - r3} 
  ldr r2, [r3]
  ldr r0, [r0]
  bl show_image_with_brightness
  pop {r0 - r3}

  mov r1, 0
  add r1, r2

  ldr r2, [r3]
  ldr r0, [r0]
  bl show_image_with_brightness
  pop {r0 - r3}
  pop {r4}
  pop {lr}
  b loop_switch_images

  end_loop_switch_images:
    pop {r4}
    pop {lr}
    bx lr
.size loop_switch_images, .-loop_switch_images

.type sequential_image_show, %function 
@ sequentially shows images (number of images to be shown stored in r2) from address in r1
@ --parameters--
@ r0: delay (display time for each image)
@ r1: memory address which stores references to the images that needs to be displayed
@ r2: number of images from the address specified in r1
sequential_image_show:
  push {lr}
  cmp r2, 0
  beq end_sequential_image_show
  push {r0 - r2}
  sub r2, #1
  ldr r3, =4
  mul r2, r3
  add r1, r2
  ldr r1, [r1]
  ldr r2, =brightness_default
  bl show_image_with_brightness
  pop {r0 - r2}
  sub r2, 1
  bl sequential_image_show
  end_sequential_image_show:
    pop {lr}
    bx lr
.size sequential_image_show, .-sequential_image_show

.type enable_buttons, %function 
@ Makes button a and b listen to events
enable_buttons:
  push {lr}
  
  @ 1: Configure GPIOTE_CONFIG[0]
  @ Need to setup: mode, pin, port, polarity in the configuration 
  @ register for GPIOTE[0]
  @ mode = 1 (event), pin = 14 and port = 0 (P0.14 = Button A), 
  @ polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  @ 2: Enable Interrupt for GPIOTE[0] (id = 6)
  @ S6.9.4.6 in nRF52833 reference manual
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b1
  str r1, [r0]

  @ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6) @ set the 6th bit since NVIC_GPIOTE_ID = 6
  str r1, [r0]

  @ 1: Configure GPIOTE_CONFIG[0]
  @ Need to setup: mode, pin, port, polarity in the configuration 
  @ register for GPIOTE[0]
  @ mode = 1 (event), pin = 23 and port = 0 (P0.23 = Button B), 
  @ polarity = 1 (LoToHi)
  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(1 | 23 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  @ 2: Enable Interrupt for GPIOTE[1] (id = 6)
  @ S6.9.4.6 in nRF52833 reference manual
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11
  str r1, [r0]

  @ 3: enable GPIOTE (interrupt #6 = NVIC_GPIOTE_ID) in NVIC_ISER0
  @ NVIC_ISER0: B3.4.4 in ARMv7-M Reference Manual
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6) @ set the 6th bit since NVIC_GPIOTE_ID = 6
  str r1, [r0]  

  pop {lr}
  bx lr
.size enable_buttons, .-enable_buttons

.type disable_buttons, %function 
@ Makes button a and b listen to events
disable_buttons:
  push {lr}

  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(0 | 14 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  ldr r0, =GPIOTE_CONFIG1
  ldr r1, =(0 | 23 << 8 | 0 << 13 | 1 << 16) @ |
  str r1, [r0]

  pop {lr}
  bx lr
.size disable_buttons, .-disable_buttons

.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {lr}
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r0, [r0]
  cmp r0, 0
  beq button_B_press 
  
  push {r4, r5}
  ldr r4, =brightness_low
  ldr r5, =current_brightness
  ldr r5, [r5]
  cmp r4, r5
  bne decrease_brightness
  ldr r4, =exit_loop_condition
  ldr r5, =1
  str r5, [r4] @ Exit outside loop if non-zero



  pop {r4, r5}
  bl init_leds
  @ clear event
  ldr r0, =GPIOTE_EVENTS_IN0
  ldr r1, =0
  str r1, [r0]

  pop {lr}
  bx lr
  
  decrease_brightness:
    push {r6, r7}
    ldr r6, =display_time
    ldr r7, [r6]
    add r7, 100
    str r7, [r6]
    pop {r6, r7}

    ldr r4, =brightness_high
    cmp r4, r5
    ITTT eq
      ldreq r4, =brightness_default
      ldreq r5, =current_brightness
      streq r4, [r5]

    ldr r4, =brightness_default
    cmp r4, r5
    ITTT eq
      ldreq r4, =brightness_low
      ldreq r5, =current_brightness
      streq r4, [r5]

    @ clear event
    ldr r0, =GPIOTE_EVENTS_IN0
    ldr r1, =0
    str r1, [r0]
    pop {r4, r5}
    pop {lr}
    bx lr
  
  button_B_press:
    push {r4, r5}
    ldr r4, =brightness_high
    ldr r5, =current_brightness
    ldr r5, [r5]
    cmp r4, r5
    bne increase_brightness
    ldr r4, =exit_loop_condition
    ldr r5, =1
    str r5, [r4] @ Exit outside loop if non-zero
    @ set boolean show higher or lower to 1
    ldr r4, =boolean_show_higher_lower
    ldr r5, =1
    str r5, [r4]

    pop {r4, r5}
    bl init_leds
    @ clear event
    ldr r0, =GPIOTE_EVENTS_IN1
    ldr r1, =0
    str r1, [r0]

    pop {lr}
    bx lr

    increase_brightness:
      push {r6, r7}
      ldr r6, =display_time
      ldr r7, [r6]
      sub r7, 100
      str r7, [r6]
      pop {r6, r7}

      ldr r4, =brightness_low
      cmp r4, r5
      ITTT eq
        ldreq r4, =brightness_default
        ldreq r5, =current_brightness
        streq r4, [r5]

      ldr r4, =brightness_default
      cmp r4, r5
      ITTT eq
        ldreq r4, =brightness_high
        ldreq r5, =current_brightness
        streq r4, [r5]

      @ clear event
      ldr r0, =GPIOTE_EVENTS_IN1
      ldr r1, =0
      str r1, [r0]
      pop {r4, r5}
      pop {lr}
      bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler

@ r0: display_time
@ r1: memory address for the first image (highlight)
@ r2: memory address for the second image (weak)
@ r3: memory address for brightness
fade_images:
  push {lr}
  loop_fade_images:
    cmp r0, 0
    beq end_loop_fade_images
    push {r0}

    push {r1, r2, r3}
    ldr r0, =10
    mov r2, r3
    bl show_image_with_brightness
    pop {r1, r2, r3}

    push {r1, r2, r3}
    ldr r0, =1
    mov r1, r2
    mov r2, r3
    bl show_image_with_brightness
    pop {r1, r2, r3}

    pop {r0}
    sub r0, 1
    b loop_fade_images

  end_loop_fade_images:
    pop {lr}
    bx lr



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

brightness_low:
  .word 100
  .word 10000

brightness_default:
  .word 2050
  .word 8050

brightness_high:
  .word 10000
  .word 100

exit_loop_condition:
  .word 0

current_brightness:
  .word brightness_default

display_time:
  .word 200

sequential_images:
  .word empty
  .word partial_heart
  .word full_heart

brightness_end_stage_high:
  .word 300
  .word 1

brightness_end_stage_low:
  .word 1
  .word 300

boolean_show_higher_lower:
  .word 0  

heart_beat_fast:
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00100 @ Column 1
  .word 0b00010 @ Column 2
  .word 0b00001 @ Column 3
  .word 0b00010 @ Column 4
  .word 0b00100 @ Column 5
  .word 0b00100 @ Column 1
  .word 0b01000 @ Column 2
  .word 0b10000 @ Column 3
  .word 0b01000 @ Column 4
  .word 0b00100 @ Column 5 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 

heart_beat_slow:
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00100 @ Column 1
  .word 0b00100 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b00100 @ Column 4
  .word 0b00100 @ Column 5
  .word 0b00100 @ Column 1
  .word 0b00010 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b01000 @ Column 4
  .word 0b00100 @ Column 5
  .word 0b00100 @ Column 1
  .word 0b00100 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b00100 @ Column 4
  .word 0b00100 @ Column 5
  .word 0b00100 @ Column 1
  .word 0b00010 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b01000 @ Column 4
  .word 0b00100 @ Column 5  
  .word 0b00100 @ Column 1
  .word 0b00100 @ Column 2
  .word 0b00100 @ Column 3
  .word 0b00100 @ Column 4
  .word 0b00100 @ Column 5
  .word 0b00100 @ Column 1  
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000 
  .word 0b00000
