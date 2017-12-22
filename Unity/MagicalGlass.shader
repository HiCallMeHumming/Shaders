Shader "Custom/MagicalGlass"
{
	Properties
	{
		_BumpMap("Normal", 2D) = "normal" {}
		_MainTex("Albedo Texture", 2D) = "white" {}
		_MaskTex("Mask Tex" ,  2D) = "white" {}
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_Refraction("Refraction Magnitude", Range(-1, 1)) = 0.015
		_CutoutThresh("Cutout threshold", Range(0.0,1.0)) = 0.2
		_SpeedX("Speed X" ,Range(0 , 3)) = 1.5
		_SpeedY("Speed Y" ,Range(0 , 3)) = 1.5
	}

		SubShader
		{
			Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			}
			LOD 100
			Cull off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "UnityStandardUtils.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
					float3 screen_uv : TEXCOORD1;
					float3 tangentToWorld[3] : TEXCOORD2;//TEXCOORD3;TEXCOORD4;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _TintColor;
				float _CutoutThresh;
				float _SpeedX;
				float _SpeedY;
				sampler2D _MaskTex;

				sampler2D _BumpMap;
				float _Refraction;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.screen_uv = float3((o.vertex.xy + o.vertex.w) * 0.5, o.vertex.w);

					// Normal Mapping Stuff
					o.normal = UnityObjectToWorldNormal(v.normal);
					float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
					float3x3 tangentToWorld = CreateTangentToWorldPerVertex(o.normal, tangentWorld.xyz, tangentWorld.w);
					o.tangentToWorld[0].xyz = tangentToWorld[0];
					o.tangentToWorld[1].xyz = tangentToWorld[1];
					o.tangentToWorld[2].xyz = tangentToWorld[2];

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// Normal Mapping Stuff
					float3 tangent = i.tangentToWorld[0].xyz;
					float3 binormal = i.tangentToWorld[1].xyz;
					float3 normal = i.tangentToWorld[2].xyz;
					float3 normalTangent = UnpackNormal(tex2D(_BumpMap, i.uv));
					float3 normalWorld = normalize(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z);

					// Refraction Vector from world Normal
					float3 viewSpaceNormal = mul(UNITY_MATRIX_V, normalWorld);
					float2 refractionVector = viewSpaceNormal.xy * viewSpaceNormal.z  * _Refraction;

					// Perspective correction for screen uv coordinate
					float2 screen_uv = i.screen_uv.xy / i.screen_uv.z;

					// sample the primary texture
					fixed4 col = tex2D(_MainTex , i.uv + refractionVector);
					clip(col - _CutoutThresh);
					col.a = tex2D(_MaskTex, i.uv+ float2(((_Time.y) * _SpeedX), (_Time.y)*_SpeedY)) + (-_CutoutThresh + _TintColor);
					return col;
				}
				ENDCG
			}
		}
}

//Credits to Broxxar, from the Makin' Stuff Look Good youtube channel for the refraction and normal mapping references