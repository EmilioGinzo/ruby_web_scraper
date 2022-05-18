require 'nokogiri'
require 'httparty'
require 'byebug'
require 'quickchart' #grafico
require 'launchy' #abrir urls en navegador

def get_repositories(topic)
    url = "https://github.com/topics/"
    url = url + topic
    puts("connecting to #{url}")
    unparse_page = HTTParty.get(url)
    parse_page = Nokogiri::HTML(unparse_page.body)
    repositories_text = parse_page.xpath('/html/body/div[4]/main/div[2]/div[2]/div/div[1]/h2').text
    repositories = repositories_text.gsub(/[^0-9]/, '')
    return repositories.to_i
end

def top_20_languages_repositories
    list_top_20_languages = Array ['JavaScript', 'Python', 'Java', 'PHP', 'Csharp', 'C++', 'C', 'GO', 'Swift', 'Ruby', 'R', 'SQL', 'MATLAB', 'Lua', 'Objective-C', 'Perl', 'Delphi/Object Pascal', 'Assembly language', 'Classic Visual Basic', 'Visual Basic']
    list_of_wrong_names = ['Csharp','C++','Delphi/Object Pascal','Classic Visual Basic','Visual Basic', 'Assembly language', 'GO']
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
        #puts("#{language}: #{repositories}")
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
        calculated_rating = ((dict_language[:repositories].to_f - min_repositories.to_f)/difference_max_min)*100
        dict_language.store(:github_rating, calculated_rating)
    end
    return list_dict_languages
end

#source: https://quickchart.io/documentation/#library-ruby
def grafico(list_dict_languages)
    array_nombres = []
    array_nro_apariciones = []

    #cargo los elementos de list_dict_languages en arrays para graficar
    cont=0
    list_dict_languages.each do |dict_language|
        cont+=1
        array_nombres.push(dict_language[:language])
        array_nro_apariciones.push(dict_language[:repositories])
        
        if cont==10
            break
        end
    end

    #grafico
    qc = QuickChart.new(
        {
        type: "bar",
        data: {
            labels: array_nombres,
            datasets: [{
            label: "Lenguajes",
            data: array_nro_apariciones
            }]
        }
        },
        width: 600,
        height: 300,
        device_pixel_ratio: 2.0,
    )
    
    # Print the chart URL
    #print("para ver el gráfico por favor acceda a:",qc.get_url)
    Launchy.open(qc.get_url)
end




#cargar los nombres de los lenguajes y el numero de apariciones
list_dict_languages, min_repositories, max_repositories = top_20_languages_repositories()

# calcular el rating github
list_dict_languages = github_rating(list_dict_languages, min_repositories, max_repositories)

#ordeno en forma descendiente por rating
#https://stackoverflow.com/questions/3154111/
list_dict_languages.sort_by! { |k| k[:repositories]}.reverse!

#imprimir en pantalla
list_dict_languages.each do |language|
    printf("%20s%20s%25s\n",language[:github_rating],language[:repositories],language[:language])
end

#graficar por orden de aparicion y mostrar en el navegador
grafico(list_dict_languages)


