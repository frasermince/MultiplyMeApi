OmniAuth.config.on_failure = Proc.new do |env|
  Rails.logger.info "***MAPPING #{Devise::Mapping.find_by_path!(env['PATH_INFO'], :path)}"
  env['devise.mapping'] = Devise::Mapping.find_by_path!(env['PATH_INFO'], :path)
  controller_name  = ActiveSupport::Inflector.camelize(env['devise.mapping'].controllers[:omniauth_callbacks])
  controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
  controller_klass.action(:failure).call(env)
end
