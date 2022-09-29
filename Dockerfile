FROM ruby:3.1
ADD Gemfile      /opt/away-from-keyboard/Gemfile
ADD Gemfile.lock /opt/away-from-keyboard/Gemfile.lock

WORKDIR /opt/away-from-keyboard
RUN gem install bundler -N
RUN bundle install --deployment --without development,test -j4

ADD . /opt/away-from-keyboard

ENTRYPOINT ["bundle", "exec"]
CMD ["away-from-keyboard"]
