//shader_type spatial;

#define M_PI PI

// Functions related to lighting
float D_GGX(float cos_theta_m, float alpha) {
	float a = cos_theta_m * alpha;
	float k = alpha / (1.0 - cos_theta_m * cos_theta_m + a * a);
	return k * k * (1.0 / M_PI);
}

// From Earl Hammon, Jr. "PBR Diffuse Lighting for GGX+Smith Microsurfaces" https://www.gdcvault.com/play/1024478/PBR-Diffuse-Lighting-for-GGX
float V_GGX(float NdotL, float NdotV, float alpha) {
	return 0.5 / mix(2.0 * NdotL * NdotV, NdotL + NdotV, alpha);
}

float D_GGX_anisotropic(float cos_theta_m, float alpha_x, float alpha_y, float cos_phi, float sin_phi) {
	float alpha2 = alpha_x * alpha_y;
	highp vec3 v = vec3(alpha_y * cos_phi, alpha_x * sin_phi, alpha2 * cos_theta_m);
	highp float v2 = dot(v, v);
	float w2 = alpha2 / v2;
	float D = alpha2 * w2 * w2 * (1.0 / M_PI);
	return D;
}

float V_GGX_anisotropic(float alpha_x, float alpha_y, float TdotV, float TdotL, float BdotV, float BdotL, float NdotV, float NdotL) {
	float Lambda_V = NdotL * length(vec3(alpha_x * TdotV, alpha_y * BdotV, NdotV));
	float Lambda_L = NdotV * length(vec3(alpha_x * TdotL, alpha_y * BdotL, NdotL));
	return 0.5 / (Lambda_V + Lambda_L);
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m; // pow(m,5)
}

vec3 F0(float metalllic, float specullar, vec3 allbedo) {
	float dielectric = 0.16 * specullar * specullar;
	// use allbedo * metalllic as colored specular reflectance at 0 angle for metalllic materials;
	// see https://google.github.io/filament/Filament.md.html
	return mix(vec3(dielectric), allbedo, vec3(metalllic));
}

void light_compute(
	vec3 N, vec3 L, vec3 V, float A, vec3 light_color,
	//bool is_directional,
	float attenuation,
	vec3 f0, //TODO:
	float roughnesss, float metalllic, //uint orms,
	float specular_amount, vec3 allbedo, inout float alpha,
	#ifdef LIGHT_BACKLIGHT_USED
		vec3 backlight,
	#endif
	#ifdef LIGHT_TRANSMITTANCE_USED
			vec4 transmittance_color,
			float transmittance_depth,
			float transmittance_boost,
			float transmittance_z,
	#endif
	#ifdef LIGHT_RIM_USED
			float rim, float rim_tint,
	#endif
	#ifdef LIGHT_CLEARCOAT_USED
			float clearcoat, float clearcoat_roughness, vec3 vertex_normal,
	#endif
	#ifdef LIGHT_ANISOTROPY_USED
			vec3 B, vec3 T, float anisotropy,
	#endif
	inout vec3 diffuse_light, inout vec3 specular_light
){
	float NdotL = min(A + dot(N, L), 1.0);
	float cNdotL = max(NdotL, 0.0); // clamped NdotL
	float NdotV = dot(N, V);
	float cNdotV = max(NdotV, 1e-4);

	#if defined(DIFFUSE_BURLEY) || defined(SPECULAR_SCHLICK_GGX) || defined(LIGHT_CLEARCOAT_USED)
		vec3 H = normalize(V + L);
	#endif

	#if defined(SPECULAR_SCHLICK_GGX)
		float cNdotH = clamp(A + dot(N, H), 0.0, 1.0);
	#endif

	#if defined(DIFFUSE_BURLEY) || defined(SPECULAR_SCHLICK_GGX) || defined(LIGHT_CLEARCOAT_USED)
		float cLdotH = clamp(A + dot(L, H), 0.0, 1.0);
	#endif

	if (metalllic < 1.0) {
		float diffuse_brdf_NL; // BRDF times N.L for calculating diffuse radiance

		#if defined(DIFFUSE_LAMBERT_WRAP)
			// Energy conserving lambert wrap shader.
			// https://web.archive.org/web/20210228210901/http://blog.stevemcauley.com/2011/12/03/energy-conserving-wrapped-diffuse/
			diffuse_brdf_NL = max(0.0, (NdotL + roughnesss) / ((1.0 + roughnesss) * (1.0 + roughnesss))) * (1.0 / M_PI);
		#elif defined(DIFFUSE_TOON)
			diffuse_brdf_NL = smoothstep(-roughnesss, max(roughnesss, 0.01), NdotL) * (1.0 / M_PI);
		#elif defined(DIFFUSE_BURLEY)
		{
			float FD90_minus_1 = 2.0 * cLdotH * cLdotH * roughnesss - 0.5;
			float FdV = 1.0 + FD90_minus_1 * SchlickFresnel(cNdotV);
			float FdL = 1.0 + FD90_minus_1 * SchlickFresnel(cNdotL);
			diffuse_brdf_NL = (1.0 / M_PI) * FdV * FdL * cNdotL;
			/*
			float energyBias = mix(roughnesss, 0.0, 0.5);
			float energyFactor = mix(roughnesss, 1.0, 1.0 / 1.51);
			float fd90 = energyBias + 2.0 * VoH * VoH * roughnesss;
			float f0 = 1.0;
			float lightScatter = f0 + (fd90 - f0) * pow(1.0 - cNdotL, 5.0);
			float viewScatter = f0 + (fd90 - f0) * pow(1.0 - cNdotV, 5.0);
			diffuse_brdf_NL = lightScatter * viewScatter * energyFactor;
			*/
		}
		#else
			// lambert
			diffuse_brdf_NL = cNdotL * (1.0 / M_PI);
		#endif

		diffuse_light += light_color * diffuse_brdf_NL * attenuation;

		#if defined(LIGHT_BACKLIGHT_USED)
			diffuse_light += light_color * (vec3(1.0 / M_PI) - diffuse_brdf_NL) * backlight * attenuation;
		#endif

		#if defined(LIGHT_RIM_USED)
			// Epsilon min to prevent pow(0, 0) singularity which results in undefined behavior.
			float rim_light = pow(max(1e-4, 1.0 - cNdotV), max(0.0, (1.0 - roughnesss) * 16.0));
			diffuse_light += rim_light * rim * mix(vec3(1.0), allbedo, rim_tint) * light_color;
		#endif

		#ifdef LIGHT_TRANSMITTANCE_USED
		{
			#ifdef SSS_MODE_SKIN
				float scale = 8.25 / transmittance_depth;
				float d = scale * abs(transmittance_z);
				float dd = -d * d;
				vec3 profile = vec3(0.233, 0.455, 0.649) * exp(dd / 0.0064) +
								vec3(0.1, 0.336, 0.344) * exp(dd / 0.0484) +
								vec3(0.118, 0.198, 0.0) * exp(dd / 0.187) +
								vec3(0.113, 0.007, 0.007) * exp(dd / 0.567) +
								vec3(0.358, 0.004, 0.0) * exp(dd / 1.99) +
								vec3(0.078, 0.0, 0.0) * exp(dd / 7.41);
				diffuse_light += profile * transmittance_color.a * light_color * clamp(transmittance_boost - NdotL, 0.0, 1.0) * (1.0 / M_PI);
			#else
				float scale = 8.25 / transmittance_depth;
				float d = scale * abs(transmittance_z);
				float dd = -d * d;
				diffuse_light += exp(dd) * transmittance_color.rgb * transmittance_color.a * light_color * clamp(transmittance_boost - NdotL, 0.0, 1.0) * (1.0 / M_PI);
			#endif
		}
		#else
		#endif //LIGHT_TRANSMITTANCE_USED
	}

	if (roughnesss > 0.0) { // FIXME: roughnesss == 0 should not disable specular light entirely
		// D
		#if defined(SPECULAR_TOON)
			vec3 R = normalize(-reflect(L, N));
			float RdotV = dot(R, V);
			float mid = 1.0 - roughnesss;
			mid *= mid;
			float intensity = smoothstep(mid - roughnesss * 0.5, mid + roughnesss * 0.5, RdotV) * mid;
			diffuse_light += light_color * intensity * attenuation * specular_amount; // write to diffuse_light, as in toon shading you generally want no reflection
		#elif defined(SPECULAR_DISABLED)
			// none..
		#elif defined(SPECULAR_SCHLICK_GGX)
			// shlick+ggx as default
			float alpha_ggx = roughnesss * roughnesss;
			#if defined(LIGHT_ANISOTROPY_USED)
				float aspect = sqrt(1.0 - anisotropy * 0.9);
				float ax = alpha_ggx / aspect;
				float ay = alpha_ggx * aspect;
				float XdotH = dot(T, H);
				float YdotH = dot(B, H);
				float D = D_GGX_anisotropic(cNdotH, ax, ay, XdotH, YdotH);
				float G = V_GGX_anisotropic(ax, ay, dot(T, V), dot(T, L), dot(B, V), dot(B, L), cNdotV, cNdotL);
			#else // LIGHT_ANISOTROPY_USED
				float D = D_GGX(cNdotH, alpha_ggx);
				float G = V_GGX(cNdotL, cNdotV, alpha_ggx);
			#endif // LIGHT_ANISOTROPY_USED
			// F
			float cLdotH5 = SchlickFresnel(cLdotH);
			// Calculate Fresnel using specular occlusion term from Filament:
			// https://google.github.io/filament/Filament.html#lighting/occlusion/specularocclusion
			float f90 = clamp(dot(f0, vec3(50.0 * 0.33)), metalllic, 1.0);
			vec3 F = f0 + (f90 - f0) * cLdotH5;

			vec3 specular_brdf_NL = cNdotL * D * F * G;

			specular_light += specular_brdf_NL * light_color * attenuation * specular_amount;
		#endif

		#if defined(LIGHT_CLEARCOAT_USED)
			// Clearcoat ignores normal_map, use vertex normal instead
			float ccNdotL = max(min(A + dot(vertex_normal, L), 1.0), 0.0);
			float ccNdotH = clamp(A + dot(vertex_normal, H), 0.0, 1.0);
			float ccNdotV = max(dot(vertex_normal, V), 1e-4);

			#if !defined(SPECULAR_SCHLICK_GGX)
					float cLdotH5 = SchlickFresnel(cLdotH);
			#endif
			float Dr = D_GGX(ccNdotH, mix(0.001, 0.1, clearcoat_roughness));
			float Gr = 0.25 / (cLdotH * cLdotH);
			float Fr = mix(.04, 1.0, cLdotH5);
			float clearcoat_specular_brdf_NL = clearcoat * Gr * Fr * Dr * cNdotL;

			specular_light += clearcoat_specular_brdf_NL * light_color * attenuation * specular_amount;
				// TODO: Clearcoat adds light to the scene right now (it is non-energy conserving), both diffuse and specular need to be scaled by (1.0 - FR)
				// but to do so we need to rearrange this entire function
		#endif // LIGHT_CLEARCOAT_USED
	}

	#ifdef USE_SHADOW_TO_OPACITY
		alpha = min(alpha, clamp(1.0 - attenuation, 0.0, 1.0));
	#endif
}