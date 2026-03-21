enum STATE_PRIORITY {
	LOW = 0,
	MEDIUM = 1,
	HIGH = 2,
	DEATH = 9
}

// Constructor de estado
function State(_name, _priority = STATE_PRIORITY.LOW) constructor {
	name = _name; // Nome do estado
	priority = _priority; // Prioridade do estado
	timer = 0; // Timer do estado atual
	
	// Funções principais
	start = function() {};
	run = function() {};
	leave = function() {};
}

function state_start(_state) {
	current_state = _state;
	current_state.start();
}

function state_run() {
	current_state.run();
}

function state_change(_state){
	current_state.leave();
	current_state = _state;
	current_state.start();
}