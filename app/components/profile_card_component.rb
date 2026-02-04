class ProfileCardComponent < ViewComponent::Base
  def initialize(profile:)
    @profile = profile
  end
end
