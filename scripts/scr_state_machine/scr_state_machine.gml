enum STATE_PRIORITY {
	LOW = 0,
	MEDIUM = 1,
	HIGH = 2,
	DEATH = 9
};

/// @function create_state
/// @param {string} _name Nome do estado
/// @param {real} _priority Prioridade do estado
/// @description Cria um novo estado com estrutura padronizada
function create_state(_name, _priority = STATE_PRIORITY.LOW) {
	return {
		name : _name, // Nome do estado
		priority : _priority, // Prioridade do estado
		timer : 0, // Timer do estado atual
		
		// Funções principais
		init : function() {},
		run : function() {},
		leave : function() {}
	}
}


// Inicia um estado
function state_init(_state) {
	// Previne múltiplas mudanças no mesmo frame
    if (_state == current_state) return;
	
	current_state = _state;
	current_state.timer = 0;
	current_state.init();
};

///@function Executa o estado atual (Utilizado no step event)
function state_run() {
	current_state.run();
};

///@function Serve para trocar o estado atual. Recebe o novo estado como parametro
function state_change(_state){
	// Previne múltiplas mudanças no mesmo frame
    if (_state == current_state) return;
	
	// Guarda o estado anterior
    previous_state = current_state;
	
	// Sai do estado atual
    current_state.leave();
	
	// Entra no novo estado
	current_state = _state;
	current_state.timer = 0; // Zerando o timer interno do estado
	
	// Chama o script de inicialização
	current_state.init();
};

#region Funções de ajuda
	
	// Força mudança ignorando prioridade
	force_state_change = function(_state) {
	    state_change(_state);
	};
	
	// Checa se está em um estado específico
	function current_state_is(_state) {
	    return current_state == _state;
	};
	
	// Checa se estava em um estado específico
	function previous_state_was(_state) {
	    return previous_state == _state;
	};
	
#endregion

















