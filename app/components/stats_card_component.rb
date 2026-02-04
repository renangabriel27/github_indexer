class StatsCardComponent < ViewComponent::Base
  def initialize(label:, value:, icon: nil)
    @label = label
    @value = value
    @icon = icon
  end
end
