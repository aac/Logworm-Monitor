class ShowRequest < Mustache
  def sections
    @collections.map do |c|
      results = @results[c['table'].intern]
      result = results.first
      
      fields = []

      unless (c['fields'].nil? || c['fields'].empty?)
        fields = c['fields']
      else
        fields = result.keys
      end

      list_items = fields.map{|f| [f, hash_to_template(result[f])]}.map{|a| "<li>#{a.first}: #{a.last}</li>"}.join
      list_items = "<ul>#{list_items}</ul>" unless list_items.empty?
      #result is a hash
      {
        :name => c['singular'],
        :body => list_items
      }
    end
  end
  
  def title
    @title
  end

  private

  def hash_to_template h
    return h unless h.is_a? Hash
    return nil if h.empty?

    res = "<ul>"
    h.each_pair do |k, v|
      res << "<li>#{k}: #{hash_to_template(v)}</li>"
    end
    res << "</ul>"
  end
end
