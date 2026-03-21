//window_set_fullscreen(true);

#region Variaveis

	// Movimento
	acceleration = 1;
	hspd = 0; 
	max_hspd = 2;
	vspd = 0;
	max_vspd = 4;
	
	// Pra checar se o player está no chão
	on_ground = true;

	#region Pulo
		
		jump_buffer_time = 3; // Janela de frames em que o pulo fica "Guardado"
		jump_buffered = false; // Indica se ha um pulo esperando a ser executado
		jump_buffer_timer = 0; // Contador regressivo do buffer (0 = sem buffer ativo)

		max_jumps = 2; // Define a quantidade maxima de pulos que o jogador pode performar
		jump_count = 0; // Contador pra quantos pulos o jogador ja deu
		jump_hold_timer = 0; // Timer pra quantidade de tempo que o jogador pressionou pulo
		jump_force = 0; // Força do pulo
		
		// Valores pra cada Pulo bem sucedido
		max_jump_force	= [-3.4, -2.6]; // Define o valor maximo da força do pulo 1 & 2
		jump_window		= [18, 10]; 	// Tempo maximo (em frames) que o jogador pode pressionar o pulo 1 & 2
		
		// Coyote time
		coyote_window = 8; // Tempo maximo (em frames) que o player pode ficar no ar e ainda conseguir perfomar um pulo
		coyote_timer = coyote_window; // Tempo que falta pro player fazer o pulo estando no ar, famoso coyote time
	
	#endregion

#endregion

#region Metodos

	// Metodo padrão de movimentação
	movimento = function() {
		// Chamando o script de controles
		controles();
		
		if (attack) current_state = states.attack;
		
		// Multiplicando a velocidade horizontal com o input e a velocidade maxima
	    hspd = lerp(hspd, horizontal_input * max_hspd, acceleration);
		
		// Não necessariamente o player está no modo de pulo quando ele aperta o botão de pulo,
		// Então apenas guardamos o pulo no buffer
		// Se o botão de pulo for pressionado, inicia o buffer timer do pulo
		if (jump_press) {
			jump_buffer_timer = jump_buffer_time;
			current_state = states.jump;
		}
	
		// Se o buffer timer não chegar a zero ...
		if (jump_buffer_timer > 0) {
			jump_buffered = true; // ... ativa o buffer (pulo guardado)
			jump_buffer_timer--; // ... e decrementa o timer em 1 a cada frame
		} else {
			jump_buffered = false; // Quando o contador chegar a zero descarta o pulo guardado
		}
		
		// Chamando o script de movimento padrão de entidades
		var _return = entity_movement(hspd, vspd);
		
		hspd = _return.hspd;
		vspd = _return.vspd;
		on_ground = _return.on_ground;
		
		// Se estiver no chão...
		if (on_ground == true) {
			jump_count = 0; // ... reseta a quantidade de pulos performados
			jump_hold_timer = 0; // ... reseta o timer de tempo que o jogador esta segurando o pulo
			coyote_timer = coyote_window // .. reseta o coyote time
		} else {
			// Coyote time: permite que o player possa pular alguns frames apos sair do chao
			if (coyote_timer > 0) {
				coyote_timer--;
			} else { 
				// Garantindo que se o player estiver no ar, jump_count seja pelo menos 1
				jump_count = max(jump_count, 1); 
			}
		}
		
	}
	
	// Metodo pra trocar o sprite do player
	change_sprite = function(_sprite = spr_player_idle_old) {
		if (sprite_index != _sprite) {
			sprite_index = _sprite;
			image_index = 0;
		}
		
		if (hspd != 0) {
			image_xscale = horizontal_input;
		}
	}
	
	// Metodo pra checar se a animação do player chegou ao fim
	animation_end = function() {
		// if (ev_animation_end) return true;
		
		var _sprite_spd = sprite_get_speed(sprite_index) / FPS;
		if (image_index + _sprite_spd >= image_number) {
			return true;
		}
	}
		
	#region Metodo de estados
		
		states = {};
		state_name = "";
		current_state = noone;
		
		dbg_text(ref_create(self, "state_name"));
		
		states.idle = function(){
			state_name = "idle"; // Nome do estado, usado em debug
			movimento(); // Chamando o metodo padrão de movimento
			change_sprite(spr_player_idle); // Chamando metodo pra trocar o sprite do player
			
			if (hspd != 0) {
				current_state = states.move;
			}
			if (vspd != 0) {
				current_state = states.jump;
			}
			if (down && hspd == 0) {
				current_state = states.crounch;
			}
		};
		
		states.move = function(){
			state_name = "move"; // Nome do estado, usado em debug
			movimento(); // Chamando o metodo padrão de movimento
			change_sprite(spr_player_move); // Chamando metodo pra trocar o sprite do player
			
			#region Transição de estados
			
				// Estado parado se velocidade horizontal é 0
				if (hspd == 0) {
					current_state = states.idle;
				}
				
				// Estado de pulo se velocidade vertical é diferente de 0
				if (vspd != 0) {
					current_state = states.jump;
				}
			#endregion
		};
		
		states.crounch = function(){
			state_name = "crounch"; // Nome do estado, usado em debug
			movimento(); // Chamando o metodo padrão de movimento
			change_sprite(spr_player_crounch); // Chamando metodo pra trocar o sprite do player
			
			if (hspd != 0 || vspd != 0 || !down) {
				current_state = states.idle;
			}
		};
		
		states.jump = function(){
			state_name = "jump"; // Nome do estado, usado em debug
			movimento(); // Chamando o metodo padrão de movimento
			change_sprite(spr_player_jump); // Chamando metodo pra trocar o sprite do player
			
			// Verificando se pode performar um pulo
			// Inicia o pulo se tiver um pulo no buffer e a quantidade de pulos performados for menor ao maximo de pulos permitidos
			if (jump_buffered && (jump_count < max_jumps)) {
				jump_count++; // Incrementando a quantidade de pulos performados
				
				// Variavel pra armazenar o indice do pulo
				// Protege de valores que ultrapassam o limite do array
				var _jump_index = clamp(jump_count - 1, 0, array_length(max_jump_force) - 1);
				
				vspd = max_jump_force[_jump_index]; // Aplica a força de pulo na velocidade horizontal
				jump_hold_timer = jump_window[_jump_index]; // Iniciando o timer de pulo
				
				// Limpando o buffer do pulo
				jump_buffered = false;
				jump_buffer_timer = 0;
				coyote_timer = 0;
				
				// change_sprite(spr_player_jump); // Troca a sprite pra animação de pulo duplo
			}
			
			// Aplica a força de pulo de acordo com o timer de segurada do botão de pulo
			if (jump && jump_hold_timer > 0) {
				// Variavel pra armazenar o indice do pulo
				// Protege de valores que ultrapassam o limite do array
				var _jump_index = clamp(jump_count - 1, 0, array_length(max_jump_force) - 1);
				
				vspd = max_jump_force[_jump_index]; // Aplica a força de pulo na velocidade horizontal
				jump_hold_timer--; // Decrementando o timer
			} else {
				jump_hold_timer = 0; // Parando o timer se o jogador parar de pressionar o botão de pulo
			}
			
			#region Transição de estados
			
				// Estado parado se encostou no chao
				if (on_ground) {
					current_state = states.idle;
				}
			
				// Estado caindo se a velocidade veritical for maior que 0	
				if (vspd > 0) {
					current_state = states.fall;
				}
			#endregion
		};
		
		states.fall = function(){
			state_name = "fall"; // Nome do estado, usado em debug
			movimento(); // Chamando o metodo padrão de movimento
			change_sprite(spr_player_fall); // Chamando metodo pra trocar o sprite do player
			
			// Estado de parado quando pisar no chão
			if (on_ground) {
				current_state = states.idle;
			}
		};
		
		states.attack = function() {
			// Esse estado serve para quando o player conseguir um power up
			state_name = "attack"; // Nome do estado, usado em debug
			movimento();
			change_sprite(spr_player_attack); // Chamando metodo pra trocar o sprite do player
			
			// Trocando para o estado de parado quando a animação de ataque acabar
			if (animation_end()) {
				current_state = states.idle;
			}
		}

		states.powerup_get = function() {
			// Esse estado serve para quando o player conseguir um power up
			state_name = "powerup_get"; // Nome do estado, usado em debug
			change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
			
			// Trocando do estado inicial de power up para o powerup wait
			if (animation_end()) {
				current_state = states.powerup_wait;
			}
		}
		
		states.powerup_wait = function() {
			// Aqui aparecerá um dialogo mostrando qual power up o player conseguiu
			state_name = "powerup_wait"; // Nome do estado, usado em debug
			change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
			
			// Trocando do estado de power up para o powerup_wait
			if (animation_end()) {
				current_state = states.powerup_end;
			}
		}
		
		states.powerup_end = function() {
			// Esse estado é chamado quando o player chegou ao final do dialogo do powerup
			state_name = "powerup_end"; // Nome do estado, usado em debug
			change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
			
			// Trocando do estado de power up para o idle
			if (animation_end()) {
				current_state = states.idle;
			}
		}
	
	#endregion

#endregion

// Estado padrão do player é o idle
current_state = states.idle;