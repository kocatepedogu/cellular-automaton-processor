// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0 OR GPL-3.0-or-later

#include <SDL.h>

namespace Simulator {
  class SDL {
  private:
    int window_width;
    int window_height;

    uint8_t *buffer;

    SDL_Window *sdl_window;
    SDL_Renderer *sdl_renderer;
    SDL_Texture *sdl_texture;

  public:
    SDL(int window_width, int window_height);
    ~SDL();

    bool checkQuit();
    void writePixel(int x, int y, uint8_t r, uint8_t g, uint8_t b, uint8_t a);
    void update();
  };
}
