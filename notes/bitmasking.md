bitwise operators + masking

# and
```
and al,bl == (al = al & bl)

and is useful to isolate specific bits

we have 1001b, want to check if bits 0,1 are set

first we can mask out with and

1001b & 0011b = 0001b

then any bits but the ones we care about (0,1) are set to 0
```

# or

```
or al,bl == (al = al | bl)

not used as often as and because it doesn't mask
```

# xor

```

xor rax,rax ; zero out rax == (rax = rax^rax)

two operands are different = 1
else 0

this means data is lost

```

segment registers ( 
    cs,
    ss,
    ds,
    es,
    fs,
    gs,
    )

cannot be bitwise opd

# shifting bits

```
shl rax,2

shift left rax 2

CX/CL used to be used for counting before gp registers became legit general purpose

how to shift

0xb76f

1011011101101111

shl ax,1

ax = 0110111011011110
CF gets set by shift, indicating the lsb was bumped off

rotate instructions do the same as shift, but they don't bump
bits into CF, they append them to the beginning

RCL = rotate using the carry bit in shift left
RCR = rotate using the carry bit in shift right

if you need to preform a rotate, and need to be sure of the state of CF,
there's STC ( set carry flag ), CLC ( clear carry flag )

```
