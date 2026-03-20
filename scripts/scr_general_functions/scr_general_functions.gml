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
	
		jump = keyboard_check(ord("Z"));
		jump_press = keyboard_check_pressed(ord("Z"));
		
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