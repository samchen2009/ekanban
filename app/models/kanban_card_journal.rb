class KanbanCardJournal < ActiveRecord::Base

	belongs_to :kanban_card
	belongs_to :issue_journal, :class_name => :Journal
	has_many :details, :foreign_key => "journal_id", :class_name => :KanbanCardJournalDetail, :dependent => :delete_all

	def self.build(old_card,new_card,issue_journal)
		#new card
		if old_card.nil?
			old_card = KanbanCard.new(:developer_id => 0, :verifier_id => 0, :kanban_pane_id => 0)
		end
		issue_journal_id = (issue_journal.nil?) ? 0 : issue_journal.id
		kanban_journal = new_card.kanban_card_journals.create(:kanban_card_id => new_card.id, :issue_journal_id => issue_journal_id)
        kanban_journal.details.create(:prop_key => "kanban_pane_id",
                       :old_value => old_card.kanban_pane_id,
                       :new_value => new_card.kanban_pane_id) if old_card.kanban_pane_id != new_card.kanban_pane_id
        kanban_journal.details.create(:prop_key => "developer_id",
                       :old_value => old_card.developer_id,
                       :new_value => new_card.developer_id) if old_card.developer_id != new_card.developer_id
        kanban_journal.details.create(:prop_key => "verifier_id",
                       :old_value => old_card.verifier_id,
                       :new_value => new_card.verifier_id) if old_card.verifier_id != new_card.verifier_id
	end
end