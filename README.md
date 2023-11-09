# Raycasting Engine
![Static Badge](https://img.shields.io/badge/WebGL-990000?style=for-the-badge&logo=webgl&logoColor=990000&labelColor=black)
![Static Badge](https://img.shields.io/badge/JS-F7DF1E?style=for-the-badge&logo=javascript&logoColor=F7DF1E&labelColor=black)
![Static Badge](https://img.shields.io/badge/HTML-E34F26?style=for-the-badge&logo=HTML5&logoColor=E34F26&labelColor=black)
![Static Badge](https://img.shields.io/badge/CSS-1572B6?style=for-the-badge&logo=CSS3&logoColor=%231572B6&labelColor=black)

Raytraced scene preview:

<img src="https://github.com/panik-kalm-panik/raycasting-engine/assets/30728714/607b9db7-2604-4893-9dcb-37ac10643fc6" width="400">

## Description
### Purpose
The raymarcher engine is designed the render a simple 3D scene, by calculating the light rays casted from a virtual camera. It calculates the objects that intersect with the rays, and displays their color, along with simple diffuse lighting.

### Components

The GLSL fragment shader that serves as the raymarcher is divided in 4 components.
1. Raymarching algorithm:
    - Using a raymarching technique, casts rays from the camera position through the scene.
    - Steps iteratively through the ray, and determines collisions with the objects in the scene.


      <img src="https://github.com/panik-kalm-panik/raycasting-engine/assets/30728714/55d9e3dd-69ad-48b8-9770-9e451f9b0dbb" width="400">

3. Signed Distance Functions: (SDF)
    - Defines SDFs for the 3D objects in the scene.
    - Used to determine the intersections between the objects and the rays.

4. Objects intersections and color:
    - Detects the closest object to the position hit by the ray.
    - And stores its color to render it to the scene.

5. Basic diffuse lighting:
    - Computes a diffuse lighting using the object normals and a light position.
    - Considers shadows by raymarching toward the light source.


      <img src="https://github.com/panik-kalm-panik/raycasting-engine/assets/30728714/9cf3935b-92b4-4938-8c63-818603c0ac88" width="400">


### Performance Considerations
Some variables are assigned the same value multiple times, which can reduce performance when rendering more complex scenes. But since this is a really simple scene, I decided to keep that variables like that.
> [!IMPORTANT]  
> If you are using this raymarcher as a template for a bigger project, consider asigning those variables on load, instead of each iteration. (Every variable that should be changed is commented in the fragment shader)

## How to visualize
To see this raymarcher in action, open the following link to access the web hosted in [GitHub Pages](https://panik-kalm-panik.github.io/raycasting-engine/).

Or download the source code and open the project in a hosted server, like VSCode live-share.

## Acknowledgments
The creation of this raymarcher was inspired by:
 - [Sebastian Lague](https://www.youtube.com/@SebastianLague) - [Raymarching video.](https://www.youtube.com/watch?v=Cp5WWtMoeKg&t=141s)
 - [Art of code](https://www.youtube.com/@TheArtofCodeIsCool) - [Raymarching playlist.](https://www.youtube.com/playlist?list=PLGmrMu-IwbgtMxMiV3x4IrHPlPmg7FD-P)

Links for the diagrams in the "Components" section:
 - Raymarching diagram: [Wikipedia: Raymarching.](https://en.wikipedia.org/wiki/Ray_marching#/media/File:Visualization_of_SDF_ray_marching_algorithm.png)
 - Diffuse lighting diagram: [Wikipedia: Raytracing (graphics).](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)#/media/File:Ray_trace_diagram.svg)
