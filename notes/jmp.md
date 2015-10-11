# jumping and flag etiquette

```
ja:
    desc: jump if above
    flags: cf = 0 and zf = 0
jnbe:
    desc: jump if not below or equal
    flags: cf = 0

jae:
    desc: jump if above or equal
    flags: cf = 0
jnb:
    desc: jump if not below
    flags: cf = 0

jb:
    desc: jump if below
    flags: cf = 1
jnae:
    desc: jump if not above or equal
    flags: cf = 1

jbe:
    desc: jump if below or equal
    flags: cf = 1 or zf = 1
jna:
    desc: jump if not above
    flags: cf = 1 or zf = 1

je:
    desc: jump if equal
    flags: zf = 1
jz:
    desc: jump if zero
    flags: zf = 1

```
