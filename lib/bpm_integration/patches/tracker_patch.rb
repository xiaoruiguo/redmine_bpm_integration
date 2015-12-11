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
          self.process_definition && self.process_definition.is_active?
        end

        def process_active_version
          self.is_bpm_process? && self.process_definition.active_version
        end

      end

    end
  end
end
