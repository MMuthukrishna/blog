#!/bin/bash
executable=`ls ./scripts/ | fzf`
./scripts/$executable
