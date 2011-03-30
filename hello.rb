require 'rubygems'
require 'sinatra'
require 'anemone'

get '/' do
  erb :index
end

post '/submit' do
  @common_english_words = ['the','of','to','and','a','in','is','it','you','that','he','was','for','on','are','with','as','I','his','they','be','at','one','have','this','from','or','had','by','hot','but','some','what','there','we','can','out','other','were','all','your','when','up','use','word','how','said','an','each','she']

  @submitvalue = params[:site]

  @html = "<table border=\"1\">"

  @start = Integer(params[:start])
  @end   = Integer(params[:end])
  count = 1

  Anemone.crawl(@submitvalue) do |anemone|
    anemone.on_every_page do |crawl_page|
      puts "crawl_page: #{crawl_page.url}"
      if (count <= @end && count >= @start)
        puts "in"
        count = count+1
        @html = @html + "<tr>"

        result = nil

        #remove script
        body = crawl_page.doc
        if ( !body.nil? )
          body.search('//script').each do |node|
            node.remove
          end
          result = string_contains_words(body.text, @common_english_words)
        end

        if result.nil?
          @html = @html + "<td>OK</td>"
        else
          @html = @html + "<td>NOT OK found '" + result.to_s  + "'</td>"
        end

        @html = @html + "<td>#{crawl_page.url}</td>"
        @html = @html + "</tr>"
      end
    end
  end

  @html = @html + "</table>"

  erb :submit
end



def string_contains_words(string, array)
  union = array.inject([])  do |result, element|
    result << Regexp.new('\b' + element + '\b', Regexp::IGNORECASE )
  end
  regexp = Regexp.union(union)
  string.match regexp
end