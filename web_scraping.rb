require 'nokogiri'
require 'httparty'
require 'byebug'
require 'chartkick'

def get_repositories(topic)
    url = "https://github.com/topics/"
    url = url + topic
    unparse_page = HTTParty.get(url)
    parse_page = Nokogiri::HTML(unparse_page.body)
    repositories_text = parse_page.xpath('/html/body/div[4]/main/div[2]/div[2]/div/div[1]/h2').text
    repositories = repositories_text.gsub(/[^0-9]/, '')
    return repositories.to_i
end

def top_20_languages_repositories
    list_top_20_languages = Array ['JavaScript', 'Python', 'Java', 'PHP', 'C#', 'C++', 'C', 'GO', 'Swift', 'Ruby', 'R', 'SQL', 'MATLAB', 'Lua', 'Objective-C', 'Perl', 'Delphi/Object Pascal', 'Assembly language', 'Classic Visual Basic', 'Visual Basic']
    list_of_wrong_names = ['C#','C++','Delphi/Object Pascal','Classic Visual Basic','Visual Basic', 'Assembly language', 'GO']
    list_of_right_names = ['csharp','cpp','pascal','visual-basic','vbnet', 'assembly-language', 'golang']
    list_dict_languages = Array.new
    min_repositories = 99999999
    max_repositories = 0
    for language in list_top_20_languages do
        if list_of_wrong_names.include? language
            right_name = list_of_right_names[list_of_wrong_names.find_index(language)]
            repositories = get_repositories(right_name)
        else
            repositories = get_repositories(language)
        end

        #find the max and min repositories
        if repositories > max_repositories
            max_repositories = repositories
        end
        if repositories < min_repositories
            min_repositories = repositories
        end

        dict_language_repositories = {
            language: language,
            repositories: repositories
        }
        puts("#{language}: #{repositories}")
        list_dict_languages << dict_language_repositories
    end
    
    file = File.open("Resultados.txt", 'w')

    list_dict_languages.each do |dict_language|
        file.write(dict_language[:language] + ': ', dict_language[:repositories], "\n")
    end

    file.close unless file.nil?
    return list_dict_languages, min_repositories, max_repositories
end

def github_rating(list_dict_languages, min_repositories, max_repositories)
    difference_max_min = max_repositories - min_repositories
    list_dict_languages.each do |dict_language|
        github_rating = ((dict_language[:repositories] - min_repositories)/difference_max_min)*100
        dict_language.store(:github_rating, github_rating)
    end
    return list_dict_languages
end

list_dict_languages, min_repositories, max_repositories = top_20_languages_repositories()
list_dict_languages = github_rating(list_dict_languages, min_repositories, max_repositories)
print(min_repositories, "  " ,max_repositories)