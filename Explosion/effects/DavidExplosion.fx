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
float gravity <string uiname="Gravity";> = 9.8f;
float time <string uiname="Time";> = 0.0f;

float height <string uiname="Screen Height";> = 100.0f;
float size <string uiname="Point Size";> = 1.0f;

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
	float4 Color : COLOR;
	//float InitV : TEXCOORD1;
	//float Life : TEXCOORD2;
	//float Angle : TEXCOORD3;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 Dir : TEXCOORD0,
	float InitV : TEXCOORD1,
	float Life : TEXCOORD2,
	float Angle : TEXCOORD3)
{
    //declare output struct
    vs2ps Out;

    //transform position
	float t = time / Life;
	
	float4 acc = float4(0.0f, -gravity, 0.0f, 0.0f);
	float4 pos = PosO;
	pos = PosO + InitV * (Dir * t) + (0.5f * acc * t * t);
	
    Out.Pos = mul(pos, tWVP);
    
    //transform texturecoordinates
    Out.TexCd = 0.0;
	
	float4 col = color;
	col.a = 1.0f - t;
	Out.Color = col;
	
	Out.Size = size * tP / Out.Pos.w * height * 0.5;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(Samp, In.TexCd);
    
	//set color
	col *= In.Color;
	
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