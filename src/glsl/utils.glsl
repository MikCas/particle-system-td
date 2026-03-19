float TrapezoidEnvelope(float t, float attack, float decay) {
    float fadeIn = smoothstep(0.0, attack, t);
    float fadeOut = 1.0 - smoothstep(1.0 - decay, 1.0, t);
    return fadeIn * fadeOut;
}

// Converts HSV (Hue, Saturation, Value) to RGB
// hsv.x = Hue (0.0 - 1.0)
// hsv.y = Saturation (0.0 - 1.0)
// hsv.z = Value (Brightness) (0.0 - 1.0)
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}