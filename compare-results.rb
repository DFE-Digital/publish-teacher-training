require 'http'
require './config/environment'
require 'thread'

# Initialize counters and arrays for comparison
status_counts = { "/results" => Hash.new(0), "/v2/results" => Hash.new(0) }
non_200_urls = { "/results" => [], "/v2/results" => [] }
response_times = { "/results" => [], "/v2/results" => [] }
mutex = Mutex.new
MAX_THREADS = 4

# Graceful interruption
trap("SIGINT") do
  puts "\nInterrupted! Printing results before exit..."
  print_results("/results", status_counts, non_200_urls, response_times)
  print_results("/v2/results", status_counts, non_200_urls, response_times)
  exit
end

# Function to fetch a URL and record metrics
def fetch_url(url, endpoint, status_counts, non_200_urls, response_times, mutex)
  start_time = Time.now
  response = HTTP.get(url)
  elapsed_time = ((Time.now - start_time) * 1000).to_i # Convert to ms

  mutex.synchronize do
    # Record status count
    status_counts[endpoint][response.status.to_s] += 1

    # Record non-200 URLs
    non_200_urls[endpoint] << url if response.status != 200

    # Record response time
    response_times[endpoint] << elapsed_time
  end
rescue => e
  mutex.synchronize { non_200_urls[endpoint] << "#{url} (error: #{e.message})" }
end

# Function to print results
def print_results(endpoint, status_counts, non_200_urls, response_times)
  puts "\nResults for #{endpoint}:"
  puts "HTTP Status Summary:"
  status_counts[endpoint].each { |status, count| puts "#{status}: #{count}" }

  puts "\nNon-200 URLs:"
  non_200_urls[endpoint].each { |url| puts url }

  avg_time = response_times[endpoint].empty? ? "N/A" : response_times[endpoint].sum / response_times[endpoint].size
  puts "\nAverage Response Time: #{avg_time.round(2)} ms"
end

# Measure time taken for each endpoint
def process_urls(endpoint, urls, status_counts, non_200_urls, response_times, mutex)
  start_time = Time.now

  threads = []
  urls.each do |url|
    threads << Thread.new { fetch_url(url, endpoint, status_counts, non_200_urls, response_times, mutex) }
    # Limit number of active threads
    threads.select!(&:join) if threads.size >= MAX_THREADS
  end
  threads.each(&:join)

  end_time = Time.now
  total_time = end_time - start_time
  puts "\nTotal Time for #{endpoint}: #{total_time.round(2)} seconds"
end

# URLs for each endpoint
results_urls = 50.times.map { 'https://find.localhost/results' }
v2_results_urls = 50.times.map { 'https://find.localhost/v2/results' }

# Process URLs and measure times
process_urls("/results", results_urls, status_counts, non_200_urls, response_times, mutex)
process_urls("/v2/results", v2_results_urls, status_counts, non_200_urls, response_times, mutex)

# Print final benchmark results
print_results("/results", status_counts, non_200_urls, response_times)
print_results("/v2/results", status_counts, non_200_urls, response_times)

