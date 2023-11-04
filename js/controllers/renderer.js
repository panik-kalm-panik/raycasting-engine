engine.controller('renderer', ['$scope', function ($scope) {
    const viewport = document.getElementById("viewport");
    const gl = viewport.getContext("webgl");

    if (gl === null) {
        alert("Unable to initialize WebGL, you browser or machine may not support it");
        return;
    }

    gl.canvas.width = window.innerWidth;
    gl.canvas.height = window.innerHeight;

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

}])