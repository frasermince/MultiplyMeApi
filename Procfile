web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake environment resque:work QUEUE=*
clock: bundle exec rake environment resque:scheduler