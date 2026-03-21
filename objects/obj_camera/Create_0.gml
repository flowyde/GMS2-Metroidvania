camera = view_camera[0];
view_width_half = camera_get_view_width(camera) / 2;
view_height_half = camera_get_view_height(camera) / 2;

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