#!/bin/bash

solc-select use ${SOLC_VERSION}
slither "$@"
