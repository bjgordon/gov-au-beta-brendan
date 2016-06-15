require "administrate/field/base"
include NodesHelper

class StateEnumField < Administrate::Field::Base
  def to_s
    data
  end

  def select_options
    NodesHelper.states.map do |state|
      [state, state]
    end
  end
end