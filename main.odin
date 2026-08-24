package main

import "image"
import "object"
import "renderer"

main :: proc() {
	width :: 500
	height :: 500
	img := image.make_image(width, height)
	defer image.destroy_image(&img)

	renderer.triangle(&img, {10, 45}, {400, 150}, {250, 470}, {1, 0, 0}, {0, 1, 0}, {0, 0, 1})

	// diablo := object.parse_object_file("assets/diablo.obj")
	// defer object.destroy_wave_front_object(&diablo)
	// draw_mesh(&img, &diablo)

	image.save_image_as_ppm(&img, "output2.ppm")
}
