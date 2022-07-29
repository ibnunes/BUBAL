# BUBAL &mdash; Barely Usable Brainfuck Assembly Language

BUBAL is yet another esoteric programming language astronomically inspired by Brainfuck. It is indeed a BAL (Brainfuck Assembly Language) with an IS (instruction set) designed to be expanded and run on architectures of at least 16 bits.

This is a side project allowing me to explore both theoretical and practical concepts of programming languages, interpreters and compilers.

Refer to [fpbrainfuck](https://github.com/ibnunes/fpbrainfuck) for a Brainfuck and regular variants interpreter.

## The Project

It is currently composed of proof-of-concepts. It encompasses 2 tools:

| Tool | Current version | Description |
| --- | --- | --- |
| **`bubal`**    | `0.0.1-alpha` (2022/07/29) | BUBAL interpreter. |
| **`bf2bubal`** | `0.0.1-alpha` (2022/07/29) | Brainfuck to BUBAL converter. |



## Instruction Set

The IS is composed of 2 main groups:

1. **Fundamental instructions**: these constitute direct equivalents to Brainfuck original syntax;
2. **Extended instructions**: the evolving instructions that allow finer control of the program (and it'll allow me to explore even further beyond the essential Brainfuck/BAL concept).

The **structural instructions** provide a quick reference for a program to stop (and a possible void operation).


| Instruction | Hexadecimal | Description |
| --- | --- | --- |
| **Structural** |
|        | `0x0000` | _Reserved_. |
| `stop` | `0x0001` | Stops a program. |
| **Fundamental** |
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


## Roadmap

This is yet to be properly defined at the time of writing. At the end of the day, Iḿ doing this just to learn and to have some fun 🙂

