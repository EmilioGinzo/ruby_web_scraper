require 'nokogiri'
require 'httparty'
require 'byebug'
require 'quickchart' #grafico
require 'launchy' #abrir urls en navegador

def get_repositories(topic)
    url = "https://github.com/topics/#{topic}"
    dict_topics = {}
    today = DateTime.now
    max_date = today - 30

    for page in 1..10 do
        puts("conectando a #{url}?o=desc&s=updated&page=#{page}")
        pagination_url = "#{url}?o=desc&s=updated&page=#{page}"
        unparse_page = HTTParty.get(pagination_url)
        parse_page = Nokogiri::HTML(unparse_page.body)
        tiempo = parse_page.css('ul.d-flex.f6.list-style-none.color-fg-muted')
        date_str = tiempo.first.css('relative-time')[0][:datetime]
        date_created = Date.parse date_str
        if date_created < max_date
            return dict_topics
        end
        topics_listing = parse_page.css('div.d-flex.flex-wrap.border-bottom.color-border-muted.px-3.pt-2.pb-2')
        topics_listing.each do |topics|
            topics.text.split.each do |topic|
                if dict_topics.key?(topic)
                    dict_topics[topic] += 1
                else
                    dict_topics[topic] = 1
                end
            end
        end
    end

    return dict_topics
end

#source: https://quickchart.io/documentation/#library-ruby
def grafico(sorted_dict)
    array_nombres = []
    array_nro_apariciones = []

    #cargo los elementos de sorted_dict en arrays para graficar
    cont=0
    sorted_dict.each do |topic|
        cont+=1
        array_nombres.push(topic[0])
        array_nro_apariciones.push(topic[1])
        
        if cont==20
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
            label: "Top 20 Topics",
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


dict_topics = get_repositories("bot")
sorted_dict = dict_topics.sort_by { |k, v| v}.reverse!
sorted_dict.each do |topic|
    puts("#{topic[0]}: #{topic[1]}")
end
grafico(sorted_dict)