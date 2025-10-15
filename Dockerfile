# syntax = docker/dockerfile:1

# Base image with Ruby 3.4.5
FROM docker.io/library/ruby:3.4.5-slim AS base

# Set working directory
WORKDIR /app

# Install dependencies needed for building gems and running the app
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Update RubyGems and install bundler
RUN gem update --system --no-document && \
    gem install -N bundler

# Build stage - installs dependencies and builds docs
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems (including from GitHub)
RUN bundle install

# Copy application code
COPY . .

# Generate GraphQL documentation
RUN bundle exec rake docs

# Final stage - minimal runtime image
FROM base

# Create user for running the app
RUN useradd ruby --home /app --shell /bin/bash && \
    chown -R ruby:ruby /app

# Copy installed gems from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copy application code and generated docs from build stage
COPY --from=build --chown=ruby:ruby /app /app

# Switch to non-root user
USER ruby:ruby

# Expose port
EXPOSE 8080

# Set environment variables
ENV RACK_ENV="production" \
    PORT="8080"

# Start the application
CMD ["bundle", "exec", "puma", "-p", "8080"]
