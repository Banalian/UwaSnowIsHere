//Global atlas
UI::Texture@ g_atlas;
int g_sprite_width = 17;
int g_sprite_height = 17;

vec2 rotOrigin = vec2(g_sprite_width/2, g_sprite_height/2);


class Snowflake : Animation {
    vec2 position;
    float curXDir = 1;
    float curYSpeed = 5;
    float curRotation = 0;

    float targetXDir = curXDir;
    float lerpFactor = 0.01f;

    // decay stuff: we want to randomly change the x direction of the snowflake, with a certain probability (to try and have a natural look)
    // (we'll check the g_dt and do some modulo operation to see if we should change the direction)
    int decay = Math::Rand(1, 100);

    uint color;

    Snowflake() {
        if (@g_atlas is null)
        {
            @g_atlas = UI::LoadTexture("src/img/smolsnowflake.png");
        }
        position = vec2(Math::Rand(0, g_width), -20);
        color = 0xFFFFFFFF;
        curRotation = Math::Rand(0, 360);
    }

    void Render() override {
        auto drawlist = UI::GetForegroundDrawList();
        auto state = VehicleState::ViewingPlayerState();
        float currentSpeed = 0;
        if(state is null) {
            currentSpeed = 0;
        } else {
            currentSpeed = state.WorldVel.Length() * 3.6;
        }

        UI::PushStyleColor(UI::Col::WindowBg, vec4(0,0,0,0));
        UI::PushStyleColor(UI::Col::Border, vec4(0,0,0,0));
        int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking | UI::WindowFlags::NoInputs;
        UI::Begin("Snowflake", windowFlags);

        vec2 rotOrigin = vec2(g_sprite_width/2, g_sprite_height/2.f);

        drawlist.AddImage(g_atlas, position, vec2(g_sprite_width,g_sprite_height), color, curRotation, rotOrigin);

        if ( (position.y >= g_height - g_sprite_height )
            || (position.x >= g_width + 50)
            || (position.x <= -50)
        ) {
            position.y = -50;
            position.x = Math::Rand(0, g_width);
            curYSpeed = Math::Rand(3, 7);
        } else {
            //print("Snowflake position: " + position.x + ", " + position.y);
            position.y += curYSpeed;
            position.x += curXDir;
            // adds a bias: the faster we go, the more we should move to the side (based on current position)
            // so, if we're on the right of the screen, move faster right, and vice versa
            float bias = 0;
            if (currentSpeed > 0) {
                bias = position.x > g_width / 2 ? 1 : -1;
                bias *= currentSpeed / 100;
            } else {
                bias = 0;
            }
            position.x += bias;
        }

        // decay stuff (approximate modulo since g_dt is a float)
        if (int(g_dt) % decay == 0) {
            targetXDir = Math::Rand(-1, 2) * Math::Rand(0.1f, 3.f);
            decay = Math::Rand(1, 100);
        }

        curXDir = Math::Lerp(curXDir, targetXDir, lerpFactor);


        UI::End();
        UI::PopStyleColor(2);
    }
}