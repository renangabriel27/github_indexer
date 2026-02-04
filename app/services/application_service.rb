class ApplicationService
  include Dry::Monads[:result]

  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def call
    raise NotImplementedError
  end
end