module BpmIntegration
  module Patches
    module IssuePatch

      def self.included(base) # :nodoc
        base.class_eval do
          has_one :human_task_issue, class_name: 'BpmIntegration::HumanTaskIssue', :dependent => :destroy
          scope :human_task, -> { joins(:human_task_issue) }
        end
      end
    end
  end
end
