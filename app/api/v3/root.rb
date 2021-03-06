module API
  require 'doorkeeper/grape/helpers'

  module V3
    class Root < Grape::API
      version 'v3'

      default_error_formatter :json
      content_type :json, 'application/json'
      format :json
      formatter :json, Grape::Formatter::ActiveModelSerializers

      rescue_from :all do |e|
        case e
        when ActiveRecord::RecordNotFound
          Rack::Response.new([{ error: '数据不存在' }.to_json], 404, {}).finish
        when Grape::Exceptions::ValidationErrors
          Rack::Response.new([{
            error: '参数不符合要求，请检查参数是否按照 API 要求传输。',
            validation_errors: e.errors
          }.to_json], 400, {}).finish
        else
          # ExceptionNotifier.notify_exception(e) # Uncommit it when ExceptionNotification is available
          if Rails.env.test?
            Rails.logger.error "Error: #{e}\n#{e.backtrace[0, 3].join("\n")}"
          else
            Rails.logger.error "Api V3 Error: #{e}\n#{e.backtrace.join("\n")}"
          end
          Rack::Response.new([{ error: 'API 接口异常' }.to_json], 500, {}).finish
        end
      end

      helpers Doorkeeper::Grape::Helpers
      helpers API::V3::Helpers

      mount API::V3::Users

      desc %(简单的 API 测试接口，需要验证，便于快速测试 OAuth 以及其他 API 的基本格式是否正确)
      params do
        optional :limit, type: Integer, values: 0..100
      end
      get 'hello' do
        doorkeeper_authorize!
        render current_user, meta: { time: Time.now }
      end



    end
  end
end
