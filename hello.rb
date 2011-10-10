require 'rubygems'
require 'sinatra'
require 'anemone'

#show search form
get '/' do
  erb :index
end

#on submit get Anemone to crawl site looking for english words
post '/submit' do
  @common_english_words = params[:words].split(/,/)

  @submitvalue = params[:site]

  @html = "<table border=\"1\">"

  @start = Integer(params[:start])
  @end   = Integer(params[:end])
  @depth = Integer(params[:depth])
  count = 1

  Anemone.crawl(@submitvalue, :depth_limit => @depth) do |anemone|
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
          @html = @html + "<td>Found word:'" + result.to_s  + "'</td>"
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