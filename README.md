# Woahdude
iOS OpenGL Shader Language app!
Woahdude is an Open Source project that lets you test your GLSL programs directly on iOS devices.

The app comes with predefined Shaders copied from http://glslsandbox.com for your enjoyment!

![List of predefined shaders](https://is1-ssl.mzstatic.com/image/thumb/Purple117/v4/d3/aa/1c/d3aa1cfb-f3bf-7f78-5c2f-440b4fa0f486/pr_source.png/750x750bb.jpg?1494931550273)

You can view each one of them in action, and change the screen resolution (to test performance) from the UISegmentedControl on the top.
You can change the uniform color from the bottom RGB sliders, and you can change the time scale from the white slider!

![Shader in action](https://is1-ssl.mzstatic.com/image/thumb/Purple117/v4/f3/0a/42/f30a42b2-151d-b9b9-b8ed-a06da41bb388/pr_source.png/750x750bb.jpg?1494931550275)

You can also fork the shader program and customize it to your own needs!

![Shader editor](https://is1-ssl.mzstatic.com/image/thumb/Purple127/v4/01/78/c5/0178c5db-0a91-f989-7c10-33b780e212eb/pr_source.png/750x750bb.jpg?1494931550275)

# Requirements!
Just make sure to implement the 4 uniforms: time, color, mouse and resolution.
> time is a single float uniform and represents the time progress
> color is a vec4 float uniform that represents the values of the RGB sliders
> mouse is a vec2 float uniform that represents the location of touch on the screen
> resolution is required for the size of the GLKView that is rendering the shader

Here's an extra screenshot of an awesome shader!

![Waves](https://is1-ssl.mzstatic.com/image/thumb/Purple127/v4/64/7b/ac/647bac4b-6254-febf-f40a-d8080a021da8/pr_source.png/750x750bb.jpg?1494931550276)
