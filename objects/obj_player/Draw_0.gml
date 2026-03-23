draw_self();

//if (horizontal_input != 0 && vertical_input < 0) {
    //var _pogo_len = 30;
    //var _direction = point_direction(0, 0, horizontal_input, vertical_input);
    //var _spr_middle = sprite_get_height(spr_player_idle);
    //var _x = lengthdir_x(_pogo_len, _direction);
    //var _y = lengthdir_y(_pogo_len, _direction) + _spr_middle;
    //var _radius = 10;
    //var _outline = false;
    //draw_circle(x + _x, y + _y, _radius, _outline);
    //
    //if (can_jump && on_ground && keyboard_check_pressed(ord("K"))) {
        //// Altura desejada para o pogo
        //var _pogo_height = sprite_get_height(spr_player_idle) * 2;
        //
        //// Força total baseada na altura
        //var _total_force = sqrt(2 * GRAVITY * _pogo_height);
        //
        //// Aplicar a força na direção diagonal
        //hspd = lengthdir_x(_total_force, _direction);
        //vspd = lengthdir_y(_total_force, _direction);
        //
        //// Debug visual
        //image_blend = c_yellow;
        //show_debug_message("Pogo! Direction: " + string(_direction) + 
                          //" | hspd: " + string(hspd) + 
                          //" | vspd: " + string(vspd));
    //}
//}