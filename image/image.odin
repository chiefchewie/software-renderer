package image

import "core:fmt"
import "core:os"

Colour :: [3]u8

Image :: struct {
	w:      int,
	h:      int,
	buffer: []Colour,
}

make_image :: proc(width, height: int) -> Image {
	assert(width > 0 && height > 0)

	buffer := make([]Colour, width * height)
	return Image{w = width, h = height, buffer = buffer}
}

destroy_image :: proc(image: ^Image) {
	delete(image.buffer)
}

set_pixel :: proc(image: ^Image, x, y: int, color: Colour) {
	assert(0 <= x && x < image.w)
	assert(0 <= y && y < image.h)

	image.buffer[y * image.w + x] = color
}

get_pixel :: proc(image: ^Image, x, y: int) -> Colour {
	assert(0 <= x && x < image.w)
	assert(0 <= y && y < image.h)

	return image.buffer[y * image.w + x]
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
		os.write(handle, transmute([]u8)fmt.tprintf("%d %d %d ", color.r, color.g, color.b))
	}
}

line :: proc(img: ^Image, a: [2]int, b: [2]int, color: Colour) {
	assert(0 <= a.x && a.x < img.w)
	assert(0 <= a.y && a.y < img.h)
	assert(0 <= b.x && b.x < img.w)
	assert(0 <= b.y && b.y < img.h)

	a := a
	b := b

	is_steep := abs(a.x - b.x) < abs(a.y - b.y)
	if is_steep {
		a.xy = a.yx
		b.xy = b.yx
	}

	if a.x > b.x {
		a.x, b.x = b.x, a.x
		a.y, b.y = b.y, a.y
	}

	y := f64(a.y)
	for x in a.x ..= b.x {
		if is_steep {
			set_pixel(img, int(y), x, color)
		} else {
			set_pixel(img, x, int(y), color)
		}
		y += f64(b.y - a.y) / f64(b.x - a.x)
	}
}
