// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0 OR GPL-3.0-or-later

#include "sdl.hh"
#include "simulation.hh"

#include <iostream>

constexpr int window_width = 600;
constexpr int window_height = 600;

enum Visualization {
  MONOCHROME,
  COLOR,
  LINEAR_INTERPOLATION
};

struct Color {
  int r;
  int g;
  int b;
} colors [] = {
  {0,   0,     0}, // Black
  {148, 0,   211}, // Violet
  {75,  0,   130}, // Indigo
  {0,   0,   255}, // Blue
  {0,   255,   0}, // Green
  {255, 255,   0}, // Yellow
  {255, 127,   0}, // Orange
  {255, 0,     0}, // Red
  {255, 255, 255}, // White
};

Color interpolateColor(int min, int max, int value) {
  constexpr int number_of_colors = sizeof colors / sizeof(Color);

  float range = max - min;
  float float_color_idx = ((value - min) / range) * number_of_colors;

  int color_idx = float_color_idx;
  if (color_idx < 0) {
    color_idx = 0;
  } else if (color_idx >= number_of_colors) {
    color_idx = number_of_colors - 1;
  }

  int next_color_idx = color_idx + 1;
  if (next_color_idx >= number_of_colors) {
    next_color_idx = number_of_colors - 1;
  }

  float fractional_part = float_color_idx - color_idx;

  Color color = colors[color_idx];
  Color next_color = colors[next_color_idx];
  Color int_color = {
    (int)(color.r * (1-fractional_part) + next_color.r * fractional_part),
    (int)(color.g * (1-fractional_part) + next_color.g * fractional_part),
    (int)(color.b * (1-fractional_part) + next_color.b * fractional_part)
  };

  return int_color;
}

int main(int argc, char **argv) {
  Visualization visual_mode;

  float color_range_min = -20;
  float color_range_max = 20;

  std::string source_file;
  std::string output_file;

  if (argc != 2) {
    std::cerr << "Missing program name" << std::endl;
    exit(EXIT_FAILURE);
  }
  else {
    std::string program_name = argv[1];

    if (program_name == "game-of-life") {
      source_file = "examples/game-of-life.asm";
      output_file = "examples/game-of-life.hex";
      visual_mode = MONOCHROME;
    } else if (program_name == "recursion") {
      source_file = "examples/recursion.asm";
      output_file = "examples/recursion.hex";
      color_range_min = 0;
      color_range_max = 1000;
      visual_mode = COLOR;
    } else if (program_name == "heat-equation") {
      source_file = "examples/heat.asm";
      output_file = "examples/heat.hex";
      color_range_min = 0;
      color_range_max = 100;
      visual_mode = LINEAR_INTERPOLATION;
    } else if (program_name == "wave-equation") {
      source_file = "examples/wave.asm";
      output_file = "examples/wave.hex";
      color_range_min = -20;
      color_range_max = 20;
      visual_mode = LINEAR_INTERPOLATION;
    } else {
      std::cerr << "Unknown program name" << std::endl;
      exit(EXIT_FAILURE);
    }
  }

  // Compile program
  system(("python3 tools/assembler.py " + source_file + " " + output_file).c_str());

  // Start simulation
  Simulator::Simulation sim(output_file);
  sim.reset();

  // Render loop
  for(Simulator::SDL sdl(window_width, window_height); !sdl.checkQuit(); sdl.update()) {
      sim.nextInstruction();

      for (int y = 0; y < window_height; ++y) {
          for (int x = 0; x < window_width; ++x) {
            unsigned int y_idx = y * sim.grid_height / window_height;
            unsigned int x_idx = x * sim.grid_width / window_width;

            switch (visual_mode) {
              case MONOCHROME: {
                int value = sim.getState(x_idx, y_idx);
                int color = value ? 255 : 0;
                sdl.writePixel(x, y, color, color, color, 0);
              } break;
              case COLOR: {
                float value = (float)sim.getState(x_idx, y_idx);
                Color color = interpolateColor(color_range_min, color_range_max, value);
                sdl.writePixel(x, y, color.r, color.g, color.b, 0);
              } break;
              case LINEAR_INTERPOLATION: {
                float y_idx_f = (float)y * sim.grid_height / window_height - y_idx;
                float x_idx_f = (float)x * sim.grid_width / window_width - x_idx;

                float v_x_y = sim.getState(x_idx, y_idx);
                float v_xp_y = sim.getState(x_idx+1, y_idx);
                float v_y = v_x_y * (1 - x_idx_f) + v_xp_y * x_idx_f;

                float v_x_yp = sim.getState(x_idx, y_idx+1);
                float v_xp_yp = sim.getState(x_idx+1, y_idx+1);
                float v_yp = v_x_yp * (1 - x_idx_f) + v_xp_yp * x_idx_f;

                float v = v_y * (1 - y_idx_f) + v_yp * y_idx_f;

                Color color = interpolateColor(color_range_min, color_range_max, v);
                sdl.writePixel(x, y, color.r, color.g, color.b, 0);
              } break;
            }
          }
      }
  }

  return 0;
}
