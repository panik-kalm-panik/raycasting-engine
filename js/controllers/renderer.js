var engine = angular.module('raycast_engine', []); 
engine.controller('renderer', ['$scope', function () {

    //? [VARIBLES]
    let vertex_shader_source, fragment_shader_source;

    //? [COMPILE SHADER]
    //? Creates a Web GL shader using the source sent as an argument.
    compile_shader = function (gl, type, source) {
        //? Create a shader using the parameters sent.
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);

        //? If the shader fails to be created, send and error and return.
        if(!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            console.error('An error occurred compiling the shaders: ' + gl.getShaderInfoLog(shader));
            gl.deleteShader(shader);
            return null;
        }

        //? Send the shader to the program.
        return shader;
    }
    
    //? [CREATE PROGRAM]
    //? Create both vertex and fragment shaders, and loads a custom variable to the fragment shader.
    create_program = function (gl, vertex_source, fragment_source, viewport) {
        //? Creates both shaders.
        const vertex_shader = compile_shader(gl, gl.VERTEX_SHADER, vertex_source);
        const fragment_shader = compile_shader(gl, gl.FRAGMENT_SHADER, fragment_source);

        //? Creates a program variable.
        const program = gl.createProgram();
        //? Attaches the shaders to the program.
        gl.attachShader(program, vertex_shader);
        gl.attachShader(program, fragment_shader);
        //? Links the program to the Web GL context.
        gl.linkProgram(program);

        //? If the program fails to be created, send and error and return.
        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            alert("Program creation error", gl.getProgramInfoLog(program));
            gl.deleteProgram(program);
            return null;
        }

        //? Send a custom variable that contains the dimensions of the canvas to the frament shader.
        const resolutionLocation = gl.getUniformLocation(program, "resolution");
        gl.useProgram(program);
        gl.uniform2f(resolutionLocation, viewport.width, viewport.height);

        //? Send the program to the renderer.
        return program;
    }

    //? [RENDER INIT]
    //? Creates the GL program along with WebGL generic data.
    render_init = function (gl, viewport) {
        //? Creates the program variable.
        const program = create_program(gl, vertex_shader_source, fragment_shader_source, viewport);

        //? Creates the WebGL generic data.
        const positionAttributeLocation = gl.getAttribLocation(program, 'position');
        const positionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
        gl.enableVertexAttribArray(positionAttributeLocation);
        gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
        const resolutionUniformLocation = gl.getUniformLocation(program, 'resolution');
        const timeUniformLocation = gl.getUniformLocation(program, 'time');

        //? Calls the render funcion.
        function render(currentTime) {
            //? Sets the viewport dimensions.
            gl.viewport(0, 0, viewport.width, viewport.height);

            //? Gives the context some generic values.
            gl.uniform2f(resolutionUniformLocation, viewport.width, viewport.height);
            gl.uniform1f(timeUniformLocation, currentTime * 0.001);
            gl.clearColor(0.0, 0.0, 0.0, 1.0);
            gl.clear(gl.COLOR_BUFFER_BIT);
            gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    
            //? Loops the render frame call.
            requestAnimationFrame(render);
        }
        //? Loops the render frame call.
        requestAnimationFrame(render);
    }

    //? [ON-LOAD]
    //? Sends a fetch request and reads the source files for both the vertex and fragment shaders.
    //? Then sets the canvas properties as well as the context for WebGL API.
    Promise.all([
        //? Sends fetch requests and awaits until the sources are fetched.
        //? Then reads the contents of the files.
        fetch('js/shaders/vertex.glsl').then(response => response.text()),
        fetch('js/shaders/fragment.glsl').then(response => response.text())
    ]).then(([vertex_shader_file_text, fragment_shader_file_text]) => {
        //? Saves the contents in the respective variables.
        vertex_shader_source = vertex_shader_file_text;
        fragment_shader_source = fragment_shader_file_text;

        //? Gets the DOM element for the canvas.
        const viewport = document.getElementById("viewport");
        //? Sets the canvas context to WebGL.
        const gl = viewport.getContext("webgl");
    
        //? If the program fails to get the WebGL context, return.
        if (gl === null) {
            alert("Unable to initialize WebGL, you browser or machine may not support it");
            return;
        }
    
        //? Set the canvas dimensions to fit the screen.
        gl.canvas.width = window.innerWidth;
        gl.canvas.height = window.innerHeight;

        //? Start the rendering process.
        render_init(gl, viewport);
    })
}])