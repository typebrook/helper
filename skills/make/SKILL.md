---
name: make
description: Implement or complete Makefile targets from their names, comments and prerequisites, using inline shell or separate scripts. Use when working on a Makefile.
---

1. Read @Makefile to get full context, and works on it
2. If no more prompt or prompt match a target, finish command(s) based on target name, comments or prerequisites
3. Solution for each command based on the following priority:
  - Use system commands and pipe if solution <10LOC. If no ".ONESHELL:" specified in Makefile, add it.
  - Write separate script(s) if solution >10LOC
    * Choose language with order: bash -> python -> javascript
    * Use installed system resources if possible
    * If an opensource module/library has resolved issue very well, add related comment in @Makefile for suggestion
