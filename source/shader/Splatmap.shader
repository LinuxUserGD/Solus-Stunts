shader_type spatial;

uniform sampler2D tex1;
uniform sampler2D tex2;
uniform sampler2D tex3;
uniform sampler2D splatmap;

uniform float tex1res=1;
uniform float tex2res=1;
uniform float tex3res=1;


void fragment() {
	vec3 result;
	
	float tex1val = texture(splatmap, UV).g;
	float tex2val = texture(splatmap, UV).r;
	float tex3val = texture(splatmap, UV).b;
	
	vec3 tex1col = texture(tex1, UV*tex1res).rgb * tex1val;
	vec3 tex2col = texture(tex2, UV*tex2res).rgb * tex2val;
	vec3 tex3col = texture(tex3, UV*tex3res).rgb * tex3val;
	
	result = tex1col + tex2col + tex3col;
}
