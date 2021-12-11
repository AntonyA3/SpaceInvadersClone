
enum InputKeyState{
    INPUT_KEY_STATE_UP,
    INPUT_KEY_STATE_PRESSED,
    INPUT_KEY_STATE_RELEASED,
    INPUT_KEY_STATE_DOWN
};

struct InputKey
{
    InputKey(int key);
    int state = INPUT_KEY_STATE_UP;
    int key;
};

InputKey::InputKey(int key){
    this->key = key;
}
