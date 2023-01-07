#!/bin/bash

echo "Setting up gem credentials..."
set +x
mkdir -p ~/.gem

cat << EOF > ~/.gem/credentials
---
:rubygems_api_key: ${RUBYGEMS_API_KEY}
EOF

chmod 0600 ~/.gem/credentials
set -x

gem_name=$(ruby -r rubygems -e "puts Gem::Specification::load('$(ls *.gemspec)').name")
gem_version=$(ruby -r rubygems -e "puts Gem::Specification::load('$(ls *.gemspec)').version")

echo "::set-output name=gem_name::$gem_name"
echo "::set-output name=gem_version::$gem_version"

git config user.email "${GIT_EMAIL:-automated@example.com}"
git config user.name "${GIT_NAME:-Automated Release}"

echo "Installing dependencies..."
gem update bundler
bundle install

echo "Running gem release task..."
rake build
gem push pkg/${gem_name}-${gem_version}.gem
