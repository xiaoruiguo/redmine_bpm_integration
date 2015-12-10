module BpmIntegration
  module Patches
    module TrackerPatch

      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        base.class_eval do

          has_one :tracker_process_definition, { class_name: 'BpmIntegration::TrackerProcessDefinition',
                                                  dependent: :destroy }
          has_one :process_definition, { class_name: 'BpmIntegration::ProcessDefinition',
                                          through: :tracker_process_definition }

        end
      end

      module InstanceMethods

        def is_bpm_process?
          !self.process_definition.nil?
        end

      end

    end
  end
end
