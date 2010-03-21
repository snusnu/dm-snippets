# Don't use this in production code! Extending lots of objects during runtime
# will have a negative impact on performance/memory because ruby clears out
# the method cache.
#
# A better approach to implement this is to write a custom DataMapper::Type that
# delegates all methods to the underlying BigDecimal and just overwrites #to_s
# Why on earth haven't I thought about that before! Thx dkubb :P 
#
#
# When this module is activated, it will round all BigDecimal property values
# to their specified :scale option when BigDecimal#to_s is called. This is
# achieved by overwriting all property readers for properties of type BigDecimal
# and then implementing the #to_s method with "round to scale" semantics on the
# metaclass of the BigDecimal instance to be returned. This way we can make sure
# that any occurrences of BigDecimals in web application views will always be
# displayed properly according to their specified :scale option. It can be argued
# that this functionality would be best kept in helpers, but the situation at hand
# didn't allow that since there are simply too many occurrences and we needed a
# quick fix.
#
# For the lazy, the module can be activated once and for all by e.g putting this into 
# the merb after_app_loads block or similar places in other webframeworks.
#
#   DataMapper::Model.descendants.each do |model|
#     model.extend BigDecimalFormatting
#     model.format_big_decimals
#   end
#
# Of course, it's cleaner to just activate it by extending it into relevant models and
# calling the #format_big_decimals method explicitly *after* declaring all properties
#
# In the process of coming up with this solution I was surprised to see that it's
# neither possible to redefine BigDecimal#to_s by implementing it on a BigDecimal metaclass,
# nor by including a module that overwrites #to_s in BigDecimal. I have no clue about the
# latter, but the former issue always raised a Type error, saying
#
#   TypeError: can't define singleton method "to_s" for BigDecimal
#
# However, it seems the method is still attached to the metaclass, so either just
# swallowing the TypeError, or overwriting #singletion_method_added seem to do the trick
# This was definitely surprising behavior!
#

class BigDecimal
  def singleton_method_added(id)
  end
end

module BigDecimalFormatting
 
  def format_big_decimals
    properties.reject { |prop| prop.type != BigDecimal }.each do |prop|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{prop.name}
          result = attribute_get(#{prop.name.inspect})
          if result && result.is_a?(BigDecimal)
            def result.to_s(s = 'F')
              round(#{prop.scale}).to_f.to_s
            end
          end
          result
        end
      RUBY
    end
  end
 
end

class Quote

  include DataMapper::Resource
  extend BigDecimalFormatting

  property :id,          Serial
  property :price,       BigDecimal, :precision => 20, :scale => 2
  property :click_price, BigDecimal, :precision =>  8, :scale => 5

  format_big_decimals

end

DataMapper.auto_migrate!


# ----------------------------------------------------------------
#                         DEMO APPLICATION
# ----------------------------------------------------------------

get '/quotes' do
  erb :index
end

get '/quotes/new' do
  @quote = Quote.new
  erb :new
end

post '/quotes' do
  @quote = Quote.create(params[:quote])
  redirect '/quotes'
end

get '/quotes/:id' do
  @quote = Quote.get(params[:id])
  erb :show
end

get '/quotes/:id/edit' do
  @quote = Quote.get(params[:id])
  erb :edit
end

put '/quotes/:id' do
  @quote = Quote.get(params[:id])
  halt 404 unless @quote
  @quote.update(params[:quote])
  redirect '/quotes'
end

delete '/quotes/:id' do
  @quote = Quote.get(params[:id])
  #halt 404 unless @quote
  @quote.destroy
  redirect '/quotes'
end

__END__

@@ layout
<!DOCTYPE html>
<html>
  <head><title>BigDecimal Standalone Demo</title></head>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
<h3>Listing Quotes</h3>
<table>
  <tr>
    <th>Id</th>
    <th>Price</th>
    <th>ClickPrice</th>
  </tr>
<% Quote.all.each do |quote| %>
  <tr>
    <td><%= quote.id %></td>
    <td><%= quote.price %></td>
    <td><%= quote.click_price %></td>
    <td><a href="/quotes/<%= quote.id%>/edit">Edit</a></td>
    <td>
      <form action="/quotes/<%= quote.id %>" method="post">
        <input type="hidden" name="_method" value="delete" />
        <button type="submit">Delete</button>
      </form>
    </td>
  </tr>
<% end %>
</table>
<a href="/quotes/new">New Quote</a>

@@ new
<h3>New Quote</h3>
<form action="/quotes" method="post">
  <label for="quote[price]">Price</label>
  <input id="quote_price" name="quote[price]" value="<%= @quote.price %>">
  <label for="quote[click_price]">ClickPrice</label>
  <input id="quote_click_price" name="quote[click_price]" value="<%= @quote.click_price %>">
  <input type="submit">
</form>

@@ edit
<h3>Edit Quote</h3>
<form action="/quotes/<%= @quote.id %>" method="post">
  <input type="hidden" name="_method" value="put" />
  <label for="quote[price]">Price</label>
  <input id="quote_price" name="quote[price]" value="<%= @quote.price %>">
  <label for="quote[click_price]">ClickPrice</label>
  <input id="quote_click_price" name="quote[click_price]" value="<%= @quote.click_price %>">
  <input type="submit" />
</form>

@@ show
<h3>Show Quote</h3>
<label for="quote[price]">Price</label>
<p><%= @quote.price %></p>
<label for="quote[click_price]">ClickPrice</label>
<p><%= @quote.click_price %></p>
