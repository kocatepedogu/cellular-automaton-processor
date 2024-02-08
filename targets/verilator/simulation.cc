// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

#include "simulation.hh"

#include <fstream>

namespace Simulator {
  Simulation::Simulation(std::string program_file_name) {
    this->top = new Vtop;
    this->grid_width = top->top->mp->width;
    this->grid_height = top->top->mp->width;
    this->instruction_memory = new uint8_t[512];

    std::ifstream input_file(program_file_name);
    for (uint8_t i = 0; i < 512; ++i) {
      std::string line;
      if (!std::getline(input_file, line)) {
        break;
      }

      instruction_memory[i] = std::stoul(line, nullptr, 16);
    }
  }

  Simulation::~Simulation() {
    top->final();
    delete[] instruction_memory;
  }

  void Simulation::clock() {
    top->clk = 1;
    top->eval();
    top->clk = 0;
    top->eval();
  }

  void Simulation::reset() {
    top->rst = 1;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->rst = 0;
    top->clk = 0;
    top->eval();
  }

  void Simulation::nextInstruction() {
    uint8_t upper = instruction_memory[top->program_counter+0];
    uint8_t lower = instruction_memory[top->program_counter+1];

    top->instruction = (upper << 8) | lower;
    clock();
  }

  int Simulation::getState(int x, int y) {
    return y < grid_height && x < grid_width ? top->top->mp->video[y][x] : 0;
  }
}
