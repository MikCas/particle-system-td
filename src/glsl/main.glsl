#include "glsl_particle"
#include "glsl_utils"
#include "glsl_random"
#include "glsl_behaviour"

void main() {   

    // --- READ PARTICLE ---
    const uint id = TDIndex();
    if (id >= TDNumElements()) return;

    Particle p = ReadParticle(id);

    p.age -= uDelta;    // Decrement age 

    // --- DEATH ---
    if (p.age <= 0.0) {
        float seed = rand(vec2(float(id) * 0.1234, fract(uTime)));
        onDeath(p, seed);
    // --- ALIVE ---
    } else { 
        onLife(p, uDelta);
    }
    
    // --- RENDER ---
    RenderParticle(p);
    
    // --- WRITE PARTICLE ---
    WriteParticle(p);
}