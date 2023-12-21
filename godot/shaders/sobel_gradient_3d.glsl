#[compute]

/**
* MIT License
*
* Copyright (c) 2023 Mark McKay
* https://github.com/blackears/godot_marching_cubes
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#version 450

layout(local_size_x = 4, local_size_y = 4, local_size_z = 4) in;

layout(r32f, set = 0, binding = 0) readonly restrict uniform image3D source_image;

layout(rgba32f, set = 0, binding = 1) writeonly restrict uniform image3D result_image;

//Sobel kernel for gradient calculations
vec3[] sobel_kernel = {
	vec3(-1.0, -1.0, -1.0), vec3(0.0, -2.0, -2.0), vec3(1.0, -1.0, -1.0),
	vec3(-2.0, 0.0, -2.0), vec3(0.0, 0.0, -4.0), vec3(2.0, 0.0, -2.0),
	vec3(-1.0, 1.0, -1.0), vec3(0.0, 2.0, -2.0), vec3(1.0, 1.0, -1.0),
	vec3(-2.0, -2.0, 0.0), vec3(0.0, -4.0, 0.0), vec3(2.0, -2.0, 0.0),
	vec3(-4.0, 0.0, 0.0), vec3(0.0, 0.0, 0.0), vec3(4.0, 0.0, 0.0),
	vec3(-2.0, 2.0, 0.0), vec3(0.0, 4.0, 0.0), vec3(2.0, 2.0, 0.0),
	vec3(-1.0, -1.0, 1.0), vec3(0.0, -2.0, 2.0), vec3(1.0, -1.0, 1.0),
	vec3(-2.0, 0.0, 2.0), vec3(0.0, 0.0, 4.0), vec3(2.0, 0.0, 2.0),
	vec3(-1.0, 1.0, 1.0), vec3(0.0, 2.0, 2.0), vec3(1.0, 1.0, 1.0),	
};

void main() {
	ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);

	vec4 value = vec4(0, 0, 0, 0);
	
	for (int k = 0; k < 3; ++k) {
		for (int j = 0; j < 3; ++j) {
			for (int i = 0; i < 3; ++i) {
				float samp = imageLoad(source_image, pos + ivec3(i - 1, j - 1, k - 1)).r;
				int kernel_index = (k * 3 + j) * 3 + i;
				value += vec4(sobel_kernel[kernel_index] * samp, 0);
			}
		}
	}
	
	value.a = 1.0;
	imageStore(result_image, ivec3(gl_GlobalInvocationID.xyz), value);
}


