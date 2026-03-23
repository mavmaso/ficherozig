# ficherozig

A CSV/delimited file reader written in Zig, built as a personal study project to explore low-level I/O, buffered chunk reading, and field parsing.

The main idea was to parse large files efficiently by reading in fixed-size chunks without loading everything into memory, while correctly handling fields that span chunk boundaries.

### How it works

`main.zig` reads a file in 64 KB chunks using a buffered reader and extracts fields delimited by `,` or `\n`. It handles fields that cross chunk boundaries by carrying leftover bytes to the next read.

`outro.zig` is a simpler alternative: reads the entire file into memory at once and splits by newline — useful as a baseline comparison.

## Requirements

- Zig 0.15+

## Setup

```sh
zig build
```

## Run

```sh
zig build run
```

Or directly:

```sh
zig run main.zig
```

## Test

```sh
zig build test --summary all
```

## Benchmark

Build with `ReleaseFast` and measure execution time with `time`:

```sh
zig build -Doptimize=ReleaseFast
time ./zig-out/bin/ficherozig
```

Example output (20 MB file on Apple Silicon):

```
________________________________________________________
Executed in    3.70 secs    fish           external
   usr time    0.26 secs
   sys time    3.37 secs
```

> The bottleneck is I/O (sys time), not CPU (usr time).

This is intended for comparison against equivalent implementations in other languages (Rust, Elixir, etc.) using the same input file.

## Sample data (`0mb.txt`)

```
destination;nome
5511932037133;Marcos
5511932037131;Mayumi
```

## Made by

- [mavmaso](https://github.com/mavmaso)
