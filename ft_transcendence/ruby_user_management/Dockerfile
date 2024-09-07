FROM ruby:3.1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

# not sur for this line, dunno
RUN gem install rerun

COPY . .

CMD ["rerun", "--background", "--dir", "/app", "ruby", "app.rb"]
