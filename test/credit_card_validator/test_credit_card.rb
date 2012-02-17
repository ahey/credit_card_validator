require "test_helper"

class CreditCardValidator::TestCreditCard < Test::Unit::TestCase
  def test_recognize_card_type
    assert_equal 'visa', validator('4111111111111111').card_type
    assert_equal 'master_card', validator('5555555555554444').card_type
    assert_equal 'diners_club', validator('30569309025904').card_type
    assert_equal 'amex', validator('371449635398431').card_type
    assert_equal 'discover', validator('6011000990139424').card_type
    assert_equal 'maestro', validator('6759671431256542').card_type
  end

  def test_detect_specific_types
    assert validator('4111111111111111').visa?
    refute validator('5555555555554444').visa?
    refute validator('30569309025904').visa?
    refute validator('371449635398431').visa?
    refute validator('6011000990139424').visa?
    assert validator('5555555555554444').master_card?
    assert validator('30569309025904').diners_club?
    assert validator('371449635398431').amex?
    assert validator('6011000990139424').discover?
    assert validator('6759671431256542').maestro?
    refute validator('5555555555554444').maestro?
    refute validator('30569309025904').maestro?
  end

  def  test_luhn_verification
    assert validator('49927398716').verify_luhn
    assert validator('049927398716').verify_luhn
    assert validator('0049927398716').verify_luhn
    refute validator('49927398715').verify_luhn
    refute validator('49927398717').verify_luhn
  end

  def test_ignore_whitespace
    assert_equal '4111111111111111', validator('4111 1111 1111 1111 ').number

    assert_equal 'visa', validator('4111 1111 1111 1111 ').card_type
    assert_equal 'visa', validator(' 4111 1111 1111 1111 ').card_type
    assert_equal 'visa', validator("\n4111 1111\t 1111 1111 ").card_type
    assert validator(' 004 992739 87 16').verify_luhn
    assert validator('601 11111111111 17').test_number?
  end

  def test_should_recognize_test_numbers
     %w(
    378282246310005 371449635398431 378734493671000
    30569309025904 38520000023237 6011111111111117
    6011000990139424 5555555555554444 5105105105105100
    4111111111111111 4012888888881881 4222222222222
  ).each do |n|
      assert validator(n).test_number?
    end

    refute validator("1234").test_number?
  end

  def test_test_number_validity_cases
    refute validator('378282246310005').valid?
    assert validator('378282246310005', :test_numbers_are_valid => true).valid?
  end

  def test_is_allowed_card_type
    assert validator('378282246310005').allowed_card_type?
    assert validator('4012888888881881', :allowed_card_types => [:visa]).allowed_card_type?
    refute validator('378282246310005', :allowed_card_types => [:visa]).allowed_card_type?
  end

  def test_card_type_allowance
    assert validator('378282246310005', :test_numbers_are_valid => true).valid?
    assert validator('4012888888881881', :allowed_card_types => [:visa], :test_numbers_are_valid => true).valid?
    refute validator('378282246310005', :allowed_card_types => [:visa], :test_numbers_are_valid => true).valid?
  end

  def validator(number, options = {})
    CreditCardValidator::CreditCard.new(number, options)
  end
end
