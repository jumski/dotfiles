FROM alpine:3.15.0

RUN apk add --no-cache \
  g++ \
  gcc \
  git \
  make \
  ruby \
  ruby-dev \
  zlib-dev \
  && gem install \
    solargraph solargraph-rails solargraph-standardrb

CMD [ "/usr/bin/solargraph", "stdio" ]
