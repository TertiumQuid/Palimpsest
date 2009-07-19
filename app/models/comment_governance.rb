class CommentGovernance < ActiveRecord::Base
    class << self
        def options_for_select
            CommentGovernance.find(:all).collect {|g| [ g.name, g.id ] }
        end
    end
end
