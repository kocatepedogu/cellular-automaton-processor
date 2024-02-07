// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0 OR GPL-3.0-or-later

#include "sdl.hh"

#include <iostream>

namespace Simulator {
  SDL::SDL(int window_width, int window_height) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
      std::cerr << "Cannot initialize SDL" << std::endl;
      exit(EXIT_FAILURE);
    }

    sdl_window = SDL_CreateWindow("Cellular Automata Processor", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, window_width, window_height, SDL_WINDOW_SHOWN);
    if (!sdl_window) {
      std::cerr << "Cannot create SDL window: " << SDL_GetError() << std::endl;
      exit(EXIT_FAILURE);
    }

    sdl_renderer = SDL_CreateRenderer(sdl_window, -1,SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer) {
      std::cerr << "Cannot create SDL renderer: " << SDL_GetError() << std::endl;
      exit(EXIT_FAILURE);
    }

    sdl_texture = SDL_CreateTexture(sdl_renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, window_width, window_height);
    if (!sdl_texture) {
      std::cerr << "Cannot create SDL texture: " << SDL_GetError() << std::endl;
      exit(EXIT_FAILURE);
    }

    this->window_width = window_width;
    this->window_height = window_height;
    this->buffer = new uint8_t[window_width * window_height * 4];
  }

  SDL::~SDL() {
    delete[] buffer;

    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    SDL_DestroyWindow(sdl_window);
    SDL_Quit();
  }

  bool SDL::checkQuit() {
    SDL_Event e;
    if (SDL_PollEvent(&e)) {
      if (e.type == SDL_QUIT) {
        return true;
      }
    }

    return false;
  }

  void SDL::writePixel(int x, int y, uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    uint8_t *pixel = &buffer[(y * window_width + x) * 4];

    pixel[0] = a;
    pixel[1] = b;
    pixel[2] = g;
    pixel[3] = r;
  }

  void SDL::update() {
    SDL_UpdateTexture(sdl_texture, NULL, buffer, window_width * 4);
    SDL_RenderClear(sdl_renderer);
    SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, NULL);
    SDL_RenderPresent(sdl_renderer);
  }
}
