class StripeService
  def initialize
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
  end

  def self.create_stripe_customer_card(user, params)
    begin
      customer = find_or_create_customer(user)
      token = create_card_token(params)
      return token if token.is_a?(String)

      card = Stripe::Customer.create_source(customer.id, source: token.id)

      if card.present?
        user.user_cards.create!(
          name: "#{params[:first_name]} #{params[:last_name]}",
          country: params[:country],
          expiry_month: params[:exp_month],
          expiry_year: params[:exp_year],
          cvc: params[:cvc],
          card_id: card.id,
          brand: card.brand,
          last_four: card.last4.to_i,
          number: params[:number].to_i
        )
      end
      card
    rescue Stripe::CardError => e
      Rails.logger.error "Stripe card error: #{e.message}"
      e.message
    end
  end

  def self.create_stripe_charge(user, params)
    begin
      charge = Stripe::Charge.create(
        amount: params[:amount_to_be_paid].to_i * 100,
        currency: 'usd',
        source: params[:card_id],
        customer: user.stripe_id,
        description: "Amount $#{params[:amount_to_be_paid]} charged for coins"
      )

      if charge.present?
        coins = COINS_PER_AMOUNT[params[:amount_to_be_paid].to_i] || 0
        user.update(coins: user.coins + coins)

        Transaction.create!(
          charge_id: charge.id,
          customer_id: charge.customer,
          amount: charge.amount * 0.01,
          balance_transaction_id: charge.balance_transaction,
          card_number: charge.payment_method,
          brand: charge.source.brand,
          currency: charge.currency,
          user_id: user.id,
          username: user.username
        )
      end
      charge
    rescue StandardError => e
      Rails.logger.error "Stripe charge error: #{e.message}"
      nil
    end
  end
end
