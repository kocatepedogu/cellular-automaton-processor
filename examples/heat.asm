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

; Let r8 = 0.125 in 32 bit fixed point with 16/16 integer/fraction parts.
li r2,3
shr r8,r7,r2

; ------- Initial Conditions -------

; Initially set all cells to 0, and show a blank screen.
li my,0
add video,my,zero

; Compute (x-12)**2
li r1,12
sub r1,x,r1
mul r3,r1,r1

; Compute (y-12)**2
li r2,12
sub r2,y,r2
mul r4,r2,r2

; Compute (x-12)**2 + (y-12)**2
add r3,r3,r4

; Compute whether for the current cell (x-12)**2 + (y-12)**2 < 5**2
li r1,25
slt r2,r3,r1

; If condition is true, output 60 in 32 bit fixed point.
unl r2,solution
li r2,120
mul my,r2,r7

; Display initial conditions
shr video,my,r6

; ------- Solution Loop -------

solution:
  ; Compute d^2(u)/dx^2
  add r1,x+,x-
  sub r1,r1,my
  sub r1,r1,my

  ; Compute d^2(u)/dy^2
  add r2,y+,y-
  sub r2,r2,my
  sub r2,r2,my

  ; Compute d^2(u)/dx^2 + d^2(u)/dy^2
  add r1,r1,r2

  ; Compute dt * (d^2(u)/dx^2 + d^2(u)/dy^2)
  fmul r1,r1,r8

  ; Compute u(t+1) = u(t) + dt * (d^2(u)/dx^2 + d^2(u)/dy^2)
  add my,my,r1

  ; Display result
  shr video,my,r6
  j solution
