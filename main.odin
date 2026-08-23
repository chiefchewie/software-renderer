package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"

import "image"
import "object"

white :: image.Colour{255, 255, 255}
green :: image.Colour{0, 255, 0}
red :: image.Colour{255, 0, 0}
blue :: image.Colour{0, 0, 255}
yellow :: image.Colour{255, 255, 200}

// orthographic camera: drop z
project_point :: proc(point: [3]f64) -> [2]f64 {
	return point.xy
}

// convert a 2D point in [-1, 1]^2 to screenspace coords
point_to_screenspace :: proc(point: [2]f64, img: ^image.Image) -> [2]int {
	x := (point.x + 1) * 0.5 * f64(img.w - 1)
	y := (1 - point.y) * 0.5 * f64(img.h - 1)
	return [2]int{int(x), int(y)}
}

draw_mesh :: proc(img: ^image.Image, obj: ^object.WavefrontObject) {
	for face in obj.faces {
		u := point_to_screenspace(project_point(obj.vertices[face[0]]), img)
		v := point_to_screenspace(project_point(obj.vertices[face[1]]), img)
		w := point_to_screenspace(project_point(obj.vertices[face[2]]), img)
		random_colour := image.Colour {
			u8(rand.int_max(256)),
			u8(rand.int_max(256)),
			u8(rand.int_max(256)),
		}
		triangle(img, u, v, w, random_colour)
	}
}

signed_triangle_area :: proc(p1, p2, p3: [2]int) -> int {
	u := p2 - p1
	v := p3 - p1
	return linalg.cross(u, v)
}

contains :: proc(p1, p2, p3, p: [2]int) -> bool {
	return(
		signed_triangle_area(p, p1, p2) >= 0 &&
		signed_triangle_area(p, p2, p3) >= 0 &&
		signed_triangle_area(p, p3, p1) >= 0 \
	)
}

triangle :: proc(img: ^image.Image, p1, p2, p3: [2]int, colour: image.Colour) {
	if signed_triangle_area(p1, p2, p3) < 1 {
		return // cull triangles facing backwards or less than one pixel
	}

	maxx := math.max(p1.x, p2.x, p3.x)
	minx := math.min(p1.x, p2.x, p3.x)
	maxy := math.max(p1.y, p2.y, p3.y)
	miny := math.min(p1.y, p2.y, p3.y)

	// todo: SIMD this
	for x := minx; x <= maxx; x += 1 {
		for y := miny; y <= maxy; y += 1 {
			if contains(p1, p2, p3, {x, y}) {
				image.set_pixel(img, x, y, colour)
			}
		}
	}
}

main :: proc() {
	width :: 500
	height :: 500
	img := image.make_image(width, height)
	defer image.destroy_image(&img)

	diablo := object.parse_object_file("assets/diablo.obj")
	defer object.destroy_wave_front_object(&diablo)
	draw_mesh(&img, &diablo)

	image.save_image_as_ppm(&img, "output2.ppm")
}
