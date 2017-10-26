#!/bin/bash
set -e
jekyll serve --limit_posts 20 --watch --host 0.0.0.0 --port 3000 --open-url
