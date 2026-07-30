package image

import "core:fmt"
import "core:os"

Pixel :: [3]u8

Image :: struct {
  w: int,
  h: int,
  buffer: []Pixel,
}


make_image :: proc(width, height: int) -> Image {
  assert(width * height != 0)

  buffer := make([]Pixel, width * height)
  return Image {
    w = width,
    h = height,
    buffer = buffer
  }
}


destroy_image :: proc(image: ^Image) {
  delete(image.buffer)
}


set_pixel :: proc(image: ^Image, row: int, col: int, pixel: Pixel) {
  assert(0 <= row && row < image.w)
  assert(0 <= col && col < image.h)

  image.buffer[row * image.w + col] = pixel
}


get_pixel :: proc(image: ^Image, row: int, col: int) -> Pixel {
  assert(0 <= row && row < image.w)
  assert(0 <= col && col < image.h)

  return image.buffer[row * image.w + col]
}


save_image_as_ppm :: proc(image: ^Image, path: string) {
  handle, err := os.open(path, os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
  assert(err == nil)

  defer os.close(handle)

  // image header
  os.write(handle, transmute([]u8)string("P3\n"))
  os.write(handle, transmute([]u8)fmt.tprintf("%d %d\n", image.w, image.h))
  os.write(handle, transmute([]u8)string("255\n"))

  // contents
  for pixel in image.buffer {
    os.write(handle, 
      transmute([]u8)fmt.tprintf("%d %d %d ", pixel.r, pixel.g, pixel.b))
  }
}
