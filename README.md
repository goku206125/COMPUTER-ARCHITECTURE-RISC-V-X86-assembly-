# Binary-turtle-Computer-architecture-


In computer graphics, turtle graphics are vector graphics using a relative cursor (the "turtle")
upon a Cartesian plane. The turtle has three attributes: a location, an orientation (or direction),
and a pen. The pen, too, has attributes: color, on/off (or up/down) state [2].
The turtle moves with commands that are relative to its own position, such as "move
forward 10 spaces" and "turn left 90 degrees". The pen carried by the turtle can also be
controlled, by enabling it or setting its color.
Your task is to write a program, which translates binary encoded turtle commands to a
raster image in a BMP file [1].
Turtle commands
The length of all turtle commands is 16 or 32 bits. The first two bits define one of four
commands (set position, set direction, move, set state). Unused bits in all commands are
marked by the – character. They should not be taken into account when the command is
decoded.
Set position command
The set position command sets the new coordinates of the turtle. It consists of two words. The
first word defines the command (bits 1-0) and X (bits x9-x0) coordinate of the new position.
The second word contains the Y (bits y5-y0) coordinate of the new position. The point (0,0) is
located in the bottom left corner of the image.
Table 1. The first word of the set position command.
bit no. 15 14 13 12 11 10 9 8
x9 x8 x7 x6 x5 x4 x3 x2
bit no. 7 6 5 4 3 2 1 0
x1 x0 - - - - 1 1
Table 2. The second word of the set position command.
bit no. 15 14 13 12 11 10 9 8
y5 y4 y3 y2 y1 y0 - -
bit no. 7 6 5 4 3 2 1 0
- - - - - - - -
Set direction command
The set direction command sets the direction in which the turtle will move, when a move
command is issued. The direction is defined by the d1, d0 bits.
Table 3. The set direction command.
bit no. 15 14 13 12 11 10 9 8
- - - - - - - -
bit no. 7 6 5 4 3 2 1 0
- - - - d1 d0 1 0

 49
Table 4. The description of the d1,d0 bits.
Bits d1,d0 Turtle direction
00 Right
01 Up
10 Left
11 Down
Move command
The move command moves the turtle in direction specified by the d1-d0 bits. The movement
distance is defined by the m9-m0 bits. If the destination point is located beyond the drawing
area the turtle should stop at the edge of the drawing. It can’t leave the drawing area. The
turtle leaves a visible trail when the pen is lowered (bit ud). The color of the trail is defined by
the r3-r0, g3-g0, b3-b0 bits.
Table 5. The move command.
bit no. 15 14 13 12 11 10 9 8
- - - - m9 m8 m7 m6
bit no. 7 6 5 4 3 2 1 0
m5 m4 m3 m2 m1 m0 0 1
Set pen state command
The pen state command defines whether the pen is raised or lowered (bit ud) and the color of
the trail. Bits c2-c0 select one of the predefined colors from the color table.
Table 6. The pen state command.
bit no. 15 14 13 12 11 10 9 8
c2 c1 c0 - - - - -
bit no. 7 6 5 4 3 2 1 0
- - - - ud - 0 0
Table 7. The description of the ud bit.
Table 8. Color table.
bits c2,c1,c0 Pen state
000 black
001 red
010 green
011 blue
100 yellow
101 cyan
110 purple
111 white

ud bit Pen state
0 pen raised (up)
1 pen lowered (down)
 50
Input
 binary file containing 16/32-bits turtle commands
 file name: “input.bin”
Output
 BMP file containing the generated image:
 Sub format: 24 bits RGB – no compression,
 Image size: 600x50 px,
 file name: “output.bmp”
