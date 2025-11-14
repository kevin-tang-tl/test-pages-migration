FROM ruby:3.3
WORKDIR /usr/src/app
RUN gem install bundler
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundler install
ENTRYPOINT ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]