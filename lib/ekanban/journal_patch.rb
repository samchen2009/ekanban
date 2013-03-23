module EKanban
  module Patches
    module JournalPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          scope :between, lambda {|from, to|
            to = (to.nil? or to.strip.empty?) ? DateTime.now : DateTime.strptime(to,"%Y-%m-%d")
            from = (from.nil? or from.strip.empty?) ? to - 1.weeks : DateTime.strptime(from,"%Y-%m-%d")
            {:conditions => ["created_on > ? and created_on < ?", from,to]}
          }

          scope :contains, lambda {|keyword|
            {:conditions => ["notes LIKE ?", "%#{keyword}%"]}
          }

          scope :issues, lambda {
            {:conditions => ["journalized_type = ?", "Issue"]}
          }
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end