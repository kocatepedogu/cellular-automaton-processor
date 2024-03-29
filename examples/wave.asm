; SPDX-FileCopyrightText: 2024 Doğu Kocatepe
; SPDX-License-Identifier: GPL-3.0-or-later

li precision,16

; ------- Constants -------

; Let dt^2 = r8 = 1/2048

li r1,1
fix r1,r1
li r2,12
shr r8,r1,r2

; ------- Initial Conditions -------

; Initially both rs = u(t-1) and r5 = u(t-2) are set to zero for all cells.
li rs,0
li r5,0

; Create wave in two cells
li r1,10
seq r2,x,r1
li r1,14
seq r3,x,r1
or r2,r2,r3
li r1,12
seq r1,y,r1
and r2,r2,r1

li r1,20
mul rs,r1,r2
fix rs,rs
li r1,19
mul r5,r1,r2
fix r5,r5

; Display u(t-2)
unfix video,r5
; Display u(t-1)
unfix video,rs

; ------- Solution Loop -------

solution:
  ; Save rs = u(t-1) to r4
  add r4,rs,zero

  ; Obtain u(t-2)
  add rs,r5,zero

  ; Compute d^2(u)/dx^2 at t-2
  add r1,x+,x-
  sub r1,r1,rs
  sub r1,r1,rs

  ; Compute d^2(u)/dy^2 at t-2
  add r2,y+,y-
  sub r2,r2,rs
  sub r2,r2,rs

  ; Compute d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  add r1,r1,r2

  ; Compute (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  fmul r1,r1,r8

  ; Compute 3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  li r2,3
  mul r1,r1,r2

  ; Compute [3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2] - [u at t-2]
  sub r1,r1,rs

  ; Compute [3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2] + 2 * [u at t-1] - [u at t-2]
  add r1,r1,r4
  add r1,r1,r4

  add r5,zero,r4
  add rs,zero,r1

  unfix video,rs
  j solution
