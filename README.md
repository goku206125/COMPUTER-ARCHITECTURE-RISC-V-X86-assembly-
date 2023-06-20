**Project Summary: Turtle Graphics to BMP Converter**

This project involves creating a program that translates binary-encoded turtle graphics commands into a raster image in a BMP file format. Turtle graphics is a vector graphics system that uses a relative cursor (the "turtle") on a Cartesian plane. The turtle has three attributes: a location, an orientation (or direction), and a pen. The pen also has attributes such as color and on/off (or up/down) state.

**Input:**
- A binary file containing 16/32-bit turtle commands
- File name: "input.bin"

**Output:**
- A BMP file containing the generated image
- Sub format: 24 bits RGB – no compression
- Image size: 600x50 px
- File name: "output.bmp"

**Turtle Commands:**
1. Set Position Command: Sets the new coordinates of the turtle.
2. Set Direction Command: Sets the direction in which the turtle will move.
3. Move Command: Moves the turtle in the specified direction with a specified distance. The turtle leaves a visible trail when the pen is lowered, and the color of the trail is defined by the RGB bits.
4. Set Pen State Command: Defines whether the pen is raised or lowered and the color of the trail using predefined colors from the color table.

The program should decode turtle commands from the input binary file, execute the commands, and generate an output BMP file with the turtle graphics raster image.
