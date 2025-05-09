#!/bin/bash

echo "📊 Analyzing log file..."

# Total number of requests
total=$(wc -l < access.log)
echo "Total requests: $total"

# Number of GET and POST requests
get=$(grep 'GET' access.log | wc -l)
post=$(grep 'POST' access.log | wc -l)
echo "GET requests: $get"
echo "POST requests: $post"

# Unique IPs
unique_ips=$(awk '{print $1}' access.log | sort | uniq | wc -l)
echo "Unique IP addresses: $unique_ips"

# GET and POST requests per IP (top 5)
echo -e "\nTop 5 IPs by GET/POST:"
awk '{print $1, $6}' access.log | cut -d\" -f2 | awk '{print $1}' | paste -d' ' <(awk '{print $1}' access.log) - | sort | uniq -c | sort -nr | head -5

# Failed requests (status 4xx or 5xx)
failures=$(awk '$9 ~ /^4|^5/ {count++} END {print count}' access.log)
fail_percent=$(awk -v f=$failures -v t=$total 'BEGIN {printf "%.2f", (f/t)*100}')
echo -e "\nFailed requests: $failures ($fail_percent%)"

# Most active IP
top_ip=$(awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -1)
echo "Most active IP: $top_ip"

# Average requests per day
days=$(awk '{print $4}' access.log | cut -d: -f1 | tr -d [ | sort | uniq | wc -l)
average_per_day=$(awk -v t=$total -v d=$days 'BEGIN {printf "%.2f", t/d}')
echo "Average requests per day: $average_per_day"

# Days with most failures
echo -e "\nTop days with failed requests:"
awk '$9 ~ /^4|^5/ {split($4, a, ":"); gsub("\\[", "", a[1]); print a[1]}' access.log | sort | uniq -c | sort -nr | head -5

# Requests per hour
echo -e "\nRequests per hour:"
awk '{split($4, a, ":"); print a[2]":00"}' access.log | sort | uniq -c | sort -n

# Status code breakdown
echo -e "\nStatus code breakdown:"
awk '{print $9}' access.log | sort | uniq -c | sort -nr

# Most active users by method
echo -e "\nTop 3 IPs by GET requests:"
grep 'GET' access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -3

echo -e "\nTop 3 IPs by POST requests:"
grep 'POST' access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -3

# Failure patterns by hour
echo -e "\nFailure patterns by hour:"
awk '$9 ~ /^4|^5/ {split($4, a, ":"); print a[2]":00"}' access.log | sort | uniq -c | sort -nr | head -5

echo -e "\n✅ Log analysis complete."
