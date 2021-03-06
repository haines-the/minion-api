# frozen_string_literal: true

module V1
  class ServerService
    def initialize(params: nil)
      @params = params
    end

    def create
      server = Server.new(@params)
      ip_error = nil
      begin
        server.addresses = [@params[:addresses]]
        aliases = @params[:aliases] || server.organization.name.gsub(' ', '-') + "-#{Faker::Number.unique.number(digits: 3)}"
        server.aliases = [aliases]
        IPAddr.new(@params[:addresses])
      rescue IPAddr::Error => error
        ip_error = error.message
      ensure
        if ip_error.nil? && server.save
          return { success: true, data: V1::ServerSerializer.new(server).serializable_hash[:data] }
        else
          errors = server.errors.messages
          errors[:addresses] = ip_error if ip_error.present?
          return { success: false, errors: errors }
        end
      end
    end

    def update(server)
      ip_error = nil
      begin
        server.addresses = [@params[:addresses]] if @params[:addresses]
        server.aliases = [@params[:aliases]] if @params[:aliases]
        server.organization_id = @params[:organization_id] if @params[:organization_id]
        IPAddr.new(@params[:addresses]) if @params[:addresses]
      rescue IPAddr::Error => error
        ip_error = error.message
      ensure
        if ip_error.nil? && server.save
          return { success: true, data: V1::ServerSerializer.new(server).serializable_hash[:data] }
        else
          errors = server.errors.messages
          errors[:addresses] = ip_error if ip_error.present?
          return { success: false, errors: errors }
        end
      end
    end
  end
end
