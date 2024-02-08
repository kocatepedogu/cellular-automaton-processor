// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0

#include <verilated.h>

#include "Vtop.h"
#include "Vtop_top.h"
#include "Vtop_multiprocessor.h"

namespace Simulator {
  class Simulation {
  private:
    uint8_t *instruction_memory;

  public:
    int grid_width;
    int grid_height;

    Vtop *top;

    Simulation(std::string program_file_name);
    ~Simulation();

    void clock();
    void reset();
    void nextInstruction();
    int getState(int x, int y);
  };
}
