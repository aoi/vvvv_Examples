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
float4x4 tWVP: WORLDVIEWPROJECTION;

float4 color:COLOR <string uiname="Color";>;
float range <string uiname="Range";> = 1.0f;
float height <string uiname="Screen Height";> = 100.0f;
float size <string uiname="Point Size";> = 1.0f;
float rotation <string uiname="Rotation";> = 0.0f;

static float PI = 3.1415f;

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
    float4 Pos  : POSITION;
	float  Size : PSIZE;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float3 TexCd : TEXCOORD0)
{
    //declare output struct
    vs2ps Out;

    //transform position
	float4 pos = PosO;
	pos.xyz = TexCd * range;
    Out.Pos = mul(pos, tWVP);
    
    //transform texturecoordinates
    Out.TexCd = 0.0;
	
	Out.Size = size * tP / Out.Pos.w * height * 0.5;

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
	float r = 2 * PI * rotation;
	float s = sin(r);
	float c = cos(r);
	rotTexCd.x = (texCd.x*c) + (texCd.y*(-s));
	rotTexCd.y = (texCd.x*s) + (texCd.y*c);
	rotTexCd += 0.5f;
    float4 col = tex2D(Samp, rotTexCd);
	col *= color;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TStarShader
{
	pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_2_0 PS();
    	
    	PointSpriteEnable = true;
    	PointScaleEnable = true;
    	FillMode = POINT;
    	
        AlphaBlendEnable = false;
        AlphaTestEnable = true;
        AlphaFunc = Greater;
        AlphaRef = 245;
 
        ZEnable = true;
        ZWriteEnable = true;
 
        CullMode = None;
    }
    pass P1
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_2_0 PS();
    	
    	PointSpriteEnable = true;
    	PointScaleEnable = true;
    	FillMode = POINT;
    	
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
 
        AlphaTestEnable = true;
        AlphaFunc = LessEqual;
        AlphaRef = 245;
 
        ZEnable = true;
        ZWriteEnable = false;
    	
    	Lighting = false;
    }
}