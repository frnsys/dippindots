//!HOOK OUTPUT
//!BIND HOOKED

const float OPACITY = 0.6;

vec4 hook() {
    vec4 color = HOOKED_texOff(0);
    color.rgb *= OPACITY;
    color.a   = OPACITY;
    return color;
}
