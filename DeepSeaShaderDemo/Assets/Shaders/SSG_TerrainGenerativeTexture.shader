// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SSG_TerrainGenerativeTexture"
{
	Properties
	{
		_AlbedoLight("AlbedoLight", Color) = (0,0,0,0)
		_AlbedoDark("AlbedoDark", Color) = (0.3490566,0.2538846,0.06750622,1)
		_NormalMap1("Normal Map1", 2D) = "bump" {}
		_NormalMap2("Normal Map2", 2D) = "bump" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metalness("Metalness", Range( 0 , 1)) = 0
		_OffsetNormal1Scale("Offset Normal1 Scale", Float) = 0
		_OffsetNormal2Scale("Offset Normal2 Scale", Float) = 0
		_NormalMap1Strength("Normal Map1 Strength", Range( 0 , 2)) = 0
		_NormalMap2Strenth("Normal Map2 Strenth", Range( 0 , 2)) = 0
		_Albedo1Scale("Albedo1 Scale", Float) = 0
		_Albedo2Scale("Albedo2 Scale", Float) = 0
		_PrceduralTextureBlend("Prcedural Texture Blend", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _NormalMap1Strength;
		uniform sampler2D _NormalMap1;
		uniform float _OffsetNormal1Scale;
		uniform float _NormalMap2Strenth;
		uniform sampler2D _NormalMap2;
		uniform float _OffsetNormal2Scale;
		uniform float4 _AlbedoLight;
		uniform float4 _AlbedoDark;
		uniform float _Albedo1Scale;
		uniform float _Albedo2Scale;
		uniform float _PrceduralTextureBlend;
		uniform float _Metalness;
		uniform float _Smoothness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult76 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 uv_TexCoord52 = i.uv_texcoord * float2( 0,0 ) + ( appendResult76 * _OffsetNormal1Scale );
			float2 uv_TexCoord61 = i.uv_texcoord * float2( 0,0 ) + ( appendResult76 * _OffsetNormal2Scale );
			o.Normal = ( UnpackScaleNormal( tex2D( _NormalMap1, uv_TexCoord52 ), _NormalMap1Strength ) + UnpackScaleNormal( tex2D( _NormalMap2, uv_TexCoord61 ), _NormalMap2Strenth ) );
			float2 uv_TexCoord12 = i.uv_texcoord * float2( 1,1 ) + ( _Albedo1Scale * appendResult76 );
			float simplePerlin2D10 = snoise( uv_TexCoord12 );
			float clampResult25 = clamp( ( 1.0 - pow( simplePerlin2D10 , 2.0 ) ) , 0.0 , 1.0 );
			float2 uv_TexCoord34 = i.uv_texcoord * float2( 1,1 ) + ( appendResult76 * _Albedo2Scale );
			float simplePerlin2D35 = snoise( uv_TexCoord34 );
			float clampResult37 = clamp( pow( simplePerlin2D35 , 2.0 ) , 0.0 , 0.1 );
			float lerpResult40 = lerp( clampResult25 , clampResult37 , _PrceduralTextureBlend);
			float4 clampResult24 = clamp( ( _AlbedoDark + lerpResult40 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
			float4 clampResult4 = clamp( ( _AlbedoLight * clampResult24 ) , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
			o.Albedo = clampResult4.rgb;
			o.Metallic = _Metalness;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
1;1;1918;1017;6833.852;522.6244;2.866121;True;False
Node;AmplifyShaderEditor.CommentaryNode;75;-4449.67,1146.37;Float;False;485.7856;203.3354;Drive UVs based on global position;2;76;78;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;78;-4412.488,1197.456;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;69;-4018.997,-432.7546;Float;False;1672.354;418.118;Calculated procedural speckles;8;16;25;28;27;10;12;18;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3934.679,-210.7998;Float;False;Property;_Albedo1Scale;Albedo1 Scale;10;0;Create;True;0;0;False;0;0;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;76;-4143.217,1191.496;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;70;-4018.997,27.19923;Float;False;1670.327;389.7507;Calculated procedural swirls;7;31;37;36;35;34;32;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-3938.823,258.7758;Float;False;Property;_Albedo2Scale;Albedo2 Scale;11;0;Create;True;0;0;False;0;0;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3711.441,-207.0899;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;18;-3711.682,-391.9568;Float;False;Constant;_Tiling1;Tiling 1;4;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-3518.079,-252.3492;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;32;-3712.372,56.64214;Float;False;Constant;_Tiling2;Tiling 2;5;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3712.132,241.509;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-3518.769,196.2497;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;10;-3235.294,-257.8862;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;35;-3235.985,190.7127;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;27;-3029.239,-252.0728;Float;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-2784.192,-250.5979;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;71;-2208.078,-19.22455;Float;False;556.6492;302.7836;Blend Inputs;2;40;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;36;-3029.928,196.5261;Float;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;72;-1647.7,-535.03;Float;False;1293.222;508.989;Color and highlight procedural albedo;6;22;23;21;24;4;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2186.445,182.7427;Float;False;Property;_PrceduralTextureBlend;Prcedural Texture Blend;12;0;Create;True;0;0;False;0;0;0.625;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2250.726,436.9725;Float;False;1244.116;504.8411;Adjust Normal Map 1 - scale and strength;6;48;54;52;50;51;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2255.94,983.6934;Float;False;1149.653;658.4561;Adjust Normal Map 2 - scale and strength;6;59;56;61;62;63;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;25;-2605.276,-249.6555;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;37;-2745.595,194.7601;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;-1833.232,26.81525;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;-1593.036,-473.431;Float;False;Property;_AlbedoDark;AlbedoDark;1;0;Create;True;0;0;False;0;0.3490566,0.2538846,0.06750622,1;0.3568628,0.3568628,0.3568628,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-2223,801.471;Float;False;Property;_OffsetNormal1Scale;Offset Normal1 Scale;6;0;Create;True;0;0;False;0;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2230.755,1371.362;Float;False;Property;_OffsetNormal2Scale;Offset Normal2 Scale;7;0;Create;True;0;0;False;0;0;-0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1269.544,-266.0178;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;50;-1988.283,489.1129;Float;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;62;-1996.038,1059.004;Float;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1995.798,1243.87;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1988.043,673.9794;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;21;-1105.196,-472.8967;Float;False;Property;_AlbedoLight;AlbedoLight;0;0;Create;True;0;0;False;0;0,0,0,0;0.2941177,0.3294118,0.2784314,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1794.681,628.7205;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-1832.505,845.7244;Float;False;Property;_NormalMap1Strength;Normal Map1 Strength;8;0;Create;True;0;0;False;0;0;0.273;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-1802.435,1198.611;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;24;-1093.301,-266.5747;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1816.035,1357.901;Float;False;Property;_NormalMap2Strenth;Normal Map2 Strenth;9;0;Create;True;0;0;False;0;0;1.31;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;68;-4469.898,894.4127;Float;False;485.7856;203.3354;Drive UVs based on global position;2;17;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-776.3713,-290.6261;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;59;-1447.303,1175.226;Float;True;Property;_NormalMap2;Normal Map2;3;0;Create;True;0;0;False;0;None;e16a6a41ac9961d4cb8751e272ea7ddd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-1464.483,578.6591;Float;True;Property;_NormalMap1;Normal Map1;2;0;Create;True;0;0;False;0;None;3e730e772a882e84fa7d891126906f68;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;17;-4413.793,942.7781;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;4;-635.8483,-290.7944;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-935.3127,583.9339;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-651.5498,806.0729;Float;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-651.2092,669.3296;Float;False;Property;_Metalness;Metalness;5;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-4163.446,939.5385;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;SSG_TerrainGenerativeTexture;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;76;0;78;1
WireConnection;76;1;78;3
WireConnection;15;0;16;0
WireConnection;15;1;76;0
WireConnection;12;0;18;0
WireConnection;12;1;15;0
WireConnection;33;0;76;0
WireConnection;33;1;31;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;10;0;12;0
WireConnection;35;0;34;0
WireConnection;27;0;10;0
WireConnection;28;0;27;0
WireConnection;36;0;35;0
WireConnection;25;0;28;0
WireConnection;37;0;36;0
WireConnection;40;0;25;0
WireConnection;40;1;37;0
WireConnection;40;2;41;0
WireConnection;23;0;22;0
WireConnection;23;1;40;0
WireConnection;63;0;76;0
WireConnection;63;1;64;0
WireConnection;51;0;76;0
WireConnection;51;1;49;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;61;0;62;0
WireConnection;61;1;63;0
WireConnection;24;0;23;0
WireConnection;20;0;21;0
WireConnection;20;1;24;0
WireConnection;59;1;61;0
WireConnection;59;5;56;0
WireConnection;48;1;52;0
WireConnection;48;5;54;0
WireConnection;4;0;20;0
WireConnection;60;0;48;0
WireConnection;60;1;59;0
WireConnection;14;0;17;1
WireConnection;14;1;17;3
WireConnection;0;0;4;0
WireConnection;0;1;60;0
WireConnection;0;3;53;0
WireConnection;0;4;6;0
ASEEND*/
//CHKSM=70341828140FBE26F9A67554E590652DC3A69D08