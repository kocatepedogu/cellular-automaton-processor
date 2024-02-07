// SPDX-FileCopyrightText: 2024 Doğu Kocatepe
// SPDX-License-Identifier: CERN-OHL-S-2.0 OR GPL-3.0-or-later

#include <verilated.h>

#include "Vtop.h"
#include "Vtop_top.h"
#include "Vtop_multiprocessor__W19_H19_R20.h"

namespace Simulator {
  class Simulation {
  private:
    uint8_t *instruction_memory;

  public:
    int grid_width;
    int grid_height;
    int register_length;

    Vtop *top;

    Simulation(std::string program_file_name);
    ~Simulation();

    void clock();
    void reset();
    void nextInstruction();
    int getState(int x, int y);
  };
}
