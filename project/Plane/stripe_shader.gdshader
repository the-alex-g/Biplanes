shader_type spatial;

// WARNING: pure white as a fin color does not work!
uniform vec3 fin_color = vec3(1, 0, 0);
uniform vec3 main_color = vec3(0, 0, 0);

void fragment() {
	float strength = distance(fin_color, COLOR.rgb) / distance(fin_color, vec3(1, 1, 1));
	if(strength > 0.3 && strength < 0.9) {
		ALBEDO = fin_color;
	} else {
		ALBEDO = main_color;
	}
}


void vertex() {
	if (VERTEX.x >= 5.1) {
		COLOR.rgb = fin_color;
	}
}