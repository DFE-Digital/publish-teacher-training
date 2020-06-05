module ServicePattern
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      private_class_method :new
    end
  end

  def call
    raise NotImplementedError("#call must be implemented")
  end

  module ClassMethods
    def call(**args)
      return new.call if args.empty?

      new(args).call
    end
  end
end
