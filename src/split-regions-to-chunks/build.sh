#!/bin/bash

(
  cd "$(dirname "$0")"
  g++ -I../libminecraft-file/include -I../hwm.task main.cpp -lstdc++fs -pthread -o ../../split-regions-to-chunks
)
