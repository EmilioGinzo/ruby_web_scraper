# GitHub Top 20 Languages Analyzer
This Ruby script analyzes the popularity of programming languages on GitHub based on the number of repositories related to a specific topic. It provides insights into the distribution of repositories for the top 20 programming languages and generates a bar chart for visualization.

## Dependencies
 - Nokogiri: HTML, XML, SAX, and Reader parser.
 - HTTParty: Makes HTTP fun!
 - QuickChart: Provides an easy way to create charts using QuickChart API.
 - Launchy: Opens URLs in a web browser.
## How to Use
1. Install dependencies using Bundler:

`bundle install` 

2. Run the script with a specific topic to analyze. For example:

`ruby github_analyzer.rb <topic>`

Replace <topic> with the GitHub topic you want to analyze.

## Functionality
 - *get_repositories(topic)*: Retrieves the number of repositories for a given GitHub topic.
 - *top_20_languages_repositories()*: Gathers information about the top 20 programming languages and their repository counts.
 - *github_rating(list_dict_languages, min_repositories, max_repositories)*: Calculates GitHub rating based on repository counts.
 - *grafico(list_dict_languages)*: Generates a bar chart of the top 10 programming languages and opens it in the default web browser.
## Output
The script outputs a table displaying GitHub ratings, repository counts, and language names in descending order of popularity. Additionally, a bar chart is generated to visually represent the data.
