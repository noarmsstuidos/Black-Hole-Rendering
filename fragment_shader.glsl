const float StepSize = 0.5;

const float screenCurvature = 50.0;

const float G = 1.0;
const float c = 10.0;

const vec3 S = vec3( -400.0, -100.0, -50.0 );

const vec3 bhPos = vec3( 0.0 );
const float bhMass = 5.0;
const float bhRS = sqrt( 2.0 * G * bhMass / ( c * c ) );

const float bhSpin = 0.8;

const float spinStrength = -100.0;

mat2 rot2D( float angle )
{
    float c = cos( angle );
    float s = sin( angle );
    
    return mat2( -c, s, s, c );
}

float hash3( vec3 p ) {
    p = fract( p * 0.1031 );
    p += dot( p, p.zyx + 31.32 );
    return fract( ( p.x + p.y ) * p.z );
}

float noise3D( vec3 x ) {
    vec3 i = floor( x );
    vec3 f = fract( x );
    
    vec3 u = f * f * f * ( f * ( f * 6.0 - 15.0 ) + 10.0 );
    
    float a = hash3( i + vec3( 0.0, 0.0, 0.0 ) );
    float b = hash3( i + vec3( 1.0, 0.0, 0.0 ) );
    float c = hash3( i + vec3( 0.0, 1.0, 0.0 ) );
    float d = hash3( i + vec3( 1.0, 1.0, 0.0 ) );
    float e = hash3( i + vec3( 0.0, 0.0, 1.0 ) );
    float f_val = hash3( i + vec3( 1.0, 0.0, 1.0 ) );
    float g = hash3( i + vec3( 0.0, 1.0, 1.0 ) );
    float h = hash3( i + vec3( 1.0, 1.0, 1.0 ) );
    
    return mix( mix( mix( a, b, u.x ), mix( c, d, u.x ), u.y ),
               mix( mix( e, f_val, u.x ), mix( g, h, u.x ), u.y ), u.z );
}

float sdDiskWithHole( vec3 p, float r, float t, float h )
{
    float d = length( p.xz ) - r;
   
    float ringDist = abs( d ) - t * 0.5;
   
    vec2 w = vec2( ringDist, abs( p.y ) - h * 0.5 );
   
    return min( max( w.x, w.y ), 0.0 ) + length( max( w, 0.0 ) );
}

float sdSphere( vec3 p, float r )
{
    return length( p ) - r;
}

vec4 map( vec3 p )
{
    vec3 q1 = p;
    q1.xz *= rot2D(iTime * 0.05 * bhSpin);
    
    float noise = noise3D( q1 );
    
    float disk = sdDiskWithHole( q1, 150.0, 100.0, ( noise + 1.0 ) * 5.0 );
    
    return vec4( disk, vec3( 0.2, 0.1, 0.7 ) );
}

vec4 mapSun( vec3 p )
{
    vec3 q1 = p;
    q1 -= vec3( S );
    
    float sun = sdSphere( q1, 200.0 );
    
    return vec4( sun, vec3( 0.8, 0.8, 1.0 ) );
}

vec4 mapBH( vec3 p )
{
    float bh = sdSphere( p, bhRS );
    
    return vec4( bh, vec3( 0.0 ) );
}

vec3 curve( vec3 dir, vec3 p )
{
    vec3 pos = p - bhPos;
    float r = length(pos);
    
    vec3 grav = -pos * (StepSize * bhMass / pow(r, 3.0));
    
    vec3 spinAxis = vec3(0.0, 1.0, 0.0);
    
    vec3 frameDrag = bhSpin * spinStrength * cross(spinAxis, dir) / pow(r, 3.0);
    
    vec3 newDir = normalize(dir + grav + frameDrag);

    return newDir;
}


vec3 rayTrace( vec2 uv )
{
    vec2 m = ( iMouse.xy * 2.0 - iResolution.xy ) / iResolution.y * sqrt( 2.0 ) * 2.0;
    
    vec3 col = vec3( 1.0 );
    
    vec3 ro = vec3( 0.0, 0.0, -150.0 );
    vec3 rd = normalize( vec3( uv, 1.0 ) );
    
    ro.yz *= rot2D( m.y );
    rd.yz *= rot2D( m.y );
    
    ro.xz *= rot2D( m.x );
    rd.xz *= rot2D( m.x );
    
    vec3 p = ro;
    
    vec4 d;
    
    float illumination = 0.0;
    
    int collisionAmt = 0;
    
    for( int i = 0; i < 1500; i ++ )
    {
        p += rd * StepSize;
        
        d = map( p );
        
        if( d.x < 0.0 )
        {
            if( collisionAmt < 1 )
            {
                col *= d.yzw;
                
                rd = normalize( S - p );
                
                collisionAmt ++;
                
                p += rd * 2.0;
            } else {
                break;
            }
        }
        
        d = mapSun( p );
        
        if( d.x < 0.0 )
        {
            col *= d.yzw;
            
            illumination += 1.0;
            
            break;
        }
        
        d = mapBH( p );
        
        if( d.x < 0.0 )
        {
            col = d.yzw;
            
            break;
        }
        
        rd = curve( rd, p );
    }
    
    col *= illumination;
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = ( fragCoord * 2.0 - iResolution.xy ) / iResolution.y;
    
    vec3 col;
    
    if( abs( uv.x ) < 1.2 && abs( uv.y ) < 0.9 )
    {
        col = rayTrace( uv );
    } else {
        col = vec3( 0.1 );
    }
        
    fragColor = vec4(col,1.0);
}

