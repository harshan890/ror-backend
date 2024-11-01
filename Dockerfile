# Uses in the official Ruby image with version 3.0.0
FROM ruby:3.0.0

# bundle Paths
ENV BUNDLE_PATH=/gems

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
nodejs \
postgresql-client \
libssl-dev \
libreadline-dev \
zlib1g-dev \
build-essential \
curl 

# Set the working directory is here
WORKDIR /myapp

# Copy the Gemfile and Gemfile.lock
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# Install Gems dependencies
RUN gem install bundler && bundle install

# Copy the application code
COPY . /myapp

#Define entrypoint and command
ENTRYPOINT ["bundle", "exec"]

# Execute the app
CMD ["rails", "server", "-b", "0.0.0.0"]
