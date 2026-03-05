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
    PROGRAM=${2:-helloworld.hex}
    cd sw
    make all
    cd ../verilator
    ./run_verilator.sh --build --run ../sw/bin/$PROGRAM
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
    echo "Usage: $0 {synth|pnr|gds|sim|all}"
    exit 1
    ;;
esac