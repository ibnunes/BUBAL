# BUBAL &mdash; Barely Usable Brainfuck Assembly Language



## Instruction Set

| Instruction | Hexadecimal | Description |
| --- | --- | --- |
| **Fundamental** |
| `forw` | Forwards `n` cells. |
| `back` | Backwards `n` cells. |
| `add`  | Adds `n` to current cell. |
| `sub`  | Subtracts `n` to current cell. |
| `get`  | Gets a value for current cell from input stream. |
| `out`  | Outputs current value to output stream. |
| `lbl`  | Defines a location in the code with `name`. |
| `jz`   | Jumps to location `name` if last operation yielded zero. |
| **Extended** |
| `set`  | Sets current cell directly to value `n`. |
| `cell` | Goes directly to cell `n`. |
| `jmp`  | Jumps unconditionally to location `name` |





