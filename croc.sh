#!/usr/bin/env bash
set -e

case "$1" in
  synth)
    cd yosys
    ./run_synthesis.sh --synth
    ;;

  pnr)
    cd openroad
    ./run_backend.sh --all
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
    ./run_verilator.sh --flist --build --run ../sw/bin/$PROGRAM
    ;;

  wave)
    GTKW=${2:-cve2_tracer.gtkw}
    gtkwave verilator/croc.fst verilator/$GTKW
    ;;

  all)
    cd yosys
    ./run_synthesis.sh --synth
    cd ../openroad
    ./run_backend.sh --all
    cd ../klayout
    ./run_finishing.sh --gds
    ;;

  *)
    echo "Usage: $0 {synth|pnr|gds|sim|wave|all}"
    exit 1
    ;;
esac