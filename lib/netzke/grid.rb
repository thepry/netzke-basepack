require 'searchlogic'
module Netzke
  #
  # Functionality:
  # * data operations - get, post, delete, create
  # * column resize and move
  # * permissions
  # * sorting
  # * pagination
  # * properties and column configuration
  #
  class Grid < Base
    include GridJsBuilder
    include GridInterface

    # define connection points between client side and server side of Grid. See implementation of equally named methods in the GridInterface module.
    interface :get_data, :post_data, :delete_data, :resize_column, :move_column, :get_cb_choices

    def initial_config
      {
        :ext_config => {:properties => true, :column_filters => true},
        :layout_manager => "NetzkeLayout",
        :column_resize => true,
        :column_move => true
      }
    end

    def property_widgets
      [{
        :columns => {
          :widget_class_name => "Grid", 
          :data_class_name => column_manager_class_name, 
          :ext_config => {:title => false, :properties => false},
          :active => true
        }
      },{
        :general => {
          :widget_class_name => "PreferenceGrid", 
          :host_widget_name => @id_name, 
          :default_properties => available_permissions.map{ |k| {:name => "permissions.#{k}", :value => @permissions[k.to_sym]}},
          :ext_config => {:title => false}
        }
      }]
    end

    ## Data for properties grid
    def properties__columns__get_data(params = {})
      # add extra filter to show only the columns for the current grid (filtered by layout_id)
      layout_id = layout_manager_class.by_widget(id_name).id
      params[:filter] ||= {}
      params[:filter].merge!(:extra_conditions => {:field => 'layout_id', :data => {:type => 'numeric', :value => layout_id}})
      
      columns_widget = aggregatee_instance(:properties__columns)
      columns_widget.interface_get_data(params)
    end
    
    def properties__general__load_source(params = {})
      w = aggregatee_instance(:properties__general)
      w.interface_load_source(params)
    end
    


    protected
    
    def layout_manager_class
      config[:layout_manager] && config[:layout_manager].constantize
    end
    
    def column_manager_class_name
      "NetzkeGridColumn"
    end
    
    def column_manager_class
      column_manager_class_name.constantize
    rescue NameError
      nil
    end
    
    def available_permissions
      %w(read update create delete)
    end

    public

    # get columns from layout manager
    def get_columns
      @columns ||=
      if layout_manager_class && column_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= column_manager_class.create_layout_for_widget(self)
        layout.items_hash  # TODO: bad name!
      else
        Netzke::Column.default_columns_for_widget(self)
      end
    end
    
    def tools
      [{:id => 'refresh', :on => {:click => 'refreshClick'}}]
    end

    def actions
      [{
        :text => 'Add', :handler => 'add', :disabled => @pref['permissions.create'] == false
      },{
        :text => 'Edit', :handler => 'edit', :disabled => @pref['permissions.update'] == false
      },{
        :text => 'Delete', :handler => 'delete', :disabled => @pref['permissions.delete'] == false
      },{
        :text => 'Apply', :handler => 'submit', :disabled => @pref['permissions.update'] == false && @pref['permissions.create'] == false
      }]
    end

    

    # Uncomment to enable a menu duplicating the actions
    # def js_menus
    #   [{:text => "config.dataClassName".l, :menu => "config.actions".l}]
    # end
    
    # include ColumnOperations
    include PropertiesTool # it will load aggregation with name :properties into a modal window
  end
end