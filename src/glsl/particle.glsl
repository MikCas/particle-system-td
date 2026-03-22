// Particle data structure and I/O

struct Particle{	
	uint id;
	vec3 pos, vel;
	float age, life;
    float seed;

    vec3 dir;
	vec3 size;
	vec4 color;
	float mass;
	vec3 baseSize;
	vec4 startColor;
	vec4 endColor;
};

// Read particle data from glsl pop
Particle ReadParticle(in uint id) {
    Particle p;
    p.id = id;
    p.pos = TDIn_P(0, id);
    p.vel = TDIn_Vel(0, id);
    p.age = TDIn_Age(0, id);
    p.life = TDIn_Life(0, id);
    p.seed = TDIn_Seed(0, id);

    p.dir = TDIn_Dir(0, id);
    p.mass = TDIn_Mass(0, id);
    p.baseSize = TDIn_BaseSize(0, id);  
    p.startColor = TDIn_StartColor(0, id);
    p.endColor = TDIn_EndColor(0, id);
    
    return p;
}

// Write particle data to glsl pop
void WriteParticle(in Particle p) {
    
    P[p.id] = p.pos;
    Vel[p.id] = p.vel;
    Age[p.id] = p.age;
    Life[p.id] = p.life;
    Seed[p.id] = p.seed;
    Size[p.id] = p.size;
    Color[p.id] = p.color;

    Dir[p.id] = p.dir;
    Mass[p.id] = p.mass;
    BaseSize[p.id] = p.baseSize;
    StartColor[p.id] = p.startColor;
    EndColor[p.id] = p.endColor;
}

