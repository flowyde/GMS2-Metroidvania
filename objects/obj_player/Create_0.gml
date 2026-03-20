//window_set_fullscreen(true);
setup_controles();

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

max_jumps = 2; // Define a quantidade maxima de pulos que o jogador pode performar
jump_count = 0; // Contador pra quantos pulos o jogador ja deu
jump_hold_timer = 0; // Timer pra quantidade de tempo que o jogador pressionou pulo
jump_force = 0; // Força do pulo

// Valores pra cada Pulo bem sucedido
max_jump_force[0] 	= -3.4; // Define o valor maximo da força do pulo 1
jump_window[0] = 18; 	// Tempo maximo (em frames) que o jogador pode pressionar o pulo 1

max_jump_force[1] 	= -2.6; // Define o valor maximo da força do pulo 2
jump_window[1] = 10; 	// Tempo maximo (em frames) que o jogador pode pressionar o pulo 2

// Coyote time
coyote_window = 20; // Tempo maximo (em frames) que o player pode ficar no ar e ainda conseguir perfomar um pulo
coyote_jump_timer = coyote_window; // Tempo que falta pro player fazer o pulo estando no ar


#endregion

#endregion

#region Metodos

// Metodo de movimentação
movimento = function() {
	// Chamando o script de controles
	controles();
	
	// Multiplicando a velocidade horizontal com o input e a velocidade maxima
    hspd = lerp(hspd, horizontal_input * max_hspd, acceleration);
	
	// Só inicia o pulo se tiver um pulo no buffer e a quantidade de pulos performados for menor ao maximo de pulos permitidos
	if (jump_buffered && (jump_count < max_jumps)) {
		// Resetando o buffer do pulo
		jump_buffered = false;
		jump_buffer_timer = 0;
		
		// Incrementando a quantidade de pulos performados 
		jump_count++;
		
		// Iniciando o timer de pulo
		jump_hold_timer = jump_window[jump_count - 1];
		
	}
	
	if not jump {
		jump_hold_timer = 0; // Parando o timer se o jogador parar de pressionar o botão de pulo
	}
	
	// Aplica a força de pulo de acordo com o timer de segurada do botão de pulo
	if (jump_hold_timer > 0) {
		// Aplica a força de pulo na velocidade horizontal
		vspd = max_jump_force[jump_count - 1];
		
		jump_hold_timer--; // Decrementando o timer
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
	} else {
		// Garantindo que se o player estiver no ar, não possa dar um pulo extra
		if (jump_count == 0) {
			jump_count = 1;
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
	
// Metodo de estados
states = {};
state_name = "";
current_state = noone;

dbg_text(ref_create(self, "state_name"));

states.idle = function(){
	state_name = "idle"; // Nome do estado, usado em debug
	change_sprite(spr_player_idle); // Chamando metodo pra trocar o sprite do player
	
	if (hspd != 0) {
		current_state = states.move;
	}
	if (vspd != 0) {
		current_state = states.jump;
	}
};

states.move = function(){
	state_name = "move"; // Nome do estado, usado em debug
	change_sprite(spr_player_move); // Chamando metodo pra trocar o sprite do player
	
	if (hspd == 0) {
		current_state = states.idle;
	}
	
	if (vspd != 0) {
		current_state = states.jump;
	}
};

states.jump = function(){
	state_name = "jump"; // Nome do estado, usado em debug
	change_sprite(spr_player_jump); // Chamando metodo pra trocar o sprite do player
	
	if (hspd == 0) && (vspd == 0) {
		current_state = states.idle;
	}
	
	if (vspd > 0) {
		current_state = states.fall;
	}
};

states.fall = function(){
	state_name = "fall"; // Nome do estado, usado em debug
	change_sprite(spr_player_fall); // Chamando metodo pra trocar o sprite do player
	
	if (vspd == 0) {
		current_state = states.idle;
	}
};

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


current_state = states.idle;