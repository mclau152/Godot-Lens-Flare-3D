shader_type spatial;

uniform sampler2D albedo_texture;
uniform sampler2D texture_noise;
uniform float noise_intensity = 0.5;
uniform float uv_scale = 1.0;

void fragment() {
    vec2 uv = UV;
    vec4 albedo_tex = texture(albedo_texture, uv * uv_scale);
    vec4 noise_tex = texture(texture_noise, uv * 2.0); // Scale the noise texture

    vec4 mixed_tex = mix(albedo_tex, noise_tex, noise_intensity);
    ALBEDO = mixed_tex.rgb;
}
