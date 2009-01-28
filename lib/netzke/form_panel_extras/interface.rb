module Netzke
  module FormPanelExtras
    module Interface
      def submit(params)
        params.delete(:authenticity_token)
        params.delete(:controller)
        params.delete(:action)
        book = Book.find(params[:id])
        if book.nil?
          book = Book.create(params)
        else
          book.update_attributes(params)
        end
      rescue ActiveRecord::UnknownAttributeError # unknown attributes get ignored
        book.save
        [book.to_array(get_fields)].to_json
      end

      def load(params)
        logger.debug { "!!! params: #{params.inspect}" }
        klass = config[:data_class_name].constantize
        case params[:neighbour]
        when "previous" then book = klass.previous(params[:id])
        when "next"     then book = klass.next(params[:id])
        else                 book = klass.find(params[:id])
        end
        [book && book.to_array(get_fields)].to_json
      end
    end
  end
end