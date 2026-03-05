#!/bin/sh
# Copyright (c) 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

RUNDIR=/tmp/runtime-$(id -u)
mkdir -p "$RUNDIR"

env UID="$(id -u)" GID="$(id -g)" docker compose pull pulp-docker
env UID="$(id -u)" GID="$(id -g)" docker compose up -d pulp-docker
env UID="$(id -u)" GID="$(id -g)" docker compose exec -it pulp-docker bash