# SPDX-FileCopyrightText: 2024 Doğu Kocatepe
# SPDX-License-Identifier: GPL-3.0-or-later

# Constant value
li r8,1

# Compute factorial(x) for cells whose x < 8, and visualize result as color
li r6,8
slt r6,x,r6
unl r6,loop
  add r2,x,zero
  li r1,1
  call factorial
  add video,r1,zero
loop:
  j loop

# Factorial function implemented using tail recursion
# Input: r1=1, r2=n, Result: r1=factorial(n)
factorial:
  seq r3,r2,zero
  nor r3,r3,zero
  and r3,r3,r8
  unl r3,done
    mul r1,r1,r2
    sub r2,r2,r8
    call factorial
done:
  ret 0

