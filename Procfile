web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb > log/unicorn.log 2>&1
worker: bundle exec rake environment resque:work QUEUE=* > log/resque.log 2>&1
clock: bundle exec rake environment resque:scheduler > log/resque_scheduler.log 2>&1
