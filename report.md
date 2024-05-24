# Report

<!-- Your text goes here. Remember to check the result of your CI to see whether 
the final PDF rendered correctly! -->

## Overview
The ARM program initializes by illuminating the center LED in accordance with the assignment specifications. It then cyclically displays the heartbeat in three phases: small heart, partial heart, and full heart. The program features three brightness levels, starting with a default setting of moderate brightness. Pressing button B increases both the heartbeat speed and screen brightness, while pressing button A decreases them. These adjustments allow for dynamic control within the defined bounds of the three brightness levels. Exceeding these levels disables the buttons and results in simulated heart failure, shown by outer LEDs dimming more than inner ones, symbolizing the heart's deterioration. The program concludes with a monitor graph that visually depicts the reason for the heart's failure and resets everything to default. The graph indicates whether the heart stopped due to excessive activity or lack thereof.

The program strictly adheres to the ARM syntax and associated rules, optimizing efficiency by selectively omitting unnecessary push and pop operations. Certain predefined values are stored in memory globally rather than locally, ensuring that modifications to these values have program-wide effects, even though the concept of "scope" in assembly language differs from higher-level languages.

The program is meticulously structured using functions, each containing distinct logic segments. Extensive testing was conducted on each function to verify the accuracy of link register values and the correct management of caller and callee-saved register values. Additionally, detailed comments have been included in areas where the logic may be challenging to comprehend.

## Implementation 
The program's initial layout involved a pen-and-paper approach to clearly define the desired final outcome. 

Initially, a function was developed to activate a single column by accessing an image's memory address. However, this function had limitations, as it could only display a fixed image section on a specific column. Recognizing this constraint, an enhancement was implemented to enable displaying any part of the image on any screen column making the function as general as possible.

Subsequently, the program introduced a dedicated function to display the entire image using a loop, leveraging the previously mentioned function. Initially, brightness considerations were not included in this implementation. However, as the project advanced and brightness became a critical factor, it became apparent that brightness management is multifaceted. Consequently, the functionality was integrated to prevent redundancy and optimize code efficiency. Upon successful implementation of the image display function, data memory was leveraged to store images essential for program execution. This strategic utilization of data memory was a foundational aspect of the initial design layout, significantly enhancing program efficiency. Additionally, this approach facilitated debugging by providing visual cues when necessary.

At this stage, it was crucial to enable button functionality. Help from lab resources was utilized for this purpose, although adapting the code for button B remained a bit unclear. To resolve this, guidance from the microbit manufacturer's documentation was reviewed for accurate integration. The buttons were disabled when the heart was in a failure state to prevent any unexpected behavior. 

The 'slide_image_show' function is designed to display a sliding animation of a graph across the screen. This function plays a crucial role in creating a dynamic and visually appealing effect, enhancing the overall user experience.

Finally, 'fade_images' function takes care of handling the brightness of different LEDs which is achieved as a way of masking one image over other.

## Analysis
The design choices incorporated in the provided assembly code were well-suited for the task for several crucial reasons. Primarily, the adoption of modular functions like display_image_with_brightness, iterate_images_with_brightness, and fade_images ensured a structured and reusable codebase. This organization not only improved maintainability but also facilitated scalability, allowing for easier integration of future enhancements.

While the specific column-displaying function would have sufficed for this program, efforts were dedicated to making it more general to enhance reusability, aligning with the SOLID principle.

Furthermore, the adoption of constants for memory addresses (such as GPIOTE_EVENTS_IN0, GPIOTE_EVENTS_IN1, etc.) and parameters (like display_time, brightness_default, etc.) contributed to enhanced code readability and flexibility. This practice streamlines future modifications or adjustments, as alterations to memory locations or parameter values can be managed centrally, ensuring consistency and ease of maintenance.

The function 'slide_image_show', responsible for displaying the sliding animation of the graph, was implemented in a somewhat rudimentary manner. While there is room for improvement, it was intentionally left this way to enhance readability. Additionally, a commented formula is provided within the code, which can be used to calculate the relevant parameters based on the number of images to be displayed in this manner. Furthermore, the function assumes that the image storage address contains references (i.e., addresses of the images) to facilitate a modular code structure.

A specialized If-then-else block was implemented to streamline comparisons effectively. To simplify condition checking, bits were stored in memory, especially within loops where tracking them became challenging.

A crucial function, 'init_prop_display_image', ensures the correct setup of the program by initializing all memory-defined values, such as brightness and conditions, to their expected default states at the start.



