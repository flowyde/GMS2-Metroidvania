camera = view_camera[0];

target = obj_player;
target_x = xstart;
target_y = ystart;

shake_len = 0;
shake_str = 0;
shake_value = 0;

function screen_shake(shake_strengh, shake_lenght) {
	if (shake_strengh > shake_value) {
		shake_str = shake_strengh;
		shake_value = shake_str;
		shake_len = shake_lenght;
	}
}