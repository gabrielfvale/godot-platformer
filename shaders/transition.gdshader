shader_type canvas_item;


uniform float progress : hint_range(0, 1);
uniform float diamondPixelSize = 10.0;
uniform float progressScaler = 2.8;
uniform bool invert = false;

float when_lt(float x, float y) {
	if (invert) {
		return max(sign(x - y), 0.0);
	}
 	return max(sign(y - x), 0.0);
}

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	float p = progress;
	if (invert) {
		p = 1.0 - progress;
	}
	COLOR.a *=  when_lt(xDistance + yDistance + UV.x + UV.y, p * progressScaler);
}
