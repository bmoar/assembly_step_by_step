# Protected Mode Memory Addressing

```

[ base + ( index * scale ) + displacement ]
    |       |       |           |
    V       V       V           V
  any GP  any GP   1,2,4,8    32-bit or 64bit constant, usually a symbolic addr

examples: 

[eax] = base

[rax + rdx] = base + index

[rax + rdx + some_label] = base + index + displacement

[eax * 8 + 65] = index times scale plus displacement

[rax + rdx * 8 + 3] = base + index * scale + displacement


```
