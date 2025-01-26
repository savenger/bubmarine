shader_type spatial;

uniform sampler2D bubble_texture : hint_normal; // Текстура пузырьков
uniform float speed : hint_range(0.1, 10.0) = 1.0; // Скорость движения пузырьков
uniform float life_time : hint_range(1.0, 10.0) = 3.0; // Время жизни пузырьков

void fragment() {
    // Используем текстуру пузырьков
    vec4 bubble_color = texture(bubble_texture, UV);

    // Определяем время жизни пузырька с использованием времени
    float time_alive = mod(TIME * speed, life_time);

    // Прозрачность пузырька
    float alpha = 1.0 - smoothstep(0.0, life_time, time_alive);

    // Применяем прозрачность
    bubble_color.a *= alpha;

    // Рендерим пузырёк
    ALBEDO = bubble_color.rgb;
    ALPHA = bubble_color.a;
}

vec3 offset = vec3(randf(), randf(), randf()) * 0.05; // случайное смещение
VERTEX += offset;