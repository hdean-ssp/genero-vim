#!/bin/bash
# Run SVN blame and revert tests

echo "Running SVN Blame and Revert Tests..."
echo "======================================"

# Run vim in batch mode
vim -u NONE -N -e -s -S test/test_svn_blame_revert.vim -c 'quit' 2>&1

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✓ All tests passed!"
else
    echo "✗ Tests failed with exit code: $exit_code"
fi

exit $exit_code
