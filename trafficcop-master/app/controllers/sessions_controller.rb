class SessionsController < ApplicationController

  def authenticate_admin
    auth_hash = request.env['omniauth.auth']

    session[:admin_user] = auth_hash['info']['email']

    if admin?
      redirect_to '/'
    else
      render :text => '401 Unauthorized', :status => 401
    end
  end

end
