#!/bin/bash
cd /data/projects/aiongrust && cargo build --release --bin quicserver && cargo build --release --bin ssngserver
