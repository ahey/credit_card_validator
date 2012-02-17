class CreditCardValidator < ActiveModel::EachValidator
  autoload :CreditCard, 'credit_card_validator/credit_card'

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message]) unless CreditCard.new(value, options).valid?
  end
end
