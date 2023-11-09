precision mediump float;

//? [JS VARIABLES]
uniform vec2 resolution;

//? [SHADER VARIABLES]
//? Max steps of the raymarcher.
#define max_steps 100
//? Min steps of the raymarcher.
#define surf_dist .01
//? Max distance of the raymarcher.
#define max_dist 100.

vec4 sphere_sdf(vec3 position, vec4 sphere, vec3 color) {
    //? Calculates the distance from the camera.
    float sdf = length(position-sphere.xyz)-sphere.w;

    //? Returns the object composed of:
    //? The color and the distance from the camera.
    return vec4(color, sdf);
}

//? Creates a plane object
vec4 plane_sdf(vec3 position, vec3 color) {
    //? Calculates the distance from the camera.
    float sdf = position.y;

    //? Returns the object composed of:
    //? The color and the distance from the camera.
    return vec4(color, sdf);
}

//? Calculates the min of two objects.
vec4 min_sdf(vec4 object_a, vec4 object_b) {
    //? If the distance of the object a is less than the distance of the object b. Return a;
    if (object_a.w < object_b.w) return object_a;
    //? If the distance of the object b is less than the distance of the object a. Return b;
    else if (object_b.w < object_a.w) return object_b;
    //? If the distances are the same, return a by default.
    else return object_a;
}

//? Gets the object hit by the raymarcher.
vec4 get_object_hit(vec3 position) {
    //? Creates the objects of the scene.
    vec4 sphere_object_red = sphere_sdf(position, vec4(-.35, 1.2, 6, 1), vec3(1, 0, 0));
    vec4 sphere_object_green = sphere_sdf(position, vec4(0, .6, 4.5, .5), vec3(0, 1, 0));
    vec4 sphere_object_blue = sphere_sdf(position, vec4(.20, .3, 3.5, .25), vec3(0, 0, 1));
    vec4 plane_object = plane_sdf(position, vec3(1, 1, 1));

    //? Calculates the min of all the objects in the scene, to get which on was hit.
    vec4 sdf_object = min_sdf(sphere_object_red, sphere_object_green);
    sdf_object = min_sdf(sdf_object, sphere_object_blue);
    sdf_object = min_sdf(sdf_object, plane_object);

    //? Returns the hit object.
    return sdf_object;
}

//? Standar raymarcher.
vec4 ray_march(vec3 camera_position, vec3 ray_direction) {
    //? Initializes a variable that stores the distance traveled towards the point.
    float distance_traveled = 0.;
    //? Initializes the object color to black.
    vec3 object_color = vec3(0, 0, 0);

    //? Repeats the raymarching algorythm for a max of X steps. (100 by default)
    for (int i = 0; i < max_steps; i++) {
        //? Saves the position in which the step ended.
        vec3 step_position = camera_position + ray_direction * distance_traveled;
        //? Saves the distance traveled in the step
        float step_distance = get_object_hit(step_position).w;
        //? Adds the distance of the step, to the general distance traveled.
        distance_traveled += step_distance; 
        //? Gets the color of the object hit.
        object_color = get_object_hit(step_position).xyz;
        //? If the distance traveled is greater that the max view distance.
        //? Or less that the minimum value distance.
        //? Stop the loop.
        if (distance_traveled > max_dist || step_distance < surf_dist) break;
    }

    //? Returns a object that saves the color of the object, and the distance the raymarched traveled.
     return vec4(object_color, distance_traveled);
}

//? Gets the normal of the object hit.
vec3 get_normal(vec3 object_hit) {
    //? Saves the traveled distance from the camera to the object specific point.
    float distance_of_point = get_object_hit(object_hit).w;
    //? Calculates the normals using the distance.
    vec2 e = vec2(0.1, 0);
    vec3 normal = distance_of_point - vec3(
        get_object_hit(object_hit - e.xyy).w,
        get_object_hit(object_hit - e.yxy).w,
        get_object_hit(object_hit - e.yyx).w);

    //? Return the normal vector for the individual point.
    return normalize(normal);
}

//? Gets the lighting for the scene.
float get_light(vec3 object_hit) {
    
    //! This variable should be called when the shader is loaded, not on every call.
    //! But since it's a really simple shader, the performance is not affected.
    //? Sets the light position. (It's a point light)
    vec3 light_position = vec3(2, 3.5, 3);

    //? Calculates the vector for the light.
    //? Which is the position of the ray hit, pointing towards the light.
    vec3 light_vector = normalize(light_position - object_hit);
    //? Calculates the normal of the object hit.
    vec3 normal = get_normal(object_hit);
    //? Calculates the lighting using the normals and the light vector.
    float diffuse_lighting = clamp(dot(normal, light_vector), 0., 1.);
    //? Calculates the shadow distance waymarching from the object hit, towards the normal vector.
    float shadow_distance = ray_march((object_hit + normal * (surf_dist * 1.1)), light_vector).w;
    //? If the shadow distance is less than the distance between the hit point and the light.
    //? It means there is an object between the hit point and the light, so the pixel is in the shadow.
    //? The shadows are 75% of the normal light.
    if (shadow_distance < length(light_position-object_hit)) diffuse_lighting *= .75;

    //? Returns the calculated lighting.
    return diffuse_lighting;
}

//? This funcion is called for each pixel in the canvas viewport. Every frame.
//? With a standar resolution of 1920x1080. (2073600 pixels)
//? And rendering with 60fps.

//? This function is called 124416000 times a second.
void main() {

    //! These variables should be called when the shader is loaded, not on every frame.
    //! But since it's a really simple shader, the performance is not affected.
    //? Normalizes the coordinates of the shader so the (0, 0) point is in the middle of the screen.
    vec2 uv = (gl_FragCoord.xy - .5 * resolution) / resolution.y;
    //? Initializes the pixel color as black.
    vec3 pixel_color = vec3(0);
    //? Sets the camera position.
    vec3 camera_position = vec3(0, 1, 0);

    //? Calculates the ray direction towards a pixel in the screen.
    vec3 ray_direction = normalize(vec3(uv.x, uv.y, 1));
    //? Raymarches from the camera position towards the ray direction.
    //? And stores the object that hits.
    //? The object stored is divided in two variables.
    //? - rgb - which stores the color of the object.
    //? - w - which stores the distance traveled unitl hiting the object.
    vec4 object_hit = ray_march(camera_position, ray_direction);
    //? Saves the position where the ray hits a object.
    vec3 ray_hit_position = camera_position + ray_direction * object_hit.w;
    //? Calculates a simple diffuse lighting.
    float diffuse_lighting = get_light(ray_hit_position);

    //? Sets the pixel color variable to the added values of the color and the lighting.
    pixel_color = object_hit.rgb * diffuse_lighting;
    //? Sends the pixel color to be drawn by the shader.
    gl_FragColor = vec4(pixel_color, 1.0);
}