FROM ruby:3.1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

# hot reload
RUN gem install guard

COPY . .

CMD ["sh", "-c", "ruby config/dbmanage.rb && rerun --background --dir /app ruby app.rb"]

