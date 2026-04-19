// xad_tape.cpp — thin wrapper that compiles XAD's single non-header translation
// unit (Tape.cpp) from the shipped inst/include/XAD/ directory. Letting R's
// default per-.cpp build rule handle this keeps -I flags consistent.
//
// XAD uses a per-translation-unit tape model: every shared library that
// allocates tapes must link its own Tape.o. xadr ships Tape.cpp under
// inst/include/XAD/ so downstream LinkingTo packages can do the same.

#include <XAD/Tape.cpp>
