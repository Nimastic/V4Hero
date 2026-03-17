#ifndef DRUM_H
#define DRUM_H

#include "../Graphics/SpriteWrapper.h"
#include <SFML/Graphics.hpp>

class Drum
{
public:
    SpriteWrapper s_drum;
    SpriteWrapper s_flash;

    sf::CircleShape c_shockwave;
    sf::CircleShape c_shockwave2;

    sf::Clock drumClock;
    float alpha = 255;

    float x = 0, y = 0;
    float x_scale = 1, y_scale = 1;

    float x_flashscale = 0.01f, y_flashscale = 0.01f;
    float flashalpha = 125;

    float shockwaveSize = 100;
    float shockwaveAlpha = 20;

    float shockwave2Size = 30;
    float shockwave2Alpha = 40;

    float rotation = 0;
    bool isBest = false;
    bool isDon = false;

    float max_radius = 12;

    struct Particle {
        sf::CircleShape c_particle;
        bool didStart;
        float x, y, angle, radius, curDistance, maxDistance, speed;
        Particle() = default;
        Particle(sf::CircleShape c_particle, bool didStart, float x, float y, float angle, float radius, float curDistance, float maxDistance, float speed)
            : c_particle(std::move(c_particle)), didStart(didStart), x(x), y(y), angle(angle), radius(radius), curDistance(curDistance), maxDistance(maxDistance), speed(speed) {}
    };

    std::vector<Particle> particles;

    int pattern = 0;
    std::string cur_drum;

    struct DrumPattern {
        float x=0, y=0, angle=0, xSpeed=0, ySpeed=0, rotSpeed=0;
        DrumPattern() = default;
        DrumPattern(float x, float y, float angle, float xSpeed, float ySpeed, float rotSpeed)
            : x(x), y(y), angle(angle), xSpeed(xSpeed), ySpeed(ySpeed), rotSpeed(rotSpeed) {}
    };

    std::vector<DrumPattern> drumPatterns;

    Drum();
    void Load(std::string drum, int perfection, std::string& drum_texture);
    void Draw();
};

#endif // DRUM_H
