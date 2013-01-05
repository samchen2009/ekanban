class KanbanCardJournalDetail < ActiveRecord::Base
	belongs_to :journal, :class_name => :KanbanCardJournal
end