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

// Random float [-1.0, 1.0]
float rand11(vec2 st){
    return rand(st) * 2.0 - 1.0;
}

// Uniform Random Vec3 [0.0, 1.0] 
vec3 rand3(vec2 st){
    return vec3(
        rand(st),
        rand(st + vec2(42.1, 78.2)), 
        rand(st + vec2(12.5, 69.1))
    );
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

// 4D Gaussian
vec4 randGaussian4(vec4 mean, vec4 stdDev, vec2 st) {
    vec2 g1 = randGaussian2(0.0, 1.0, st);
    vec2 g2 = randGaussian2(0.0, 1.0, st + vec2(100.0, 100.0));
    
    return mean + vec4(g1, g2) * stdDev;
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

// Random Point on Sphere Surface
vec3 randOnSphere(vec2 st) {
    float u = rand(st);
    float v = rand(st + vec2(31.4, 15.9));
    
    float theta = 2.0 * PI * u;
    float z = 2.0 * v - 1.0;
    float r = sqrt(max(0.0, 1.0 - z * z));

    return vec3(r * cos(theta), r * sin(theta), z);
}

// Random Point inside Sphere
vec3 randInSphere(vec2 st) {
    vec3 p = randOnSphere(st);
    float u = rand(st + vec2(92.1, 11.2));
    float r = pow(u, 1.0/3.0); // Cube root for volume uniformity
    return p * r;
}

// Random Point inside a 2D Disk
vec2 randInDisk(float radius, vec2 st) {
    float u = rand(st);
    float v = rand(st + vec2(11.1, 44.4));
    
    float r = radius * sqrt(u); // Sqrt for area uniformity
    float theta = 2.0 * PI * v;
    
    return vec2(r * cos(theta), r * sin(theta));
}
