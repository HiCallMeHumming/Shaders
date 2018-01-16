Shader "Custom/MixingColors"
{
	Properties
	{
	_Tint1 ("Texture 1", Color) = (0,0,0,1)
	_Tex1 ("", 2D) = "" {}
	_Transp1("Transparency", Range(0.0,0.5)) = 0.25
	_SpeedX1("Speed X" ,Range(-3 , 3)) = 1.5
	_SpeedY1("Speed Y" ,Range(-3 , 3)) = 1.5

	_Tint2("Texture 2", Color) = (0,0,0,1)
	_Tex2("", 2D) = "" {}
	_Transp2("Transparency", Range(0.0,0.5)) = 0.25
	_SpeedX2("Speed X" ,Range(-3 , 3)) = 1.5
	_SpeedY2("Speed Y" ,Range(-3 , 3)) = 1.5

	_Tint3("Texture 3", Color) = (0,0,0,1)
	_Tex3("", 2D) = "" {}
	_SpeedX3("Speed X" ,Range(-3 , 3)) = 1.5
	_SpeedY3("Speed Y" ,Range(-3 , 3)) = 1.5

	_CutoutThresh("Textures' Cutout Threshold", Range (0, 1)) = 1
	}
	SubShader
	{
		Tags {
		"RenderType" = "Transparent"
		"Queue" = "Transparent" 
		//"IgnoreProjection" = "True"
	}
		LOD 100
		Blend DstColor Zero

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			float4 _MainTex_ST;
			sampler2D _Tex1;
			float4 _Tint1;
			sampler2D _Tex2;
			float4 _Tint2;
			sampler2D _Tex3;
			float4 _Tint3;

			float _SpeedX1;
			float _SpeedY1;
			float _SpeedX2;
			float _SpeedY2;
			float _SpeedX3;
			float _SpeedY3;

			float _CutoutThresh;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 tex1 = tex2D(_Tex1, i.uv + float2(((_Time.y) * _SpeedX1), (_Time.y)*_SpeedY1)) * _Tint1;
				//clip(tex1.a - _CutoutThresh);
				fixed4 tex2 = tex2D(_Tex2, i.uv + float2(((_Time.y) * _SpeedX2), (_Time.y)*_SpeedY2)) * _Tint2;
				//clip(tex2.a - _CutoutThresh);
				fixed4 tex3 = tex2D(_Tex3, i.uv + float2(((_Time.y) * _SpeedX3), (_Time.y)*_SpeedY3)) * _Tint3;
				//clip(tex3.a - _CutoutThresh);
				fixed3 finaltex = (tex1 * tex1.a) + (tex2 * tex2.a) + (tex3 * tex3.a);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finaltex);
				return fixed4 (finaltex, 1 - _CutoutThresh);
			}
			ENDCG
		}
	}
}
