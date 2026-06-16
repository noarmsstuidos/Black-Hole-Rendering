// Shadertoy Fragment Shader - Black Hole Rendering
// Easy Shadertoy Integration
// Copy and paste directly into Shadertoy - Image tab

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalize coordinates to 0.0 - 1.0
    vec2 uv = fragCoord / iResolution.xy;
    
    // Center coordinates around origin
    vec2 pos = uv - 0.5;
    pos.x *= iResolution.x / iResolution.y;
    
    // Black hole effect - ray marching simulation
    vec3 col = vec3(0.0);
    
    // Calculate distance from center
    float dist = length(pos);
    
    // Event horizon radius
    float horizon = 0.1;
    
    // Accretion disk effect
    float disk = 1.0 / (1.0 + dist * dist * 5.0);
    disk *= sin(atan(pos.y, pos.x) * 8.0 + iTime * 2.0) * 0.5 + 0.5;
    
    // Gravitational lensing effect
    float bend = sin(dist * 20.0 - iTime * 3.0) * 0.1;
    float lensed = sin((atan(pos.y, pos.x) + bend) * 6.0 + iTime * 1.5);
    
    // Color based on distance and time
    col.r = disk * (sin(iTime * 0.5 + dist * 5.0) * 0.5 + 0.5);
    col.g = disk * (sin(iTime * 0.3 + dist * 7.0 + 2.0) * 0.5 + 0.5);
    col.b = lensed * 0.3 + 0.2;
    
    // Black center (event horizon)
    if (dist < horizon) {
        col = vec3(0.0);
    }
    
    // Fade to black at edges
    col *= 1.0 - smoothstep(0.3, 0.8, dist);
    
    // Add some radiation glow
    col += vec3(1.0, 0.4, 0.1) * exp(-dist * 3.0) * 0.5;
    
    // Output
    fragColor = vec4(col, 1.0);
}
