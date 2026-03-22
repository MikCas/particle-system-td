const float PI = 3.14159265359;

// "Gold Noise" Hash
float hash12(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Uniform Random Float [0.0, 1.0]
float rand(vec2 st) {
    return hash12(st);
}

// Gaussian Distribution (1D) using Box-Muller (Pair)
vec2 randGaussian2(float mean, float stdDev, vec2 st) {
    float u1 = max(1e-6, rand(st)); // Safety: Prevent log(0)
    float u2 = rand(st + vec2(13.5, 96.2)); 
    
    // Box-Muller Transform
    float mag = sqrt(-2.0 * log(u1));
    float z0 = mag * cos(2.0 * PI * u2);
    float z1 = mag * sin(2.0 * PI * u2);
    
    return vec2(mean) + vec2(z0, z1) * stdDev;
}

// 1D Gaussian Wrapper
float randGaussian(float mean, float stdDev, vec2 st) {
    return randGaussian2(mean, stdDev, st).x;
}

// 3D Gaussian
vec3 randGaussian3(vec3 mean, vec3 stdDev, vec2 st) {
    vec2 g1 = randGaussian2(0.0, 1.0, st);
    vec2 g2 = randGaussian2(0.0, 1.0, st + vec2(100.0, 100.0));
    
    vec3 result = vec3(g1, g2.x);
    return mean + result * stdDev;
}

// Power Distribution
// Useful for particle sizes (many small, few large).
// exponent > 1.0 = Biased toward minVal
// exponent < 1.0 = Biased toward maxVal
float randPower(float minVal, float maxVal, float exponent, vec2 st) {
    return minVal + (maxVal - minVal) * pow(rand(st), exponent);
}

// 3D Power Distribution
vec3 randPower3(vec3 minVal, vec3 maxVal, vec3 exponent, vec2 st) {
    return vec3(
        randPower(minVal.x, maxVal.x, exponent.x, st),
        randPower(minVal.y, maxVal.y, exponent.y, st + vec2(100.0, 100.0)),
        randPower(minVal.z, maxVal.z, exponent.z, st + vec2(200.0, 200.0))
    );
}

float TrapezoidEnvelope(float t, float attack, float decay) {
    float fadeIn = smoothstep(0.0, attack, t);
    float fadeOut = 1.0 - smoothstep(1.0 - decay, 1.0, t);
    return fadeIn * fadeOut;
}

// Output mask between [0.0, 1.0] based on end-of-life duration
// duration: Length of the decay window (0 to 1)
// float decay [0, 1]: Decay duration
float GetDecayMask(float t, float duration) {
    float start = 1.0 - max(0.001, duration); // Ensure mask doesn't break at 0 decay
    return smoothstep(start, 1.0, t); 
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

// Safe normalization to prevent NaNs
vec3 safe_normalize(vec3 v, vec3 fallback) {
    float len = length(v);
    return (len > 1e-6) ? v / len : fallback;
}