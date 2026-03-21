// Checando se tem um alvo para seguir e atualizar a posição da camera
if !(instance_exists(target)) {
	exit;
} else {
	target_x = target.x;
	target_y = target.y;
}

// Atualizando a posição na camera
x += (target_x - x) / 1.5;
y += (target_y - y) / 1.5;

// Mantem a camera no centro da room
x = clamp(x, view_width_half, room_width - view_width_half);
y = clamp(y, view_height_half, room_height - view_height_half);

// Efeito de Screenshake com um valor aleatorio negativo e positivo de shake_value
x += random_range(-shake_value,shake_value);
y += random_range(-shake_value,shake_value);

// Gradualmente decrementando o shake_value
shake_value = max(0, shake_value - ((1/shake_len) * shake_str));

// Mantendo a camera no centro da tela
camera_set_view_pos(camera, x - view_width_half, y - view_height_half);