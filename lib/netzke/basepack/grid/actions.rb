module Netzke
  module Basepack
    class Grid < Netzke::Base
      module Actions
        extend ActiveSupport::Concern

        included do
          action :add do |a|
            a.disabled = config[:prohibit_create]
            a.icon = :add
          end

          action :edit do |a|
            a.disabled = true
            a.icon = :table_edit
          end

          action :del do |a|
            a.disabled = true
            a.icon = :table_row_delete
          end

          action :apply do |a|
            a.disabled = config[:prohibit_update] && config[:prohibit_create]
            a.icon = :tick
          end

          action :search do |a|
            a.enable_toggle = true
            a.icon = :find
          end
        end
      end
    end
  end
end
