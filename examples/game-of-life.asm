# Generate glider pattern
cond1:
  li r1,0
  seq r1,y,r1
  unl r1,cond2
  li r1,1
  seq r1,x,r1
  unl r1,cond2
  li my,1

cond2:
  li r1,1
  seq r1,y,r1
  unl r1,cond3
  li r1,2
  seq r1,x,r1
  unl r1,cond3
  li my,1

cond3:
  li r1,2
  seq r1,y,r1
  unl r1,loop
  li r1,3
  slt r1,x,r1
  unl r1,loop
  li my,1

# Run Game of Life simulation
loop:
    # Retrieve left values
        # Shift everything to right and get (x-1,y)
        add r1,zero,x-
        add my,zero,x-

        # Retrieve (x-1,y-1)
        add r1,r1,y-
        # Retrieve (x-1,y+1)
        add r1,r1,y+

        # Shift everything back to left
        add my,zero,x+

    # Retrieve right values
        # Shift everything to left and get (x+1,y)
        add r2,zero,x+
        add my,zero,x+

        # Retrieve (x+1,y-1)
        add r2,r2,y-
        # Retrieve (x+1,y+1)
        add r2,r2,y+

        # Shift everything back to right
        add my,zero,x-

    # Retrieve upper
        add r1,r1,y-
    # Retrieve lower
        add r2,r2,y+
    # Sum all values
        add r1,r1,r2

    # Calculate output
        # r2 is true if the cell has 2 alive neighbours
        li r4,2
        seq r2,r1,r4

        # r3 is true if the cell has 3 alive neighbours
        li r4,3
        seq r3,r1,r4

        # r2 is true if the cell is currently alive and it has 2 or 3 alive neighbours
        or r2,r2,r3
        and r2,r2,my

        # r4 is true if the cell is currently dead but it has 3 alive neighbours
        nor r4,my,my
        and r4,r4,r3

        # If either r2 or r4 is true, the cell will be alive
        or my,r2,r4
        add video,zero,my

    # Go to the next cycle
        j loop
