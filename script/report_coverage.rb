# frozen_string_literal: true

require 'json'

report = JSON.parse(File.read('coverage/coverage.json'))
lines = report.dig('total', 'lines')
branches = report.dig('total', 'branches')
files = report.fetch('coverage').map do |path, info|
  {
    :path => path,
    :missed => info['missed_lines'].to_i,
    :line_percent => info['lines_covered_percent'].to_f,
    :branch_percent => info['branches_covered_percent'].to_f,
    :total => info['total_lines'].to_i
  }
end
gaps = files.reject { |file| file[:total].zero? }
            .sort_by { |file| [-file[:missed], file[:line_percent]] }
            .first(10)

def percent(stat)
  format(
    '%<percent>.2f%% (%<covered>d/%<total>d)',
    :percent => stat['percent'],
    :covered => stat['covered'],
    :total => stat['total']
  )
end

body = +<<~MARKDOWN
  ## Coverage

  Line coverage: #{percent(lines)}

  Branch coverage: #{percent(branches)}

  This report is informational. A low percentage does not fail the build.

  ### Largest line gaps

  | File | Line | Branch | Missed lines |
  | --- | --- | --- | --- |
MARKDOWN
gaps.each do |file|
  body << "| `#{file[:path]}` | #{format('%<percent>.1f%%', :percent => file[:line_percent])} | " \
          "#{format('%<percent>.1f%%', :percent => file[:branch_percent])} | #{file[:missed]} |\n"
end

destination = ENV.fetch('GITHUB_STEP_SUMMARY', nil)
if destination
  File.write(destination, body)
else
  puts body
end
