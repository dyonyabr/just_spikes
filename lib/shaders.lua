box_shadow_shader = love.graphics.newShader([[
    uniform vec2 rectPos;         // Position of the rectangle (x, y)
    uniform vec2 rectSize;        // Size of the rectangle (width, height)
    uniform float shadowSpread;   // How far the shadow spreads
    uniform vec4 shadowColor;     // Color of the shadow (with alpha for opacity)

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 pos = screen_coords - rectPos;
        vec2 halfSize = rectSize * 0.5;

        float distX = max(0.0, abs(pos.x - halfSize.x) - halfSize.x);
        float distY = max(0.0, abs(pos.y - halfSize.y) - halfSize.y);
        float distance = length(vec2(distX, distY));

        float alpha = smoothstep(shadowSpread, 0.0, distance);
        return vec4(shadowColor.rgb, shadowColor.a * alpha);
    }
]])

circle_shadow_shader = love.graphics.newShader([[
    uniform vec2 circleCenter;   // Center of the circle (x, y)
    uniform float radius;        // Radius of the circle
    uniform float shadowSpread;  // How far the shadow spreads
    uniform vec4 shadowColor;    // Color of the shadow (with alpha for opacity)

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        float distance = length(screen_coords - circleCenter) - radius;
        float alpha = smoothstep(shadowSpread, 0.0, distance);
        return vec4(shadowColor.rgb, shadowColor.a * alpha);
        }
    ]])
