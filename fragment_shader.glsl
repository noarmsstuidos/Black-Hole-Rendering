const float StepSize = 0.1;

const float Absorption = 0.5;

const float G = 1.0;
const float c = 10.0;

const vec3 bhPos = vec3( 0.0 );
const float bhMass = 2.0;
const float bhRS = sqrt( 2.0 * G * bhMass / ( c * c ) );

const float accretionDiskSize = 15.0;

mat2 rot2D( float angle )
{
    float c = cos( angle );
    float s = sin( angle );
    
    return mat2( -c, s, s, c );
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

float rand( float seed ) {
    return fract( sin( seed * 12.9898 ) * 43758.5453123 );
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
    float fVal = hash3( i + vec3( 1.0, 0.0, 1.0 ) );
    float g = hash3( i + vec3( 0.0, 1.0, 1.0 ) );
    float h = hash3( i + vec3( 1.0, 1.0, 1.0 ) );
    
    return mix( mix( mix( a, b, u.x ), mix( c, d, u.x ), u.y ),
               mix( mix( e, fVal, u.x ), mix( g, h, u.x ), u.y ), u.z );
}

float mapGas( vec3 p )
{
    vec3 q = p;
    q.xy *= rot2D( 0.2 );
    
    float sphere = sdDiskWithHole( q, bhRS * 3.0 + accretionDiskSize / 2.0 + bhMass * 2.0, accretionDiskSize, 1.0 );
    
    return sphere;
}

float mapBH( vec3 p )
{
    float bh = sdSphere( p, bhRS );
    
    return bh;
}

vec3 curve( vec3 rd, vec3 p )
{
    vec3 pos = p - bhPos;
    float distToBH = length( pos );
    
    vec3 newDir = normalize(
        rd - ( pos * StepSize / pow( distToBH, 3.0 ) * bhMass )
    );
    
    return newDir;
}

vec3 rayTrace( vec2 uv )
{
    vec3 col = vec3( 0.0 );
    
    vec3 ro = vec3( 0.0, 0.0, -60.0 );
    vec3 rd = normalize( vec3( uv, 5.0 ) );
    
    ro.yz *= rot2D( 0.3 );
    rd.yz *= rot2D( 0.3 );
    
    vec3 p = ro;
    
    float d;
    
    float density = 0.0;
    
    float illumination = 0.0;
    
    for( int i = 0; i < int( length( ro ) * 2.0 / StepSize ); i ++ )
    {
        p += rd * StepSize;
        
        d = mapGas( p );
        
        if( d < 0.0 )
        {
            col = vec3( 1.0, 0.3, 0.0 );
            
            vec3 q = p;
            q.xz *= rot2D( iTime );
            
            vec3 lightDir = normalize( -q );
            
            illumination += sqrt( 0.006 / pow( length( q / ( accretionDiskSize ) * 3.0 ), 2.0 ) * 10.0 );
            
            q = p;
            q.xz *= rot2D( iTime / 20.0 );
            
            density += noise3D( vec3( length( q ) ) + q / 5.0 ) * StepSize * Absorption;
        }
        
        d = mapBH( p );
        
        if( d < 0.0 )
        {
            col = vec3( 0.0 );
            
            break;
        }
        
        rd = curve( rd, p );
    }
    
    col += density;
    
    col *= illumination * 3.0 * StepSize;
    
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
        col = vec3( 0.02 );
    }
    
    fragColor = vec4( col, 1.0 );
}
