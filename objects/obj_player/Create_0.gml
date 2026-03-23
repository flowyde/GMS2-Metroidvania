//window_set_fullscreen(true);

#region Variaveis

	// Movimento
	acceleration = 1;
	hspd = 0; 
	max_hspd = 2;
	vspd = 0;
	max_vspd = 4;

	facing_direction = 1; // Armazena a direção em que o jogador está olhando
	
	#region Boleanas genericas
		on_ground = true; // Pra checar se o player está no chão
		can_move = true; // Pra checar se o player pode se mover
		can_turn = true; // Pra checar se o xscale pode ser alterado
		can_jump = true; // Pra checar se o player pode pular
		can_attack = true; // Pra checar se o jogador pode atacar
		can_dash = true; // Pra checar se o jogador pode performar um dash
	
	#endregion 

	#region Pulo
		
		max_jumps = 1; // Define a quantidade maxima de pulos que o jogador pode performar
		jump_count = 0; // Contador pra quantos pulos o jogador ja deu
		jump_hold_timer = 0; // Timer pra quantidade de tempo que o jogador pressionou pulo
		jump_force = 0; // Força do pulo
		
		// Valores pra cada Pulo bem sucedido
		max_jump_force	= [-3.4, -2.6]; // Define o valor maximo da força do pulo 1 & 2
		jump_window		= [18, 10]; 	// Tempo maximo (em frames) que o jogador pode pressionar o pulo 1 & 2

		// Coyote time
		coyote_window = 6; // Tempo maximo (em frames) que o player pode ficar no ar e ainda conseguir perfomar um pulo
		coyote_timer = coyote_window; // Tempo que falta pro player fazer o pulo estando no ar, famoso coyote time

		// Jump buffer
		jump_buffer_window = 10; // Janela de frames em que o pulo fica "Guardado"
		jump_buffer_timer = 0; // Contador regressivo do buffer (0 = sem buffer ativo)
		jump_buffered = false; // Indica se ha um pulo esperando a ser executado
	
	#endregion

	#region Pogo
	
	#endregion

	#region Dash

		max_dashes = 1; // Define a quantidade maxima de dashes que o jogador pode performar
		dash_count = 0; // Contador pra quantos dashes o jogador ja deu
		dash_speed = 6; // Define a velocidade em que o jogador vai do ponto original até a direção do dash
		dash_hspd = 0; // Velocidade horizontal do dash
		dash_vspd = 0; // Velocidade vertical do dash
		dash_direction = 0; // Armazena a direção do dash
		dash_duration = 15; // Duração do dash em frames
		dash_timer = 0; // Timer que conta a duração
		
		#region Inertia
			inertia_window = 100; // Tempo maximo em frames que o jogador pode apertar o botão de pulo enquanto faz um dash pra ganhar um boost
			
		#endregion		

	#endregion


#endregion

#region Metodos

	///@method Metodo padrão de movimentação
	movimento = function() {
		// Chamando o script de controles
		controles();
		
		// Verificando se o jogador pode performar um dash
		if (dash_run_press && dash_count < max_dashes && can_dash) {
		    state_change(states.dash);
		}
		
		if (can_attack && attack) {
			state_change(states.attack);
		}
		
		// Verificando se o jogador pode se mover
		if (can_move == true) {
			// Multiplicando a velocidade horizontal com o input e a velocidade maxima
			hspd = lerp(hspd, horizontal_input * max_hspd, acceleration);
		}/* else {
			hspd = 0; // Zerando a velociade instantaneamente
		}*/
		
		// Chamando o script de colisão padrão de entidades
		var _return = entity_collision(hspd, vspd);
		
		// Retornando os valores pós colisão
		hspd = _return.hspd
		vspd = _return.vspd;
		on_ground = _return.on_ground;
		
		// Se pode pular e o botão de pulo for pressionado, inicia o buffer timer do pulo
		if (can_jump && jump_press) {
			jump_buffer_timer = jump_buffer_window;
			state_change(states.jump); // 
		}
		
		// Se o buffer timer de pulo não chegar a zero ...
		if (jump_buffer_timer > 0) {
			jump_buffered = true; // ... ativa o buffer (pulo guardado)
			jump_buffer_timer--; // ... e decrementa o timer em 1 a cada frame
		} else {
			jump_buffered = false; // Quando o contador chegar a zero descarta o pulo guardado
		}
		
		// Se estiver no chão...
		if (on_ground == true) {
			jump_count = 0; // ... reseta a quantidade de pulos performados
			jump_hold_timer = 0; // ... reseta o timer de tempo que o jogador esta segurando o pulo
			coyote_timer = coyote_window // .. reseta o coyote time
			dash_count = 0; // ... reseta a quantidade de dashes performados
			can_dash = true;
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
		
		if (can_turn == true && horizontal_input != 0) {
			facing_direction = horizontal_input;
		}
		
		image_xscale = facing_direction;
	}
	
	// Metodo pra checar se a animação do player chegou ao fim
	animation_end = function() {
		// if (ev_animation_end) return true;
		
		var _sprite_spd = sprite_get_speed(sprite_index) / FPS;
		if (image_index + _sprite_spd >= image_number) {
			return true;
		}
	}
		
	#region Metodos de estados
		
		states = {};
		current_state = undefined;
		previous_state = undefined;
		
		//dbg_text(ref_create(self, "state_name"));

		states.idle 		= create_state("idle", STATE_PRIORITY.LOW);
		states.move 		= create_state("move", STATE_PRIORITY.LOW);
		states.jump 		= create_state("jump", STATE_PRIORITY.LOW);
		states.fall 		= create_state("fall", STATE_PRIORITY.LOW);
		states.crounch		= create_state("crounch", STATE_PRIORITY.LOW);
		states.look_up 		= create_state("look_up", STATE_PRIORITY.LOW);
		states.pogo			= create_state("pogo", STATE_PRIORITY.HIGH);
		states.dash 		= create_state("dash", STATE_PRIORITY.LOW);
		states.inertia		= create_state("inertia", STATE_PRIORITY.MEDIUM);
		states.attack 		= create_state("attack", STATE_PRIORITY.MEDIUM);
		//states.powerup_get 	= create_state("powerup_get", STATE_PRIORITY.HIGH);
		//states.powerup_wait = create_state("powerup_wait", STATE_PRIORITY.HIGH);
		//states.powerup_end 	= create_state("powerup_end", STATE_PRIORITY.HIGH);
		
		#region Idle
			states.idle.init = method(self, function() {
				can_move = true;
			});
			
			states.idle.run = method(self, function() {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_idle); // Chamando metodo pra trocar o sprite do player
				
				if (hspd != 0) 			{state_change(states.move); return;}
				if (vspd < 0) 			{state_change(states.jump); return;}
				if (vspd > 0) 			{state_change(states.fall); return;}
				if (up && hspd == 0) 	{state_change(states.look_up); return;}
				if (down) 				{state_change(states.crounch); return;}
			});
			
			states.idle.leave = method(self, function() {
				//show_debug_message("iedle");
				return;
			});
		#endregion

		#region Move
			states.move.init = method(self, function() {
				can_move = true;
			});
			
			states.move.run = method(self, function() {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_move); // Chamando metodo pra trocar o sprite do player
				
				if (vspd < 0) 	{state_change(states.jump); return;}
				if (vspd > 0) 	{state_change(states.fall); return;}
				if (hspd == 0) 	{state_change(states.idle); return;} // Estado parado se velocidade horizontal é 0
				if (down) 		{state_change(states.crounch); return;}
			});
				
			states.move.leave = method(self, function() {});
		#endregion

		#region Jumping
			states.jump.init = method(self, function () {
				can_move = true;
			});

			states.jump.run = method(self, function () {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_jump); // Chamando metodo pra trocar o sprite do player
				
				// Verificando se pode performar um pulo
				// Inicia o pulo nos seguintes casos:
				// Existe um pulo no buffer e a quantidade de pulos performados for menor ao maximo de pulos permitidos
				if ((coyote_timer > 0) || (jump_buffered && (jump_count < max_jumps))) {
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
				} else if (!jump){
					jump_hold_timer = 0; // Parando o timer se o jogador parar de pressionar o botão de pulo
				}
				
				#region Transição de estados
				
					if (attack && down && !on_ground) {
					    state_change(states.pogo);
						return;
					}
				
					// Estado caindo se a velocidade veritical for maior que 0	
					if (vspd > 0) {
						state_change(states.fall);
						return;
					}
				
					// Estado parado se encostou no chao
					if (on_ground) {
						state_change(states.idle);
						return;
					}
				#endregion
			});

			states.jump.leave = method(self, function () {});
		#endregion
		
		#region Falling
			states.fall.init = method(self, function () {
				can_move = true;
			});

			states.fall.run = method(self, function () {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_fall); // Chamando metodo pra trocar o sprite do player
				
				// Checando se o jogador apertou o botão de pulo enquanto ainda pode
				// Coyote time
				if ((coyote_timer > 0) && jump_press) {
					state_change(states.jump);
					return;
				}
				
				if (attack && down && !on_ground) {
					state_change(states.pogo);
					return;
				}
				
				// Checando se ja chegou ao chão
				if (on_ground) {
					//Estado de movendo se a velocidade horizontal for diferente de zero
					if (hspd != 0) {state_change(states.move); return;}
					
					// Fallback pra estado parado
					state_change(states.idle);
					return;
				}
			});

			states.fall.leave = method(self, function () {});
		#endregion

		#region Crounch
			states.crounch.init = method(self, function () {
				can_move = false;
				hspd = 0;
				vspd = 0;
			});

			states.crounch.run = method(self, function () {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_crounch); // Chamando metodo pra trocar o sprite do player
				
				if (!down) {
					state_change(states.idle);
					return;
				}
			});

			states.crounch.leave = method(self, function () {});
		#endregion

		#region Looking Up
			states.look_up.init = method(self, function () {
				can_move = true;
				can_turn = true;
				can_jump = true;
			});

			states.look_up.run = method(self, function () {
				movimento(); // Chamando o metodo padrão de movimento
				change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
				
				//if !on_ground || vspd != 0 {
					//state_change(states.jump);
				//}
				
				if (hspd != 0 || !up) {
					state_change(states.idle);
				}
			});

			states.look_up.leave = method(self, function () {});
		#endregion
				
		#region Pogo

			states.pogo.init = method(self, function () {
				can_move = false;
				can_attack = false;
				can_jump = false;
				can_turn = false;
				
				pogo_direction = point_direction(0, 0, facing_direction, -1);
				
				var _pogo_force = abs(max_jump_force[0]) * 1.2; // Força do avanço
				
				// Aplicar força diagonal
				hspd = lengthdir_x(_pogo_force, pogo_direction);
				vspd = -lengthdir_y(_pogo_force, pogo_direction); // += para somar com o pulo
				
				image_blend = c_yellow;
				
				pogo_done = false;
				pogo_jump_done = false;
				pogo_dash_done = false;
				pogo_duration = 16;
			});

			states.pogo.run = method(self, function () {
				controles();
				change_sprite(spr_player_pogo); // Placeholder
				
				// Incrementando o timer do pogo
				states.pogo.timer++;
				
				// Aplicar gravidade e movimento
		        var _return = entity_collision(hspd, vspd);
		        hspd = _return.hspd;
		        vspd = _return.vspd;
		        on_ground = _return.on_ground;
				
				// Condições de saída
				// Se colidiu, volta para idle
				if (on_ground || _return.hspd_col || _return.vspd_col) {
					state_change(states.idle);
					return;
				}
				
		        // Mínimo de tempo no estado para evitar saída instantânea
		        if (states.pogo.timer > pogo_duration) {
		            
		            // Se ainda está no ar
		            if (!on_ground) {
		                // Vai para jump se subindo, fall se descendo
		                if (vspd < 0) {
		                    state_change(states.jump);
		                } else {
		                    state_change(states.fall);
		                }
		                return;
		            }
		        }
				
			});

			states.pogo.leave = method(self, function () {
		        can_move = true;
		        can_attack = true;
		        can_jump = true;
		        can_turn = true;
		        image_blend = c_white; // Resetar cor
			});
	

		#endregion

		#region Dashing

			states.dash.init = method(self, function () {
				can_turn = false;
				can_move = false;
				
				// Checa se existe algum input do jogador para determinar a direção do dash
				// Se não, utiliza a direção em que o personagem está olhando
				if (horizontal_input != 0 || vertical_input != 0)
					dash_direction = point_direction(0, 0, horizontal_input, vertical_input);
				else
					dash_direction = (facing_direction > 0) ? 0 : 180;
				
				// Definindo as velocidades horizontal e vertical do dash
				dash_hspd = lengthdir_x(dash_speed, dash_direction);
				dash_vspd = lengthdir_y(-dash_speed, dash_direction);
				
				// Inicia o timer do dash
				// states.dash.timer = dash_duration;
				
				// Incrementando a quantidade de dashes performados
				dash_count++;
				
				// Efeito de screen shake
				obj_camera.screen_shake(5, dash_duration);
				
				image_blend = c_aqua;
				
				if sign(dash_hspd) != 0
					facing_direction = sign(dash_hspd)
			})

			states.dash.run = method(self, function () {
				
				// Utilizando os valores horizontal e vertical do dash para colisao
				var _return = entity_collision(dash_hspd, dash_vspd,, 0);
				
				hspd = _return.hspd;
				vspd = _return.vspd;
				on_ground = _return.on_ground;
				
				change_sprite(spr_player_jump);
				
				// Incrementando o timer de dash
				states.dash.timer++;
				
		        // Termina o dash quando o timer passa a duração do dash
		        if (states.dash.timer > dash_duration) {
					if (!on_ground) {
						state_change(states.fall);
						return;
					}
					
					// Fallback pra estado idle
		            state_change(states.idle);
		            return;
		        }
		        
		        // Sair do dash mais cedo se colidir
		        if (_return.hspd_col || _return.vspd_col) {
					if (!on_ground) {
						state_change(states.fall);
						return;
					}
					
		            state_change(states.idle);
		            return;
		        }
			})

			states.dash.leave = method(self, function () {
				can_turn = true;
				can_move = true;

				// Zerando as velocidades de dash
				dash_hspd = 0;
				dash_vspd = 0;
				
				// vspd = 0;
				
				image_blend = c_white;
			})
		
		#endregion

		#region Inertia

			states.inertia.init = method(self, function () {
				image_blend = c_fuchsia;
			});
	
			states.inertia.run = method(self, function () {
				states.inertia.timer++;
				if states.inertia.timer == inertia_window
					image_blend = c_green
				
			});
	
			states.inertia.leave = method(self, function () {
				
			});
		
		#endregion

		#region Attacking
			states.attack.init = method(self, function () {
				can_move = false;
				can_turn = false;
				can_jump = false;
				can_attack = false; // Evita do player atacar enquanto ataca
			});

			states.attack.run = method(self, function () {
				// Zerando a velocidade horizontal e vertical
				// Evita de herdar velocidade de outros estados
				hspd = lerp(hspd, 0, 0.25);
				vspd = lerp(vspd, 0, 0.25);
				
				movimento();
				static _combo_sprites = [
					spr_player_attack,
					spr_player_double_attack,
				];
				static _combo_index = 0;
				
				change_sprite(_combo_sprites[_combo_index]); // Chamando metodo pra trocar o sprite do player
				
				// Trocando para o estado de parado quando a animação de ataque acabar
				if (animation_end()) {
					_combo_index = (_combo_index + 1) mod array_length(_combo_sprites);
					state_change(states.idle);
					return;
				}
			});

			states.attack.leave = method(self, function () {
				can_move = true;
				can_turn = true;
				can_attack = true;
				can_jump = true;
			});
		#endregion

/*
		#region Powerup
			states.powerup_get = function() {
				// Esse estado serve para quando o player conseguir um power up
				state_name = "powerup_get"; // Nome do estado, usado em debug
				can_move = false;
				change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
				
				// Trocando do estado inicial de power up para o powerup wait
				if (animation_end()) {
					current_state = states.powerup_wait;
				}
			}
			states.crounch.init = method(self, function () {});
			states.crounch.run = method(self, function () {});
			states.crounch.leave = method(self, function () {});
			
			states.powerup_wait = function() {
				// Aqui aparecerá um dialogo mostrando qual power up o player conseguiu
				state_name = "powerup_wait"; // Nome do estado, usado em debug
				can_move = false;
				change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
				
				// Trocando do estado de power up para o powerup_wait
				if (animation_end()) {
					current_state = states.powerup_end;
				}
			}
			states.crounch.init = method(self, function () {});
			states.crounch.run = method(self, function () {});
			states.crounch.leave = method(self, function () {});
			
			states.powerup_end = function() {
				// Esse estado é chamado quando o player chegou ao final do dialogo do powerup
				state_name = "powerup_end"; // Nome do estado, usado em debug
				can_move = false;
				change_sprite(spr_player_powerup); // Chamando metodo pra trocar o sprite do player
				
				// Trocando do estado de power up para o idle
				if (animation_end()) {
					current_state = states.idle;
				}
			}

			states.crounch.init = method(self, function () {});
			states.crounch.run = method(self, function () {});
			states.crounch.leave = method(self, function () {});
		#endregion
*/

	
	#endregion

#endregion

// Estado padrão do player é o idle
current_state = states.idle;
state_init(states.idle);


