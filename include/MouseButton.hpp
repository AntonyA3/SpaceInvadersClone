
enum MouseButtonState{
    MOUSE_BUTTON_STATE_UP,
    MOUSE_BUTTON_STATE_PRESSED,
    MOUSE_BUTTON_STATE_RELEASED,
    MOUSE_BUTTON_STATE_DOWN
};

struct MouseButton
{
    MouseButton(int button);
    int state;
    int button;
};

MouseButton::MouseButton(int button){
    this->button = button;
}
