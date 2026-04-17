#!/usr/bin/env bash
set -e

PROJ_NAME=core
TOP_DESIGN=core_wrap

case "$1" in
  synth)
    cd yosys
    PROJ_NAME=$PROJ_NAME TOP_DESIGN=$TOP_DESIGN ./run_synthesis.sh --synth
    ;;

  pnr)
    cd openroad
    PROJ_NAME=$PROJ_NAME TOP_DESIGN=$TOP_DESIGN ./run_backend.sh --all
    ;;

  gds)
    cd klayout
    ./run_finishing.sh --gds
    ;;

  sim)
    PROGRAM=${2:-rv32i/helloworld.hex}
    cd sw
    make all
    cd ../verilator
    ./run_verilator.sh --build --run ../sw/bin/$PROGRAM
    ;;

  wave)
    GTKW=${2:-cve2_tracer.gtkw}
    gtkwave verilator/croc.fst verilator/$GTKW
    ;;

  all)
    cd yosys
    PROJ_NAME=$PROJ_NAME TOP_DESIGN=$TOP_DESIGN ./run_synthesis.sh --synth
    cd ../openroad
    PROJ_NAME=$PROJ_NAME NETLIST=$NETLIST TOP_DESIGN=$TOP_DESIGN ./run_backend.sh --all
    ;;

  *)
    echo "Usage: $0 {synth|pnr|gds|sim|wave|all}"
    exit 1
    ;;
esac