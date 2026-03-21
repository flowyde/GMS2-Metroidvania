function entity_collision(horizontal_speed, vertical_speed, collidables = obj_collision, grav = GRAVITY){
	// Aplicando a gravidade antes do movimento
	vertical_speed += grav;
	
	// Declarando variaveis de escopo local
	var _hspd 		=	horizontal_speed;
	var _vspd		=	vertical_speed;
	var _sign_h		=	sign(_hspd);
	var _sign_v		=	sign(_vspd);
	static __sub_pixel 	=	0.5;
	
	#region Movimento Horizontal
		// Checando a colisão horizontal
		if (place_meeting(x + _hspd, y, collidables)) {
			
			// Enquanto não estiver colidindo, soma a posição de X com o "sign" do sub pixel da velocidade horizontal
			var _check_pixel = __sub_pixel * _sign_h
			while (!place_meeting(x + _check_pixel, y, collidables)) {
				x += _check_pixel;
			}	
			
			// Se uma colisão for feita, então a velocidade horizontal é zero 
			_hspd = 0;
		}
	
		// Soma o valor X de acordo com a velocidade horizontal
		x += _hspd;
	
	#endregion
	
	#region Movimento Vertical
		
		// Checa se a velocidade vertical é maior que a velocidade terminal
		if (_vspd > TERM_VEL) {
			_vspd = TERM_VEL; // Limita para ser igual a velocidade terminal
		}
	
		// Checando a colisão vertical
		if (place_meeting(x, y + _vspd, collidables)) {
			
			// Enquanto não estiver colidindo, soma a posição de Y com o "sign" do sub pixel da velocidade vertical
			var _check_pixel = __sub_pixel * _sign_v
			while (!place_meeting(x, y + _check_pixel, collidables)) {
				y += _check_pixel;
			}
			
			// Se uma colisão for feita, então a velocidade vertical é zero
			_vspd = 0;
		}
	
		// Define uma variavel que checa se a entidade está colidindo com o chão
		var _on_ground = true;
		
		if ((_vspd >= 0) && place_meeting(x, y + 1, collidables)) {
			_on_ground = true;
		} else {
			_on_ground = false;
		}
	
		// Soma o valor de Y de acordo com a velocidade vertical
		y += _vspd;
	
	#endregion
	
	// Retornando os valores de velocidade horizontal e vertical
	return {
		hspd : _hspd,
		vspd : _vspd,
		on_ground : _on_ground
	};
}