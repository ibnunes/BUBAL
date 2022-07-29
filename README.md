# BUBAL &mdash; Barely Usable Brainfuck Assembly Language

Work (more like fun) in progress



## Instruction Set

| Instruction | Hexadecimal | Description |
| --- | --- | --- |
| **Fundamental** |
|        | `0x0000` | _Reserved_. |
| `stop` | `0x0001` | Stops a program. |
| `forw` | `0x0010` | Forwards `n` cells. |
| `back` | `0x0011` | Backwards `n` cells. |
| `inc`  | `0x0100` | Increments `n` to current cell. |
| `dec`  | `0x0101` | Decrements `n` to current cell. |
| `get`  | `0x0110` | Gets a value for current cell from input stream. |
| `out`  | `0x0111` | Outputs current value to output stream. |
| `lbl`  | `0x1000` | Defines a location in the code with `name`. |
| `jnz`  | `0x1001` | Jumps to location `name` if last operation did not yield zero. |
| **Extended** |
| `set`  | `0x1010` | Sets current cell directly to value `n`. |
| `cell` | `0x1011` | Goes directly to cell `n`. |
| `jmp`  | `0x1100` | Jumps unconditionally to location `name` |


