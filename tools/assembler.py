# SPDX-FileCopyrightText: 2024 Doğu Kocatepe
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import copy

register_indices = {
    'my': 0,
    'r1': 1,
    'r2': 2,
    'r3': 3,
    'r4': 4,
    'r5': 5,
    'r6': 6,
    'r7': 7,
    'r8': 8,

    'zero': 9, 'video': 9,
    'x':  10,
    'y':  11,
    'x-': 12,
    'x+': 13,
    'y-': 14,
    'y+': 15,
}

i_type_instructions = {
    'li':   0,
}

b_type_instructions = {
    'unl':  1
}

r_type_instructions = {
    'add':  2,
    'sub':  3,
    'and':  4,
    'or':   5,
    'nor':  6,
    'seq':  7,
    'slt':  8,
    'mul':  9,
    'shr':  10,
    'fmul': 11
}

j_type_instructions = {
    'j':    12,
    'call': 13,
    'ret':  14
}

def initialize_register_indices():
    for i in range(0, 16):
        register_indices[f'${i}'] = i

def is_label(line):
    return len(line) >= 1 and line[-1] == ':'

def read_source_file(file_name):
    with open(file_name) as f:
        result = []
        for line in f.readlines():
            # Remove unnecessary white space
            ln = line.strip()
            if len(ln) == 0: continue

            # Remove comments
            comment_begin = ln.find('#')
            if comment_begin != -1:
                ln = ln[0:comment_begin]
            if len(ln) == 0:
                continue

            # Add line to result
            result.append(ln)

        return result


def get_symbol_table(source_code):
    symbol_table = copy.deepcopy(register_indices)
    address = 0
    for line in source_code:
        if is_label(line): 
            label_name = line[:-1]
            symbol_table[label_name] = address
        else: address += 2
    return symbol_table


def parse(source_code):
    lines = [line.split(' ') for line in source_code 
            if not is_label(line)]
    return [(line[0], line[1].split(',')) for line in lines]


def substitute_symbol_values(parsed_source_code, symbol_table):
    address = 0
    result = list()
    for instruction, operands in parsed_source_code:
        result.append((address, instruction,
            [int(operand) if operand not in symbol_table 
             else symbol_table[operand]
             for operand in operands]))
        address += 2
    return result


def encode(substituted_source):
    result = []
    for line in substituted_source:
        pc = line[0]
        mnemonic = line[1]
        operands = line[2]
        
        instr = None
        if mnemonic in i_type_instructions:
            opcode = i_type_instructions[mnemonic]
            target, imm = operands
            instr = (opcode & 0b1111) << 12 | (target & 0b1111) << 8 | (imm & 0b1111_1111)
        elif mnemonic in b_type_instructions:
            opcode = b_type_instructions[mnemonic]
            condition_reg, branch_addr = operands
            instr = (opcode & 0b1111) << 12 | (condition_reg & 0b1111) << 8 | (((branch_addr - pc) >> 1) & 0b1111_1111)
        elif mnemonic in r_type_instructions:
            opcode = r_type_instructions[mnemonic]
            target, first, second = operands
            instr = (opcode & 0b1111) << 12 | (target & 0b1111) << 8 | (first & 0b1111) << 4 | (second & 0b1111)
        elif mnemonic in j_type_instructions:
            opcode = j_type_instructions[mnemonic]
            addr = operands[0]
            instr = (opcode & 0b1111) << 12 | ((addr >> 1) & 0b1111_1111_1111)
        else:
            raise Exception('Unknown instruction')

        result.append(instr >> 8)
        result.append(instr & 0xFF)
    return result


def assemble(input_file):
    initialize_register_indices()
    source = read_source_file(input_file)
    symbol_table = get_symbol_table(source)
    parsed_source = parse(source)
    substituted_source = substitute_symbol_values(parsed_source, symbol_table)
    return encode(substituted_source)


def write_to_output_file(binary, output_file):
    with open(output_file, 'w') as f:
        for value in binary:
            f.write(hex(value)[2:].zfill(2) + '\n')


def main():
    if len(sys.argv) != 3:
        print("Usage: assembler.py [ASSEMBLY FILE] [OUTPUT FILE]")
        exit()

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    initialize_register_indices()
    source = read_source_file(input_file)
    symbol_table = get_symbol_table(source)
    parsed_source = parse(source)
    substituted_source = substitute_symbol_values(parsed_source, symbol_table)
    binary = encode(substituted_source)
    write_to_output_file(binary, output_file)

if __name__ == '__main__':
    main()
