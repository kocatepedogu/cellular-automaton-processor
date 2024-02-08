; SPDX-FileCopyrightText: 2024 Doğu Kocatepe
; SPDX-License-Identifier: GPL-3.0-or-later

li precision,8

; ------- Constants -------

; Let r8 = 0.125
li r1,1
fix r1,r1
li r2,4
shr r8,r1,r2

; ------- Initial Conditions -------

; Initially set all cells to 0, and show a blank screen.
li rs,0
add video,rs,zero

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

; If condition is true, output 120 in fixed point.
unl r2,solution
li r2,120
fix rs,r2

; Display initial conditions
unfix video,rs

; ------- Solution Loop -------

solution:
  ; Compute dt * d^2(u)/dx^2
  sub r1,x+,rs
  sub r2,rs,x-
  sub r1,r1,r2
  fmul r1,r1,r8

  ; Compute dt * d^2(u)/dy^2
  sub r2,y+,rs
  sub r3,rs,y-
  sub r2,r2,r3
  fmul r2,r2,r8

  ; Compute dt * (d^2(u)/dx^2 + d^2(u)/dy^2)
  add r1,r1,r2

  ; Compute u(t+1) = u(t) + dt * (d^2(u)/dx^2 + d^2(u)/dy^2)
  add rs,rs,r1

  ; Display result
  unfix video,rs
  j solution
