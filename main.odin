package main


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
    image.line(img, u, v, green)
    image.line(img, v, w, green)
    image.line(img, w, u, green)
  }
}


main :: proc() {
  width  :: 500
  height :: 500
  img := image.make_image(width, height)
  defer image.destroy_image(&img)

  diablo := object.parse_object_file("assets/diablo.obj")
  defer object.destroy_wave_front_object(&diablo)
  draw_mesh(&img, &diablo)

  image.save_image_as_ppm(&img, "output.ppm")
}
