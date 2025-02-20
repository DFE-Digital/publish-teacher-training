# frozen_string_literal: true

require 'net/http'
require 'benchmark'
require 'uri'

BASE_URL = 'https://find.localhost/results'
TOTAL_REQUESTS = 500
CONCURRENCY = 4

queue = Queue.new
TOTAL_REQUESTS.times { |i| queue << URI("#{BASE_URL}?page=#{i + 1}") }

success_count = 0
redirect_count = 0
error_count = 0
mutex = Mutex.new

time = Benchmark.realtime do
  threads = Array.new(CONCURRENCY) do
    Thread.new do
      until queue.empty?
        url = begin
          queue.pop(true)
        rescue StandardError
          nil
        end
        next unless url

        begin
          response = Net::HTTP.get_response(url)
          status = response.code.to_i

          mutex.synchronize do
            if status == 200
              success_count += 1
            else
              error_count += 1
            end
          end

          puts "Request to #{url} => Status: #{status}"
        rescue StandardError => e
          mutex.synchronize { error_count += 1 }
          puts "Request failed: #{e.message}"
        end
      end
    end
  end
  threads.each(&:join)
end

puts "\nTotal time: #{time.round(2)}s"
puts "200 responses: #{success_count}"
puts "308 redirects: #{redirect_count}"
puts "Errors: #{error_count}"
