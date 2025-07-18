# frozen_string_literal: true

module Hmibo
  module Concerns
    # Module for notification-related functionality
    module Notifiable
      extend ActiveSupport::Concern

      included do
        attr_accessor :send_notifications
      end

      def initialize(attributes = {})
        @send_notifications = attributes.delete(:send_notifications) { true }
        super(attributes)
      end

      private

      def send_notification(notification_type, recipient, data = {})
        return unless @send_notifications

        # This would integrate with your notification system
        # For now, we'll just log it
        log_notification(notification_type, recipient, data)
      end

      def log_notification(notification_type, recipient, data)
        if defined?(Rails)
          Rails.logger.info "Notification: #{notification_type} sent to #{recipient} with data: #{data}"
        end
      end
    end
  end
end