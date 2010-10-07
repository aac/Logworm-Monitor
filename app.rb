require 'rubygems'
require 'sinatra'
require "logworm_amqp"

require 'mustache/sinatra'

Sinatra::register Mustache::Sinatra

set :mustache, {
  :views     => 'views/',
  :templates => 'views/'
}

def configuration
  @config ||= YAML.load_file("config.yml")
end

def extend_fields fields
  fields = [fields] unless fields.is_a? Array
  (fields + %w(_request_id _ts_utc)).compact.uniq
end

configure do
  @collections = configuration['collections']
  @collections.each do |c|
    c['fields'] ||= []
    c['fields'] = extend_fields(c['fields'])
  end
  set :collections, @collections
end

def tables
  lw_list_logs.map{|l| l['tablename'].intern}
end

def build_response xml, response_builder
  xml.response do
    response_builder.call
  end
end

def get_expiration_in_ms at
  exp = Time.parse(at)
  ms = exp.to_i * 1000 + exp.usec/1000 # 2 seconds in ms
end

get '/' do
  #render page *and* javascript
  @collections = options.collections
  mustache :index
end

get '/requests/:id' do |id|
  @id = id
  @results = {}
  tables.map do |t|
    res = lw_query(t, :conditions => ["\"_request_id\":\"#{id}\""])
    @results[t] = res['results']
  end

  @collections = options.collections
  mustache :show_request
end

def build_format_string summary
  format_string = summary[1..-1].map do |s|
    "var #{s} = request.find('#{s}');"
  end.join
  format_string << "sprintf(\"#{summary.first}\","
  format_string += summary[1..-1].map{|s| "#{s}.text()"}.join(",")
  format_string << ");"
end

get "/*" do |collection_name|
  content_type 'text/xml', :charset => 'utf-8'
  
  collection = options.collections.find{|c| c['name'] == collection_name}
  return nil if collection.nil?

  fields = collection['fields']

  res = lw_query(collection['table'], :fields => fields, :conditions => collection['conditions'])
  builder do |xml| 
    build_response(xml, Proc.new(){
                     xml.expiration get_expiration_in_ms(res['expires'])
                     xml.format_string(build_format_string(collection['summary'])) if collection['summary']
                     xml.tag!(collection_name) do
                       res['results'].each do |result|
                         xml.tag!(collection['singular']) do
                           fields.each{|f| xml.tag!(f, result[f])}
                         end
                       end
                     end
                   })
  end
end