// === CONSTANTS ===
const float MIN_LIFE = 0.001;
const float MIN_MASS = 0.01;
const float SPEED_THRESHOLD = 0.001;
const vec3  UP = vec3(0.0, 1.0, 0.0);

// === PHYSICS ===
// Calculate the forces acting upon a particle
vec3 CalculateForces(in Particle p){
    vec3 noiseForce = TDIn_NoiseCurl(0, p.id);
    return noiseForce;
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

// === LIFECYCLE ===
void Reset(inout Particle p) {

    p.seed = rand(vec2(float(p.id) * 0.1234, fract(uTime)));

    p.age = max(MIN_LIFE, randGaussian(uLife.x, uLife.y, vec2(p.seed, 1.0)));
    p.life = p.age;

    p.pos = randGaussian3(TDIn_PosMean(0, p.id), uPosSpread, vec2(p.seed, 2.0));

    vec3 dir  = SafeNormalize(randGaussian3(uDirection, uDirSpread, vec2(p.seed, 3.0)), SPEED_THRESHOLD, UP);
    float speed = max(0.0, randGaussian(uSpeed.x, uSpeed.y, vec2(p.seed, 4.0)));
    p.vel = dir * speed;
}

void Update(inout Particle p, float dt) {

    vec3 baseSize = randPower3(uSizeMin, uSizeMax, uSizeBias, vec2(p.seed, 5.0));
    float volume = baseSize.x * baseSize.y * baseSize.z;
    float mass = max(MIN_MASS, volume * uDensity);
    
    vec3 F = CalculateForces(p);

    float effectiveMass = mix(1.0, mass, uMassInfluence);   // Calculate Acceleration (a = F/m)
    vec3 acc = F / effectiveMass;                          

    p.vel *= exp(-uDamping * dt);                           // Update Velocity (v = v + a)
    p.vel += acc * dt; 

	p.pos += p.vel * dt;                                    // Update Position (p = p + v)
    CheckBounds(p, uBoundsSize, uRestitution);
}

// === RENDER ===
vec4 RenderColor(float seed, float t) {
    // --- SETUP MASKS ---
    float decayMask = GetDecayMask(t, uColorEnvelope.y);
    float envelope  = TrapezoidEnvelope(t, uColorEnvelope.x, uColorEnvelope.y);

    // --- COLOR ---
    float h = fract(uHue.x + rand(vec2(seed, 6.0)) * uHue.y);
    float s = uSaturation.x + rand(vec2(seed, 7.0)) * uSaturation.y; 
    float v = uBrightness.x + rand(vec2(seed, 8.0)) * uBrightness.y; 

    vec3 startColor = hsv2rgb(vec3(h, s, v));
    vec3 endColor   = hsv2rgb(vec3(fract(h + uHueShift), s, v));

    vec3 rgb = mix(mix(startColor, endColor, t), uFlashColor.rgb, decayMask);
    float a  = mix(envelope, 1.0, decayMask);

    // --- ALPHA MIXING ---
    // If decayMask is 1.0 (Flash), we want Alpha to be 1.0.
    // If decayMask is 0.0, we want to use the standard envelope (fade out).
    return vec4(rgb, a);
}

vec3 RenderSize(float seed, float t) {

    // --- SETUP MASKS ---
    float decayMask = GetDecayMask(t, uSizeEnvelope.y);
    float envelope  = TrapezoidEnvelope(t, uSizeEnvelope.x, uSizeEnvelope.y);
    
    // --- IMPLOSION LOGIC ---
    float implosion = 1.0 - decayMask; // Calculate how much to shrink during the flash (decay)
    float flashScale = max(0.3, implosion); // Clamp so it never shrinks below 30% (0.3) during the flash

    vec3 baseSize = randPower3(uSizeMin, uSizeMax, uSizeBias, vec2(seed, 5.0));
    return baseSize * envelope * flashScale;
}

// Update visual attributes
void RenderParticle(inout Particle p){
    // Invert normalised age (0.0 -> 1.0)
    // Clamp prevents artifacts for less than 0, Max prevents division by 0
    float t = 1.0 - clamp(p.age / p.life, 0.0, 1.0);
    p.color = RenderColor(p.seed, t);
    p.size = RenderSize(p.seed, t);
}