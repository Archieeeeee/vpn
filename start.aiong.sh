#!/bin/bash
cd /data/projects/aiongrust && cargo run --release --bin quicserver && cargo run --release --bin ssngserver
