//!HOOK MAIN
//!BIND HOOKED

vec4 hook()
{
    vec4 color = HOOKED_texOff(0);
    color.a = 0.0;
    return color;
}
