#!/bin/bash

# Run preservation property tests
vim -u NONE -N -es \
  -c "set nocompatible" \
  -c "source /root/workspace/test/test_preservation_properties.vim" \
  2>&1

exit $?
