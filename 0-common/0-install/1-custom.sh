#!/usr/bin/env bash

# https://github.com/MarathonLabs/marathon/releases/
curl -L -s https://github.com/MarathonLabs/marathon/releases/download/0.8.1/marathon-0.8.1.zip > marathon.zip
unzip -q marathon.zip
export PATH=$PATH:$(pwd)/marathon-0.8.1/bin

marathon version
