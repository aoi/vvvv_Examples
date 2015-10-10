//@author: aoi
//@help: this is a very basic template. use it to start writing your own effects. if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects
//@tags:
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;

float time <string uiname="Time";> = 0.0f;
float4 color:COLOR <string uiname="Color";>;
float range <string uiname="Range";> = 1.0f;
float height <string uiname="Screen Height";> = 100.0f;
float size <string uiname="Point Size";> = 1.0f;
float speed <string uiname="Speed";> = 2.0f;
float rotation <string uiname="Rotation";> = 0.0f;
float alphaRef <string uiname="Alpha Ref";> = 245.0f;
static float sizeMax <string uiname="Max Point Size"; float uimax=256.0f;> = 256.0f;

static float sizeA = 1.0f;
static float sizeB = 1.0f;
static float sizeC = 1.0f;
static float PI2 = 3.1415f*2;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos   : POSITION;
	float  Size  : PSIZE;
    float2 TexCd : TEXCOORD0;
	float4 Rnd   : COLOR;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float3 TexCd : TEXCOORD0,
	float  RndO  : TEXCOORD1,
	float  Life  : TEXCOORD2,
	float  Start : TEXCOORD3)
{
    //declare output struct
    vs2ps Out;
	float t = time - Start;
	t = fmod(t, Life);
	float maxHeight = 10.0f;
	
    //transform position
	float4 dir = 1.0f;
	dir.y = speed * RndO * t;
	
	float curRange = range * dir.y * cos(PI2 * RndO* (dir.y-Start));
	float rotSpeed = Start - t * 0.5f;
	dir.x = curRange * cos(PI2 * rotSpeed);
	dir.z = curRange * sin(PI2 * rotSpeed);
	
	float4 pos = PosO;
	pos = dir * t;
    pos = mul(pos, tWVP);
    Out.Pos = pos;
	
    //transform texturecoordinates
    Out.TexCd = 0.0;
	
	// calc size
	float d = sqrt(pos.x*pos.x + pos.y*pos.y + pos.z*pos.z);
	Out.Size =  t * height * size * sqrt(1/(sizeA + sizeB*d + sizeC*d*d));
	Out.Rnd = RndO;
	Out.Rnd.a = max(0, (Life-t)/Life);
	
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
	float2 texCd = In.TexCd;
	float2 rotTexCd = texCd;
	texCd -= 0.5f;
	float r = PI2 * rotation * (In.Rnd.x - 0.5f);
	float s = sin(r);
	float c = cos(r);
	rotTexCd.x = (texCd.x*c) + (texCd.y*(-s));
	rotTexCd.y = (texCd.x*s) + (texCd.y*c);
	rotTexCd += 0.5f;
    float4 col = tex2D(Samp, rotTexCd);
	col *= color;
	col.a *= In.Rnd.a;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSmokeShader
{
	pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_2_0 PS();
    	
    	PointSize_Max = sizeMax;
    	PointSpriteEnable = true;
    	PointScaleEnable = true;
    	FillMode = POINT;
    	
        AlphaBlendEnable = false;
        AlphaTestEnable = true;
        AlphaFunc = Greater;
        AlphaRef = alphaRef;
 
        ZEnable = true;
        ZWriteEnable = true;
 
        CullMode = NONE;
    }
    pass P1
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_2_0 PS();
    	
    	PointSize_Max = sizeMax;
    	PointSpriteEnable = true;
    	PointScaleEnable = true;
    	FillMode = POINT;
    	
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
 
        AlphaTestEnable = true;
        AlphaFunc = LessEqual;
        AlphaRef = alphaRef;
 
        ZEnable = true;
        ZWriteEnable = false;
    	
    	Lighting = false;
    }
}