module AuthenticationMethodsShim
  include CanvasShim::AuthenticationMethods

  def self.included base
    base.send :alias_method, :original_method, :load_user
    base.send(
      :define_method,
      :load_user,
      CanvasShim::AuthenticationMethods.instance_method(:load_user)
    )

    base.send(:define_method, :canvas_shim_extensions) do
      @canvas_shim_extensions ||= []
      @canvas_shim_extensions
    end
  end
end

AuthenticationMethods.include(AuthenticationMethodsShim)
