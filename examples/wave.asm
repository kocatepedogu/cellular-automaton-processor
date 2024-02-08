; SPDX-FileCopyrightText: 2024 Doğu Kocatepe
; SPDX-License-Identifier: GPL-3.0-or-later

; ------- Constants -------

; Let r6 = 16.
li r6,16

; Let r7 = 2**16.
li r7,128
mul r7,r7,r7
li r2,2
mul r7,r7,r2
mul r7,r7,r2

; Let dt^2 = r8 = 1/2048 in 32 bit fixed point with 16/16 integer/fraction parts.
li r2,12
shr r8,r7,r2

; ------- Initial Conditions -------

; Initially both my = u(t-1) and r5 = u(t-2) are set to zero for all cells.
li my,0
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
mul my,r1,r2
mul my,my,r7
li r1,19
mul r5,r1,r2
mul r5,r5,r7

; Display u(t-2)
shr video,r5,r6
; Display u(t-1)
shr video,my,r6

; ------- Solution Loop -------

solution:
  ; Save my = u(t-1) to r4
  add r4,my,zero

  ; Obtain u(t-2)
  add my,r5,zero

  ; Compute d^2(u)/dx^2 at t-2
  add r1,x+,x-
  sub r1,r1,my
  sub r1,r1,my

  ; Compute d^2(u)/dy^2 at t-2
  add r2,y+,y-
  sub r2,r2,my
  sub r2,r2,my

  ; Compute d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  add r1,r1,r2

  ; Compute (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  fmul r1,r1,r8

  ; Compute 3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2
  li r2,3
  mul r1,r1,r2

  ; Compute [3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2] - [u at t-2]
  sub r1,r1,my

  ; Compute [3 * (dt^2) * d^2(u)/dx^2 + d^2(u)/dy^2 at t-2] + 2 * [u at t-1] - [u at t-2]
  add r1,r1,r4
  add r1,r1,r4

  add r5,zero,r4
  add my,zero,r1

  shr video,my,r6
  j solution
