// ECS610U -- Miles Hansard

precision highp float;

uniform mat4 modelview, modelview_inv, projection, view_inv;

uniform struct {
    vec4 position, ambient, diffuse, specular;  
} light;

uniform bool render_skybox, render_texture;
uniform samplerCube cubemap;
uniform sampler2D texture;

varying vec2 map;
varying vec3 d, m;
varying vec4 p, q;

// Gamma Transformation from Week 10 Lecture B slides by Miles Hansard
vec4 gamma_transform(vec4 colour, float gamma) {
    return vec4(pow(colour.rgb, vec3(gamma)), colour.a);
}

float canvas_width = 850.0;
vec4 material_colour;

// C4 Vignette Function
float vignette(vec2 fragCoord)
{
    float distance = length(fragCoord / canvas_width - 0.5);
    float strength = smoothstep(0.5, 0.8, 1.0 - distance);
    return strength;
}


void main()
{ 
    vec3 n = normalize(m);

    if(render_skybox) {
        gl_FragColor = textureCube(cubemap,vec3(-d.x,d.y,d.z));
        // set fragment to white -- for debugging only
        //gl_FragColor = vec4(1.0);

        // Get the vignetting effect strength
        float vignetteStrength = vignette(gl_FragCoord.xy);

        // scale the final fragment rgb by vignette value
        gl_FragColor.rgb *= vignetteStrength;
    }
    else {
        // object colour
        //material_colour = gamma_transform(texture2D(texture,map), 2.0);
        material_colour = vec4(0.5, 0.5, 0.5, 1.0);

        //if(gl_FragCoord.x > canvas_width/2.0) {
            // do gamma transformation here
        //    material_colour = gamma_transform(texture2D(texture,map), 1.0);
        //}

        // sources and target directions 
        vec3 s = normalize(q.xyz - p.xyz);
        vec3 t = normalize(-p.xyz);

        // reflection vector in world coordinates
        vec3 r = (view_inv * vec4(reflect(-t,n),0.0)).xyz;

        // reflected background colour
        vec4 reflection_colour = textureCube(cubemap,vec3(-r.x,r.y,r.z));

        // blinn-phong lighting

        vec4 ambient = material_colour * light.ambient;
        vec4 diffuse = material_colour * max(dot(s,n),0.0) * light.diffuse;

        // halfway vector
        vec3 h = normalize(s + t);
        vec4 specular = pow(max(dot(h,n), 0.0), 4.0) * light.specular;       

        // combined colour
        if(render_texture) {
            // B2 -- MODIFY
            //gl_FragColor = vec4(1.0-(0.5 * ambient + 
            //                     0.5 * diffuse + 
            //                     0.01 * specular + 
            //                     0.1 * reflection_colour).rgb, 1.0);
            //gl_FragColor = vec4((0.5 * ambient + 
            //                     0.5 * diffuse + 
            //                     0.01 * specular + 
            //                     0.1 * reflection_colour).rgb, floor(0.5 * ambient + 
            //                     0.5 * diffuse + 
            //                     0.01 * specular + 
            //                     0.1 * reflection_colour+0.5));
            //if(!gl_FrontFacing) {
                // fragment faces away from camera
            //    discard;
            //}
            gl_FragColor = vec4((0.5 * ambient +
                               0.5 * diffuse +
                               0.01 * specular +
                               0.1 * reflection_colour).rgb, 1.0);
            }
            else {
            // reflection only 
            gl_FragColor = reflection_colour;
        }

    }
}

