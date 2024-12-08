shader_type canvas_item;

uniform vec4 player1[4] : source_color;
uniform vec4 player2[4] : source_color;
uniform vec4 player3[4] : source_color;
uniform vec4 player4[4] : source_color;
uniform int player;



bool colorCheck(vec4 color, vec4 test) {
	float threshold = 0.05;
	
	if (test.r > color.r - threshold 
	&& test.r < color.r + threshold
	&&
	test.g > color.g - threshold 
	&& test.g < color.g + threshold
	&&
	test.b > color.b - threshold 
	&& test.b < color.b + threshold)
	
	{
		return true;
	}
	
	
	return false;
}

void fragment() {
	if (player > 1) {
		vec4 pixel = texture(TEXTURE,UV);
		
		for (int c = 0; c < (player1.length()); c++) {
			if (colorCheck (pixel, player1[c])) {
				if (player == 2) {COLOR = player2[c];}
				if (player == 3) {COLOR = player3[c];}
				if (player == 4) {COLOR = player4[c];}
			}
		}
		
		
		//COLOR = pixel;
		}
	}
