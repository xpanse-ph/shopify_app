module ShopifyApp
  module SessionStorage
    extend ActiveSupport::Concern

    included do
      validates :shopify_domain, presence: true, uniqueness: true
      validates :shopify_token, presence: true
    end

    def with_shopify_session(&block)
      ShopifyAPI::Session.temp(shopify_domain, shopify_token, &block)
    end

    class_methods do
      def store(session, company)
        if company
          store = self.find_or_initialize_by(shopify_domain: session.url)
          store.company = company
          store.shopify_token = session.token
          store.save!
          store.id
        end
      end

      def retrieve(id)
        return unless id

        if store = self.find_by(id: id)
          ShopifyAPI::Session.new(store.shopify_domain, store.shopify_token)
        end
      end
    end

  end
end
