class AntsAdmin::SessionsController < AntsAdminController
  layout "account"
  
  # GET /admin/sign_in
  def new
    @resource = resource_name.constantize.new
  end

  # POST /admin/sign_in
  def create
   @token = resource_name.constantize.login_with(params[resource_name][:login], params[resource_name][:password])
   if @token
     cookies[:token] = @token
     redirect_to '/admin'
   else
     redirect_to '/admin/sign_in'
   end
  end

  # DELETE /admin/sign_out
  def destroy
    cookies[:token] = nil
    redirect_to '/admin/sign_in'
  end
end
