// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SSG_FishVertexDeformation"
{
	Properties
	{
		_DiffuseTop("Diffuse Top", Color) = (0,0,0,0)
		_DiffuseBottom("Diffuse Bottom", Color) = (0,0,0,0)
		_GeometricPeriod("Geometric Period", Float) = 5
		_TimeScale("TimeScale", Float) = 5
		_WaveMagnitude("Wave Magnitude", Float) = 0.5
		_SmoothnessCap("Smoothness Cap", Range( 0 , 1)) = 0
		_Metalness("Metalness", Range( 0 , 1)) = 0
		_GradientScale("Gradient Scale", Float) = 0
		_GradientOffset("Gradient Offset", Float) = 0
		_Albedo2Scale("Albedo2 Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _GeometricPeriod;
		uniform float _TimeScale;
		uniform float _WaveMagnitude;
		uniform float4 _DiffuseBottom;
		uniform float _Albedo2Scale;
		uniform float4 _DiffuseTop;
		uniform float _GradientOffset;
		uniform float _GradientScale;
		uniform float _Metalness;
		uniform float _SmoothnessCap;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 objToWorld32 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 appendResult14 = (float4(0.0 , 0.0 , ( sin( ( ( ase_vertex3Pos.x * _GeometricPeriod ) + ( _Time.y * _TimeScale ) + ( objToWorld32.y * 6.0 ) ) ) * _WaveMagnitude * ase_vertex3Pos.x ) , 0.0));
			v.vertex.xyz += appendResult14.xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 appendResult67 = (float4(ase_vertex3Pos.x , ase_vertex3Pos.y , 0.0 , 0.0));
			float2 uv_TexCoord52 = i.uv_texcoord * float2( 1,1 ) + ( appendResult67 * _Albedo2Scale ).xy;
			float simplePerlin2D53 = snoise( uv_TexCoord52 );
			float temp_output_54_0 = pow( simplePerlin2D53 , 1.5 );
			float clampResult55 = clamp( temp_output_54_0 , 0.0 , 0.3 );
			float clampResult39 = clamp( ( _GradientOffset + ( _GradientScale * ase_vertex3Pos.y ) ) , 0.0 , 1.0 );
			float4 lerpResult33 = lerp( ( _DiffuseBottom * clampResult55 ) , ( clampResult55 * _DiffuseTop ) , clampResult39);
			o.Albedo = lerpResult33.rgb;
			o.Emission = float4(0,0,0,1).rgb;
			o.Metallic = _Metalness;
			o.Smoothness = min( _SmoothnessCap , temp_output_54_0 );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
2569;-518;1837;1064;2438.655;689.8699;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;65;-3319.3,-820.1493;Float;False;485.7856;203.3354;Drive UVs based on global position;2;67;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-3023.856,-583.4764;Float;False;1670.327;389.7507;Calculated procedural swirls;7;55;54;53;52;51;50;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;66;-3263.195,-771.7841;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-2943.681,-351.8981;Float;False;Property;_Albedo2Scale;Albedo2 Scale;9;0;Create;True;0;0;False;0;0;115;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;67;-3012.847,-775.0236;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;50;-2717.231,-554.0331;Float;False;Constant;_Tiling2;Tiling 2;5;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2716.99,-369.165;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2009.167,-60.49413;Float;False;332.5985;402.1107;Geometric information;2;32;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-1633.535,458.1738;Float;False;380.7224;194.9109;Scaled time component to wave's period;3;6;4;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1630.861,245.6271;Float;False;370.0282;188.227;Wave advances along model's x-axis;2;15;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1749.836,681.4142;Float;False;497.0217;148.1238;Object's transform height used as anim offset;1;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1545.313,-92.57693;Float;False;803.1427;259.076;Object's local y dimension used to determine albedo gradient;5;39;38;35;37;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1606.252,494.33;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-2523.628,-414.4257;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;2;-1873.013,39.03096;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1591.538,566.6666;Float;False;Property;_TimeScale;TimeScale;3;0;Create;True;0;0;False;0;5;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;32;-1896.8,182.33;Float;False;Object;World;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;16;-1618.374,340.7685;Float;False;Property;_GeometricPeriod;Geometric Period;2;0;Create;True;0;0;False;0;5;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;53;-2240.844,-419.9628;Float;True;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1403.633,323.3389;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1618.622,735.7184;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1404.133,493.6667;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1459.707,-16.34113;Float;False;Property;_GradientScale;Gradient Scale;7;0;Create;True;0;0;False;0;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1254.272,-20.60563;Float;False;Property;_GradientOffset;Gradient Offset;8;0;Create;True;0;0;False;0;0;-0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;54;-2034.789,-414.1493;Float;True;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1152.947,402.6056;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-978.5146,365.9369;Float;False;426.1726;212.2889;Amplitude contribution masked by origin;3;13;12;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1200.272,64.39435;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;11;-847.4817,416.6364;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;55;-1600.456,-413.9154;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1036.271,18.39436;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-922.9999,488.777;Float;False;Property;_WaveMagnitude;Wave Magnitude;4;0;Create;True;0;0;False;0;0.5;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1218.942,-664.9561;Float;False;Property;_DiffuseBottom;Diffuse Bottom;1;0;Create;True;0;0;False;0;0,0,0,0;0.3396226,0.3396226,0.3396226,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-1253.044,-274.2335;Float;False;Property;_DiffuseTop;Diffuse Top;0;0;Create;True;0;0;False;0;0,0,0,0;0,0.00681342,0.1226415,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-709.4817,416.6364;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-626.1436,203.1727;Float;False;Property;_SmoothnessCap;Smoothness Cap;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;39;-901.2822,16.96856;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-929.5349,-504.8312;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-924.9919,-333.3581;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-606.5374,30.1665;Float;False;Property;_Metalness;Metalness;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-532.345,-141.2666;Float;False;Constant;_Color0;Color 0;9;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;70;-296.7051,185.391;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;33;-622.0549,-367.7708;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-305.6023,275.1754;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;SSG_FishVertexDeformation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;67;0;66;1
WireConnection;67;1;66;2
WireConnection;51;0;67;0
WireConnection;51;1;49;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;53;0;52;0
WireConnection;15;0;2;1
WireConnection;15;1;16;0
WireConnection;41;0;32;2
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;54;0;53;0
WireConnection;8;0;15;0
WireConnection;8;1;5;0
WireConnection;8;2;41;0
WireConnection;36;0;38;0
WireConnection;36;1;2;2
WireConnection;11;0;8;0
WireConnection;55;0;54;0
WireConnection;35;0;37;0
WireConnection;35;1;36;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;12;2;2;1
WireConnection;39;0;35;0
WireConnection;63;0;34;0
WireConnection;63;1;55;0
WireConnection;64;0;55;0
WireConnection;64;1;21;0
WireConnection;70;0;30;0
WireConnection;70;1;54;0
WireConnection;33;0;63;0
WireConnection;33;1;64;0
WireConnection;33;2;39;0
WireConnection;14;2;12;0
WireConnection;0;0;33;0
WireConnection;0;2;40;0
WireConnection;0;3;29;0
WireConnection;0;4;70;0
WireConnection;0;11;14;0
ASEEND*/
//CHKSM=0EF6FCFA9B3A258FEA71B8334CB3A3ADE8AD1A6C