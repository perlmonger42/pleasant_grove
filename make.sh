rm -f *.gem \
  && gem uninstall pleasant_grove \
  && gem build ./pleasant_grove.gemspec \
  && gem install --local pleasant_grove-*.gem
