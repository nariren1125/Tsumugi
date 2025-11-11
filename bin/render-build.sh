#!/usr/bin/env bash
set -o errexit
echo "==== [Render Build Script Start] ===="

bundle install

# Node/Tailwind系依存がある場合のみ
if [ -f package.json ]; then
  yarn install --frozen-lockfile || yarn install
fi

# アセットのプリコンパイル
bundle exec rails assets:precompile

# DBマイグレーション
bundle exec rails db:migrate

echo "==== [Render Build Script Done] ===="
