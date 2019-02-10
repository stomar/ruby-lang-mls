# frozen_string_literal: true

module MLS
  class Request

    attr_reader :list, :email, :action

    ACTIONS = %w[subscribe unsubscribe]
    LISTS   = %w[ruby-talk ruby-core ruby-doc ruby-cvs]

    def initialize(params)
      @list   = params[:list]   || ""
      @email  = params[:email]  || ""
      @action = params[:action] || ""
    end

    def valid?
      valid_email? && valid_list? && valid_action?
    end

    def valid_email?
      !email.strip.empty?
    end

    def valid_list?
      LISTS.include?(list)
    end

    def valid_action?
      ACTIONS.include?(action)
    end

    def mail_options
      {
        to: "#{list}-request@ruby-lang.org",
        body: "#{action} address=#{email}"
      }
    end
  end
end
