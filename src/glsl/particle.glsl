struct Particle{	
	// --- IDENTITY ---
	uint id;

	// --- DYNAMIC ---
	// Attributes which are updated during life
	vec3 pos;
	vec3 vel;
	vec3 dir;
	float age;
	vec3 size;
	vec4 color;

	// --- STATIC ---
	// Attrbiutes which are constant during life
	float life;
	float mass;
	vec3 baseSize;
	vec4 startColor;
	vec4 endColor;
};

// Read particle data from glsl pop
Particle ReadParticle(in uint id) {
    Particle p;
    p.id = id;
    
	// --- DYNAMIC ---
    p.pos = TDIn_P(0, id);
    p.vel = TDIn_Vel(0, id);
    p.dir = TDIn_Dir(0, id);
    p.age = TDIn_Age(0, id);

	// --- STATIC ---
    p.life = TDIn_Life(0, id);
    p.mass = TDIn_Mass(0, id);
    p.baseSize = TDIn_BaseSize(0, id);  
    p.startColor = TDIn_StartColor(0, id);
    p.endColor = TDIn_EndColor(0, id);
    
    return p;
}

// Write particle data to glsl pop
void WriteParticle(in Particle p) {
    
    // --- DYNAMIC ---
    P[p.id] = p.pos;
    Vel[p.id] = p.vel;
    Dir[p.id] = p.dir;
    Age[p.id] = p.age;
    Size[p.id] = p.size;
    Color[p.id] = p.color;

    // --- STATIC ---
    Life[p.id] = p.life;
    Mass[p.id] = p.mass;
    BaseSize[p.id] = p.baseSize;
    StartColor[p.id] = p.startColor;
    EndColor[p.id] = p.endColor;
}

