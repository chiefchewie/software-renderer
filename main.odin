package main

import "core:fmt"
import "image"


white   :: image.Pixel{255, 255, 255}
green   :: image.Pixel{  0, 255,   0}
red     :: image.Pixel{255,   0,   0}
blue    :: image.Pixel{  0,   0, 255}
yellow  :: image.Pixel{255, 255, 200}

main :: proc() {
  width  :: 64
  height :: 64
  img := image.make_image(64, 64)
  defer image.destroy_image(&img)

  ax, ay := 7, 3
  bx, by := 12, 37
  cx, cy := 62, 53
  
  image.set_pixel(&img, ax, ay, white)
  image.set_pixel(&img, bx, by, white)
  image.set_pixel(&img, cx, cy, white)

  image.save_image_as_ppm(&img, "output.ppm")
}
