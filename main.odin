package main

import "core:fmt"
import "image"

white   :: image.Color{255, 255, 255}
green   :: image.Color{  0, 255,   0}
red     :: image.Color{255,   0,   0}
blue    :: image.Color{  0,   0, 255}
yellow  :: image.Color{255, 255, 200}

main :: proc() {
  width  :: 64
  height :: 64
  img := image.make_image(64, 64)
  defer image.destroy_image(&img)

  ax, ay := 7, 3
  bx, by := 12, 37
  cx, cy := 62, 53
  
  image.set_pixel(&img, ax, ay, red)
  image.set_pixel(&img, bx, by, green)
  image.set_pixel(&img, cx, cy, blue)

  image.line(&img, ax, ay, bx, by, red)
  image.line(&img, bx, by, cx, cy, green)
  image.line(&img, cx, cy, ax, ay, blue)

  image.save_image_as_ppm(&img, "output.ppm")
}
