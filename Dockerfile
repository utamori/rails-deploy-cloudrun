# Docker Hubの公式Rubyイメージを利用します
# https://hub.docker.com/_/ruby

FROM ruby:3.0.2 AS dev
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
# コンテナイメージにアプリコードをコピーします
COPY . /app
ENV RAILS_SERVE_STATIC_FILES=true
# ログをCloud Runで捕捉できるように、標準出力に出します
ENV RAILS_LOG_TO_STDOUT=true
EXPOSE 8080
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]

FROM ruby:3.0.2 AS prod
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install
# コンテナイメージにアプリコードをコピーします
COPY . /app
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
# ログをCloud Runで捕捉できるように、標準出力に出します
ENV RAILS_LOG_TO_STDOUT=true
# [START cloudrun_rails_dockerfile_key]
ARG MASTER_KEY
ENV RAILS_MASTER_KEY=${MASTER_KEY}
# [END cloudrun_rails_dockerfile_key]
# マスターキーを用いて、アセットをプレビルドします
RUN bundle exec rake assets:precompile
EXPOSE 8080
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
