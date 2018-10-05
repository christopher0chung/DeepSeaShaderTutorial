// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SSG_PostPosterize"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_ColorChannelPosterization("Color Channel Posterization", Float) = 0
		_ValuePosterization("Value Posterization", Float) = 1.98
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_RealismPower("RealismPower", Range( 0 , 1)) = 0.5445201
		_ColorFlatteningPower("Color Flattening Power", Range( 0 , 1)) = 0
		_ColorPostToBWPost("ColorPost To BWPost", Range( 0 , 1)) = 0.579378
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _ColorChannelPosterization;
			uniform sampler2D _TextureSample0;
			uniform float4 _TextureSample0_ST;
			uniform float _ColorFlatteningPower;
			uniform float _ValuePosterization;
			uniform float _ColorPostToBWPost;
			uniform float _RealismPower;

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos ( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_TextureSample0 = i.uv.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float4 tex2DNode7 = tex2D( _TextureSample0, uv_TextureSample0 );
				float4 normalizeResult18 = normalize( tex2DNode7 );
				float4 lerpResult22 = lerp( tex2DNode7 , normalizeResult18 , _ColorFlatteningPower);
				float div30=256.0/float((int)_ColorChannelPosterization);
				float4 posterize30 = ( floor( lerpResult22 * div30 ) / div30 );
				float4 temp_cast_2 = (( ( tex2DNode7.r + tex2DNode7.g + tex2DNode7.b ) / 3.0 )).xxxx;
				float div5=256.0/float((int)_ValuePosterization);
				float4 posterize5 = ( floor( temp_cast_2 * div5 ) / div5 );
				float4 lerpResult8 = lerp( posterize30 , posterize5 , _ColorPostToBWPost);
				float4 lerpResult19 = lerp( lerpResult8 , tex2DNode7 , _RealismPower);
				

				finalColor = lerpResult19;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=15600
2569;-518;1837;1058;1769.737;1180.461;1.984196;True;False
Node;AmplifyShaderEditor.CommentaryNode;25;-547.6788,-103.5518;Float;False;581.7306;266.845;Posterize Light/Dark;4;15;16;5;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;7;-838.5197,-82.99317;Float;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;None;d657a1f69ccf4bf45aee95f3a094104b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;24;-828.5415,-526.3624;Float;False;793.4;365.4;Color Flattening and Posterize;5;30;31;21;18;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-804.4133,-372.0401;Float;False;Property;_ColorFlatteningPower;Color Flattening Power;4;0;Create;True;0;0;False;0;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-497.6788,-53.55169;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;18;-804.478,-442.4016;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-389.1987,50.64158;Float;False;Property;_ValuePosterization;Value Posterization;1;0;Create;True;0;0;False;0;1.98;62.253;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-545.3755,-246.5135;Float;False;Property;_ColorChannelPosterization;Color Channel Posterization;0;0;Create;True;0;0;False;0;0;8.7556;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-296.1782,-53.55175;Float;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;32;78.02316,-109.414;Float;False;624.2712;279.7205;Color to BW Lerp;2;9;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;22;-500.342,-465.9621;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.4980392;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;33;720.9861,245.3386;Float;False;626.8711;308.3206;Processed to Literal Lerp;2;20;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosterizeNode;5;-156.9482,-52.76945;Float;False;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;30;-207.3638,-467.1764;Float;False;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;115.0232,73.50641;Float;False;Property;_ColorPostToBWPost;ColorPost To BWPost;5;0;Create;True;0;0;False;0;0.579378;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;450.2945,-59.41405;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.4980392;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;770.9861,438.6586;Float;False;Property;_RealismPower;RealismPower;3;0;Create;True;0;0;False;0;0.5445201;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;19;1082.857,295.3382;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.4980392;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1393.067,297.1999;Float;False;True;2;Float;ASEMaterialInspector;0;2;SSG_PostPosterize;c71b220b631b6344493ea3cf87110c93;0;0;SubShader 0 Pass 0;1;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;15;0;7;1
WireConnection;15;1;7;2
WireConnection;15;2;7;3
WireConnection;18;0;7;0
WireConnection;16;0;15;0
WireConnection;22;0;7;0
WireConnection;22;1;18;0
WireConnection;22;2;21;0
WireConnection;5;1;16;0
WireConnection;5;0;6;0
WireConnection;30;1;22;0
WireConnection;30;0;31;0
WireConnection;8;0;30;0
WireConnection;8;1;5;0
WireConnection;8;2;9;0
WireConnection;19;0;8;0
WireConnection;19;1;7;0
WireConnection;19;2;20;0
WireConnection;1;0;19;0
ASEEND*/
//CHKSM=4B45BE827E925DC25967A51A788B79DF828A86C8