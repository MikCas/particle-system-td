const float MIN_LIFE = 0.01;
const float MIN_MASS = 0.1;
const float SPEED_THRESHOLD = 0.001;
const vec3  DEFAULT_UP = vec3(0.0, 1.0, 0.0);

// Calculate the forces acting upon a particle
vec3 CalculateForces(in Particle p){
    vec3 noiseForce = TDIn_NoiseCurl(0, p.id);
    return noiseForce;
}

// Update particle direction if particle is moving too fast, to stabilise movement
// vec3 vel: Velocity value to compare 
// vec3 defaultDir: Default direction to use if check fails 
void CheckVelocity(inout Particle p, in vec3 vel, in vec3 defaultDir){
    float speed = length(vel);
    vec3 vDir = safe_normalize(vel, defaultDir);                    // Determine the direction from the velocity, or use fallback
    p.dir = mix(defaultDir, vDir, step(SPEED_THRESHOLD, speed));    // Update direction only if speed threshold is met
}

// Bound particle position to uniform cube 
// float size [0, inf]: Cube size 
// restitution []     : Energy loss from impact, [0, 1]
void CheckBounds(inout Particle p, float size, float restitution) {
    
    // --- COLLISION DETECTION ---
    vec3 s = sign(p.pos);
    vec3 isOutside = step(vec3(size), abs(p.pos));

    // Only bounce if particle is moving towards the boundary (outward)
    vec3 isMovingOut = step(0.0, p.vel * s);
    vec3 doBounce = isOutside * isMovingOut;

    // --- BOUNCE ---
    p.vel *= 1.0 - (doBounce * (1.0 + restitution)); // invert velocity and apply restitution
    p.pos = clamp(p.pos, -size, size);                             
}

// Update the new position of a particle at the current timestep
// vec3 F: Total force acting upon a particle 
// float massInfluence [0, 1]     : 
// float velDamp []               : 
void UpdatePosition(inout Particle p, float dt, vec3 F, float massInfluence, float velDamp){

    // --- CALCULATE ACCELERATION (a = F/m) ---
    float mass = mix(1.0, p.mass, massInfluence);
    vec3 acc = F / mass;                          

    // --- UPDATE VELOCITY (v = v + a) ---
    p.vel *= exp(-velDamp * dt);
    p.vel += acc * dt; 
    
    // Safety check: Don't normalize near-zero vectors to avoid NaNs
    CheckVelocity(p, p.vel, p.dir);

    // --- UPDATE POSITION (p = p + v) ---
	p.pos += p.vel * dt;
}

// Reset particle attributes 
void onDeath(inout Particle p) {

    // --- SEED ---
    p.seed = rand(vec2(float(p.id) * 0.1234, fract(uTime)));

    // --- AGE  ---
    p.age = max(MIN_LIFE, randGaussian(uLife.x, uLife.y, vec2(p.seed, 1.0)));
    p.life = p.age;

    // --- POS  ---
    p.pos = randGaussian3(TDIn_PosMean(0, p.id), uPosSpread, vec2(p.seed, 2.0));

    // --- VELOCITY ---
    vec3 randomDir = randGaussian3(uDirection, uDirSpread, vec2(p.seed, 3.0)); // Random non-normalised direction vector
    float speed = max(0.0, randGaussian(uSpeed.x, uSpeed.y, vec2(p.seed, 4.0)));
    CheckVelocity(p, randomDir, DEFAULT_UP);
    p.vel = normalize(p.dir) * speed;

    // --- SIZE  ---
    p.baseSize = randPower3(uSizeMin, uSizeMax, uSizeBias, vec2(p.seed, 5.0));

    // --- MASS  ---
    // density = mass * volume
    float volume = p.baseSize.x * p.baseSize.y * p.baseSize.z;
    p.mass = max(MIN_MASS, volume * uDensity);

    // --- COLOR ---
    float h = fract(uHue.x + rand(vec2(p.seed, 6.0)) * uHue.y); 
    float s = uSaturation.x + rand(vec2(p.seed, 7.0)) * uSaturation.y; 
    float v = uBrightness.x + rand(vec2(p.seed, 8.0)) * uBrightness.y; 

    // Make the End Color a shifted version of the start (e.g., +0.1 hue shift)
    p.startColor = vec4(hsv2rgb(vec3(h, s, v)), 1.0);
    float hEnd = fract(h + uHueShift); 
    p.endColor = vec4(hsv2rgb(vec3(hEnd, s, v)), 1.0); 
}

// Update physical attributes
void onLife(inout Particle p, float dt) {
    vec3 F = CalculateForces(p);
    UpdatePosition(p, dt, F, uMassInfluence, uDamping);
    CheckBounds(p, uBoundsSize, uRestitution);
}

// Derive per-particle size from seed + uniforms
vec3 DeriveBaseSize(float seed) {
    return randPower3(uSizeMin, uSizeMax, uSizeBias, vec2(seed, 5.0));
}

// Derive per-particle mass from seed + uniforms
float DeriveMass(float seed) {
    vec3 s = DeriveBaseSize(seed);
    float volume = s.x * s.y * s.z;
    return max(MIN_MASS, volume * uDensity);
}

// Derive per-particle hue from seed
float DeriveHue(float seed) {
    return fract(uHue.x + rand(vec2(seed, 6.0)) * uHue.y);
}

// Output mask between [0.0, 1.0] based on end-of-life duration
// duration: Length of the decay window (0 to 1)
// float decay [0, 1]: Decay duration
float GetDecayMask(float t, float duration) {
    float start = 1.0 - max(0.001, duration); // Ensure mask doesn't break at 0 decay
    return smoothstep(start, 1.0, t); 
}

void UpdateColor(inout Particle p, float t) {
    // --- SETUP MASKS ---
    float decayMask = GetDecayMask(t, uColorEnvelope.y);
    float envelope  = TrapezoidEnvelope(t, uColorEnvelope.x, uColorEnvelope.y);

    // --- COLOR MIXING ---
    vec3 baseColor = mix(p.startColor.rgb, p.endColor.rgb, t);  // Interpolate base gradient
    p.color.rgb = mix(baseColor, uFlashColor, decayMask); // Mix to Flash Color based on decayMask

    // --- ALPHA MIXING ---
    // If decayMask is 1.0 (Flash), we want Alpha to be 1.0.
    // If decayMask is 0.0, we want to use the standard envelope (fade out).
    p.color.a = mix(envelope, 1.0, decayMask);
}

void UpdateSize(inout Particle p, float t) {

    // --- SETUP MASKS ---
    float decayMask = GetDecayMask(t, uSizeEnvelope.y);
    float envelope  = TrapezoidEnvelope(t, uSizeEnvelope.x, uSizeEnvelope.y);
    
    // --- IMPLOSION LOGIC ---
    float implosion = 1.0 - decayMask; // Calculate how much to shrink during the flash (decay)
    float flashScale = max(0.3, implosion); // Clamp so it never shrinks below 30% (0.3) during the flash

    p.size = p.baseSize * envelope * flashScale;
}

// Update visual attributes
void RenderParticle(inout Particle p){
    // Invert normalised age (0.0 -> 1.0)
    // Clamp prevents artifacts for less than 0, Max prevents division by 0
    float lifeProgress = 1.0 - clamp(p.age / p.life, 0.0, 1.0);

    UpdateSize(p, lifeProgress);
    UpdateColor(p, lifeProgress);
}