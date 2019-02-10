shader_type spatial;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform float texres=1;
uniform sampler2D texture_splatmap: hint_albedo;




void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV*texres);
	vec4 splatmap_tex = texture(texture_splatmap,UV);
	ALBEDO = 2.0 * albedo.rgb * albedo_tex.rgb + 4.0 * splatmap_tex.rgb;
	float roughness_tex = dot(texture(texture_roughness,UV*texres),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMALMAP = texture(texture_normal,UV*texres).rgb;
}

