// Função pra ser usada no create event caso a função controles for usada
function setup_controles() {
	jump_buffer_time = 3; // Janela de frames em que o pulo fica "Guardado"
	jump_buffered = false; // Indica se ha um pulo esperando a ser executado
	jump_buffer_timer = 0; // Contador regressivo do buffer (0 = sem buffer ativo)
}

// Função pra definir todos os controles que serão usados no jogo
function controles() {
	#region Direções
	
		left = keyboard_check(vk_left);
		right = keyboard_check(vk_right);
		up = keyboard_check(vk_up);
		down = keyboard_check(vk_down);
	
		horizontal_input = (right - left);
		vertical_input = (up - down);
	
	#endregion
	
	#region Ações
	
		#region Pulo
			jump = keyboard_check(ord("Z"));
			jump_press = keyboard_check_pressed(ord("Z"));
	
			
			// Se o botão de pulo for pressionado, inicia o buffer timer do pulo
			if (jump_press) {
				jump_buffer_timer = jump_buffer_time;
			}
	
			// Enquanto o timer não chegar a zero ...
			if (jump_buffer_timer > 0) {
				jump_buffered = true; // ... ativa o buffer (pulo guardado)
				jump_buffer_timer--; // ... e decrementa o timer em 1 a cada frame
			} else {
				jump_buffered = false; // Quando o contador chegar a zero descarta o pulo guardado
			}
	
		#endregion
		
		attack = keyboard_check(ord("X"));
		dash_run = keyboard_check(ord("C"));
		taunt = keyboard_check(ord("V"));
		
		heal = keyboard_check(ord("A"));
		chain = keyboard_check(ord("S"));
		// placeholder = keyboard_check(ord("D"));
		// placeholder = keyboard_check(ord("F"));
		
		map = keyboard_check(vk_tab);
		
		menu = keyboard_check_pressed(ord("Q"))
		// placeholder = keyboard_check(ord("W"));
		// placeholder = keyboard_check(ord("E"));
		restart = keyboard_check(ord("R"));
		
		pause = keyboard_check_pressed(vk_escape);
	
	#endregion
	
}