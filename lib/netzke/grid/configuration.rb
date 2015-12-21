module Netzke
  module Grid
    module Configuration # WTF: naming it Config causes troubles in 1.9.3
      def bbar
        config.has_key?(:bbar) ? config[:bbar] : default_bbar
      end

      def default_bbar
        [].tap do |bbar|
          unless config.read_only
            bbar << :add << :edit
            bbar << :apply if config.edit_inline
            bbar << :delete
          end
          bbar << :search
        end
      end

      def context_menu
        config.has_key?(:context_menu) ? config.context_menu : default_context_menu
      end

      # Override to change the default context menu
      def default_context_menu
        [].tap do |menu|
          unless config.read_only
            menu << :edit << :delete
          end
        end
      end

      def tools
        config.has_key?(:tools) ? config.tools : default_tools
      end

      def default_tools
        [{ type: :refresh, handler: f(:handle_refresh_tool) }]
      end

      def configure_client(c)
        super

        c.title = c.title || self.class.client_class_config.properties[:title] || model_class.name.pluralize
        c.columns = {items: js_columns}
        c.columns_order = columns_order
        c.pri = model_adapter.primary_key
        if c.default_filters
          populate_columns_with_filters(c)
        end
      end

      private

      def validate_config(c)
        raise ArgumentError, "Grid requires a model" if c.model.nil?
        c.paging = true if c.edit_inline
        c.tools = tools
        c.bbar = bbar
        c.context_menu = context_menu
        super
      end
    end
  end
end
