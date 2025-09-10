#!/bin/bash

echo "running_test"

echo "total test: 1:"
./bitops <<EOF
5
countbit
EOF

echo "total test: 2:"
./bitops <<EOF
16
pow_2
EOF

echo "total test: 3:"
./bitops <<EOF
7
reverse
EOF

echo "total test: 4:"
./bitops <<EOF
8
set
3
EOF

echo "total test: 5:"
./bitops <<EOF
15
clear
2
EOF

echo "total test: 6:"
./bitops <<EOF
10
toggle
1
EOF

echo "total tests run are 6"

