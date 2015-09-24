module BpmIntegration
  module Patches
    module CustomFieldPatch

      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do

          has_many :form_fields, class_name: 'BpmIntegration::FormField'

          scope :bpm_processes, -> { joins(:tracker_process_definition) }

        end
      end

      module InstanceMethods

        def is_bpm_process?
          !self.tracker_process_definition.nil?
        end

      end

    end
  end
end
