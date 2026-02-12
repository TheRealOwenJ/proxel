# Proxel; the not-so-great image programming language!
Proxel (Programming Pixel) is an esoteric programming language, so it's NOT made to be fun and games. (It is, though!)  

## Well, how do I use it?
To open a file you use:  
```bash
ruby main.rb file.prxl
```

## But how do I make a file ?
The basic syntax of proxel is:  
### The init line
For an image:  
```bash
init sizex sizey canvascolor pixelsize type image
```
For a video:  
```bash
init sizex sizey canvascolor pixelsize type video fps loop (if you don't want it to loop, remove loop.)
```
### The pixel lines
To code a pixel you type:  
```bash
x y color
```
### The frame lines
If you are coding a video, you need to separate your frames. You do this kind of like javascript:  
```bash
frame 1 (or whatever frame you're at) {
pixel line
}
```
### Colors
Red, Green, Blue, Yellow, White, Black, Gray, Cyan, Magenta, Orange, Purple, Brown, Pink and Lime.  

This was a fun little project of mine. I wont be maintaining this regularly.
