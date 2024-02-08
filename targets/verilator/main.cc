// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

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

struct Program {
  const char *program_name;

  const char *source_file;
  const char *output_file;

  const float color_range_min;
  const float color_range_max;

  Visualization visual_mode;
} programs[] = {
  {
    "game-of-life",
    "examples/game-of-life.asm",
    "examples/game-of-life.hex",
    0, 0, MONOCHROME
  }, {
    "recursion",
    "examples/recursion.asm",
    "examples/recursion.hex",
    0, 1000, COLOR
  }, {
    "heat-equation",
    "examples/heat.asm",
    "examples/heat.hex",
    0, 100, LINEAR_INTERPOLATION
  }, {
    "wave-equation",
    "examples/wave.asm",
    "examples/wave.hex",
    -20, 20, LINEAR_INTERPOLATION
  }
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

Program *findProgram(const char *program_name) {
  constexpr int number_of_programs = sizeof programs / sizeof(Program);

  for (int i = 0; i < number_of_programs; ++i) {
    Program *program = &programs[i];

    if (!strcmp(program->program_name, program_name)) {
      return program;
    }
  }

  return nullptr;
}

Program *parseArgs(int argc, char **argv) {
  Program *prog = nullptr;

  if (argc != 2) {
    std::cerr << "Missing program name" << std::endl;
    exit(EXIT_FAILURE);
  }

  if (!(prog = findProgram(argv[1]))) {
    std::cerr << "Given program is not found." << std::endl;
    exit(EXIT_FAILURE);
  }

  return prog;
}

void display(Simulator::SDL& sdl, Simulator::Simulation& sim, Program *prog) {
  for (int y = 0; y < window_height; ++y) {
      for (int x = 0; x < window_width; ++x) {
        unsigned int y_idx = y * sim.grid_height / window_height;
        unsigned int x_idx = x * sim.grid_width / window_width;

        switch (prog->visual_mode) {
          case MONOCHROME: {
            int value = sim.getState(x_idx, y_idx);
            int color = value ? 255 : 0;
            sdl.writePixel(x, y, color, color, color, 0);
          } break;

          case COLOR: {
            float value = sim.getState(x_idx, y_idx);
            Color color = interpolateColor(prog->color_range_min, prog->color_range_max, value);
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

            Color color = interpolateColor(prog->color_range_min, prog->color_range_max, v);
            sdl.writePixel(x, y, color.r, color.g, color.b, 0);
        } break;
      }
    }
  }
}

int main(int argc, char **argv) {
  // Get program
  Program *prog = parseArgs(argc, argv);

  // Compile program
  system(("python3 tools/assembler.py " + std::string(prog->source_file) + " " +
                                          std::string(prog->output_file)).c_str());

  // Start simulation
  Simulator::Simulation sim(prog->output_file);
  sim.reset();

  // Render loop
  for(Simulator::SDL sdl(window_width, window_height); !sdl.checkQuit(); sdl.update()) {
    sim.nextInstruction();
    display(sdl, sim, prog);
  }

  return 0;
}
