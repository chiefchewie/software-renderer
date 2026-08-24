package object

import "core:os"
import "core:strconv"
import "core:strings"

Vertex :: [3]f64
Face :: [3]int

WavefrontObject :: struct {
	vertices: [dynamic]Vertex,
	faces:    [dynamic]Face,
}

parse_object_file :: proc(filepath: string) -> WavefrontObject {
	data, err := os.read_entire_file_from_path(filepath, context.allocator)
	if err != nil {
		return {}
	}
	defer delete(data, context.allocator)

	obj := WavefrontObject{}
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		line := strings.trim_space(line)
		if len(line) == 0 || line[0] == '#' {
			continue
		}

		fields := strings.fields(line)
		if len(fields) == 0 {
			continue
		}

		switch fields[0] {
		case "v":
			x, _ := strconv.parse_f64(fields[1])
			y, _ := strconv.parse_f64(fields[2])
			z, _ := strconv.parse_f64(fields[3])
			assert(-1 <= x && x <= 1)
			assert(-1 <= y && y <= 1)
			assert(-1 <= z && z <= 1)
			append(&obj.vertices, Vertex{x, y, z})
		case "f":
			v1 := strings.split(fields[1], "/")[0]
			v2 := strings.split(fields[2], "/")[0]
			v3 := strings.split(fields[3], "/")[0]
			a, _ := strconv.parse_int(v1)
			b, _ := strconv.parse_int(v2)
			c, _ := strconv.parse_int(v3)
			append(&obj.faces, Face{a - 1, b - 1, c - 1})
		}
	}
	return obj
}

destroy_wave_front_object :: proc(obj: ^WavefrontObject) {
	delete(obj.vertices)
	delete(obj.faces)
}
