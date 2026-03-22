#include "glsl_particle"
#include "glsl_utils"
#include "glsl_random"
#include "glsl_behaviour"

void main() {   

    const uint id = TDIndex();
    if (id >= TDNumElements()) return;
    Particle p = ReadParticle(id);

    p.age -= uDelta;       // Decrement age 
    if (p.age <= 0.0) {    // Death
        Reset(p);
    } else { 
        Update(p, uDelta); // Alive
    }
    
    RenderParticle(p);
    WriteParticle(p);
}