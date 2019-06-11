// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "InClassFishAnimExample"
{
	Properties
	{
		_Amplitude("Amplitude", Float) = 0
		_TimeOffset("Time Offset", Float) = 0
		_Frequency("Frequency", Float) = 0
		_AmplitudeOffset("Amplitude Offset", Float) = 0
		_PositionalOffsetScalar("Positional Offset Scalar", Float) = 0
		_PositoinalAmplitudeScalar("Positoinal Amplitude Scalar", Float) = 0
		_TopColor("Top Color", Color) = (0.3369081,0.4780601,0.6320754,0)
		_BottomColor("Bottom Color", Color) = (0.1886348,0.2247253,0.254717,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_VertexLerpScale("Vertex Lerp Scale", Float) = 0
		_VertexLerpOffset("Vertex Lerp Offset", Range( -1 , 1)) = 0
		_NoiseScale("Noise Scale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform float _Amplitude;
		uniform float _Frequency;
		uniform float _TimeOffset;
		uniform float _PositionalOffsetScalar;
		uniform float _PositoinalAmplitudeScalar;
		uniform float _AmplitudeOffset;
		uniform float4 _TopColor;
		uniform float4 _BottomColor;
		uniform float _VertexLerpScale;
		uniform float _VertexLerpOffset;
		uniform float _NoiseScale;
		uniform float _Smoothness;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult15 = (float4(( ( _Amplitude * sin( ( ( _Frequency * _Time.y ) + _TimeOffset + ( ase_vertex3Pos.z * _PositionalOffsetScalar ) ) ) * ( ase_vertex3Pos.z * _PositoinalAmplitudeScalar ) ) + _AmplitudeOffset ) , 0.0 , 0.0 , 0.0));
			v.vertex.xyz += appendResult15.xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float clampResult32 = clamp( ( (0.0 + (( _VertexLerpScale * ase_vertex3Pos.y ) - 1.0) * (1.0 - 0.0) / (-1.0 - 1.0)) + _VertexLerpOffset ) , 0.0 , 1.0 );
			float4 lerpResult29 = lerp( _TopColor , _BottomColor , clampResult32);
			float simplePerlin3D42 = snoise( ( ase_vertex3Pos * _NoiseScale ) );
			float clampResult47 = clamp( sin( simplePerlin3D42 ) , 0.0 , 1.0 );
			o.Albedo = ( lerpResult29 + (clampResult47*0.2 + 0.1) ).rgb;
			o.Metallic = 0.0;
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
7;1;1906;1011;2118.053;589.3027;1.339095;True;False
Node;AmplifyShaderEditor.CommentaryNode;22;-1836.972,220.222;Float;False;922.8853;762;Adding the scaled and offset time value to the vertex's y position;4;13;5;20;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1786.972,630.2219;Float;False;498;326;Scales Vertex Y Position;3;17;19;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1692.972,270.2219;Float;False;394;324;Scales and Offsets Time Input;4;6;9;8;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1643.087,326.7451;Float;False;Property;_Frequency;Frequency;2;0;Create;True;0;0;False;0;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1758.144,834.1267;Float;False;Property;_PositionalOffsetScalar;Positional Offset Scalar;4;0;Create;True;0;0;False;0;0;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;16;-1696.305,679.5172;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;2;-1645.087,419.7452;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-821.416,-667.5176;Float;False;Property;_NoiseScale;Noise Scale;11;0;Create;True;0;0;False;0;0;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1432.892,-74.89545;Float;False;Property;_VertexLerpScale;Vertex Lerp Scale;9;0;Create;True;0;0;False;0;0;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1483.104,725.0176;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1483.087,498.7452;Float;False;Property;_TimeOffset;Time Offset;1;0;Create;True;0;0;False;0;0;1.885547;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1456.918,1002.752;Float;False;543.639;249.309;Uses distance from origin as scalar multiplier of amplitude;2;27;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-459.7102,-516.8072;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1189.094,-50.78357;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1459.087,396.7452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1204.087,393.7451;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;42;-307.9434,-605.2247;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;24;-884.4871,222.9452;Float;False;553.9999;353;Scaling and offsetting sin ouput;4;3;4;10;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1406.918,1137.061;Float;False;Property;_PositoinalAmplitudeScalar;Positoinal Amplitude Scalar;5;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;30;-1026.132,-31.92963;Float;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1047.102,142.1123;Float;False;Property;_VertexLerpOffset;Vertex Lerp Offset;10;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;46;-5.425537,-370.4026;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1082.279,1052.752;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;5;-1056.087,393.7451;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-824.7366,5.477492;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-834.4871,272.9451;Float;False;Property;_Amplitude;Amplitude;0;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-664.4871,276.9451;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-730.4871,460.9451;Float;False;Property;_AmplitudeOffset;Amplitude Offset;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-156.1363,-249.8341;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-849.0817,-277.2797;Float;False;Property;_BottomColor;Bottom Color;7;0;Create;True;0;0;False;0;0.1886348,0.2247253,0.254717,0;0.2439035,0.2598858,0.2735849,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;33;-849.0814,-481.7542;Float;False;Property;_TopColor;Top Color;6;0;Create;True;0;0;False;0;0.3369081,0.4780601,0.6320754,0;0,0.05380852,0.1037736,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;32;-702.6921,25.33931;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;49;-471.4419,-189.5361;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-300.4957,228.0251;Float;False;217;229;Applying result to x axis;1;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-484.4872,276.9451;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;-515.6681,-28.27365;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-250.4957,278.0251;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-251.4099,85.85018;Float;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-248.7308,168.9022;Float;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;1;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-178.5418,-48.13605;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;InClassFishAnimExample;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;17;0;16;3
WireConnection;17;1;19;0
WireConnection;44;0;16;0
WireConnection;44;1;45;0
WireConnection;37;0;38;0
WireConnection;37;1;16;2
WireConnection;9;0;8;0
WireConnection;9;1;2;0
WireConnection;13;0;9;0
WireConnection;13;1;6;0
WireConnection;13;2;17;0
WireConnection;42;0;44;0
WireConnection;30;0;37;0
WireConnection;46;0;42;0
WireConnection;26;0;16;3
WireConnection;26;1;27;0
WireConnection;5;0;13;0
WireConnection;39;0;30;0
WireConnection;39;1;40;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;26;0
WireConnection;47;0;46;0
WireConnection;32;0;39;0
WireConnection;49;0;47;0
WireConnection;7;0;4;0
WireConnection;7;1;10;0
WireConnection;29;0;33;0
WireConnection;29;1;34;0
WireConnection;29;2;32;0
WireConnection;15;0;7;0
WireConnection;48;0;29;0
WireConnection;48;1;49;0
WireConnection;0;0;48;0
WireConnection;0;3;35;0
WireConnection;0;4;36;0
WireConnection;0;11;15;0
ASEEND*/
//CHKSM=8B307215E658757119C41729DD175A8617AE95BA