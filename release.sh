#!/bin/sh

echo "Setting up gem credentials..."
set +x
mkdir -p ~/.gem

cat << EOF > ~/.gem/credentials
---
:github: Bearer ${WRITE_GHCR_TOKEN}
EOF

chmod 0600 ~/.gem/credentials
set -x

gem build danger-checkstyle_merge.gemspec

gem push --key github --host https://rubygems.pkg.github.com/pnlinh-it ./*.gem
