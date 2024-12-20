array<Animation@> g_anims(150);
uint g_animsSize = 150;
uint g_animCount = 0;

float g_dt = 0;
int g_width;
int g_height;

void addSnowflake() {
    if (!UI::IsGameUIVisible()) return;

    if (g_animCount <= g_animsSize) {
        g_animsSize += 30;
        g_anims.Resize(g_animsSize);
    }

    @g_anims[g_animCount] = Snowflake();
    g_animCount++;
}

void resetSnowflakes() {    
    for (uint i = 0; i < g_animsSize; i++) {
         @g_anims[i] = null;
    }

    g_animsSize = 30;
    g_anims.Resize(g_animsSize);
    g_animCount = 0;
}

void Render() {
    if (!UI::IsGameUIVisible()) return;

    auto playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    if (playground !is null && (playground.UIConfigs.Length > 0)) {
        if (playground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
            return;
        }
    }

    auto visState = VehicleState::ViewingPlayerState();
    if (visState is null) return;

    for (uint i = 0; i < g_animsSize; i++) {
        if (@g_anims[i] !is null) {
            g_anims[i].Render();
        }
    }

}

void RenderMenu(){
    if (UI::BeginMenu(Icons::SnowflakeO + " Uwa Snow Is Here")) {
        if (UI::MenuItem("Reset Snowflakes")) {
            resetSnowflakes();
        }
        if (UI::MenuItem("Add Snowflake")) {
            addSnowflake();
        }
        UI::EndMenu();
    }
}


void Update(float dt) {
    g_dt += dt;
    auto app = cast<CTrackMania>(GetApp());
    if (app.ManiaPlanetScriptAPI.DisplaySettings is null) {
        app.ManiaPlanetScriptAPI.DisplaySettings_LoadCurrent();
    }
    auto windowSize = app.ManiaPlanetScriptAPI.DisplaySettings.WindowSize;

    g_width = windowSize.x;
    g_height = windowSize.y;

}

void Main() {
    while(g_dt < 1) {
        yield();
    }
    while (g_animCount < initialSnowflakeSize) {
        addSnowflake();
        sleep(Math::Rand(100, 500));
    }

    // add a snowflake every 1-3 seconds
    while (true && (g_animCount < maxAmountOfSnowflakes)) {
        addSnowflake();
        sleep(Math::Rand(1000, 3000));
    }
}