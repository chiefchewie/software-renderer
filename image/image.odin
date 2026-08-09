package image

import "core:fmt"
import "core:os"

Color :: [3]u8

Image :: struct {
  w: int,
  h: int,
  buffer: []Color,
}


make_image :: proc(width, height: int) -> Image {
  assert(width * height != 0)

  buffer := make([]Color, width * height)
  return Image {
    w = width,
    h = height,
    buffer = buffer
  }
}


destroy_image :: proc(image: ^Image) {
  delete(image.buffer)
}


set_pixel :: proc(image: ^Image, row: int, col: int, color: Color) {
  assert(0 <= row && row < image.w)
  assert(0 <= col && col < image.h)

  image.buffer[row * image.w + col] = color
}


get_pixel :: proc(image: ^Image, row: int, col: int) -> Color {
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
  for color in image.buffer {
    os.write(handle, 
      transmute([]u8)fmt.tprintf("%d %d %d ", color.r, color.g, color.b))
  }
}


line :: proc(img: ^Image, ax: int, ay: int, bx: int, by: int, color: Color) {
  assert(0 <= ax && ax <= img.h)
  assert(0 <= ay && ay <= img.w)
  assert(0 <= bx && bx <= img.h)
  assert(0 <= by && by <= img.w)

  ax := ax
  bx := bx
  ay := ay
  by := by

  is_steep := abs(ax - bx) < abs(ay - by)
  if is_steep {
    ax, ay = ay, ax
    bx, by = by, bx
  }

  if ax > bx {
    ax, bx = bx, ax
    ay, by = by, ay
  }

  for x in ax..=bx {
    t := f64(x - ax) / f64(bx-ax)
    y := int(f64(ay) + t*f64(by-ay))
    if is_steep {
      set_pixel(img, y, x, color)
    } else {
      set_pixel(img, x, y, color)
    }
  }
}
