module API
  module V3
    class Users < Grape::API
      resource :users do
        # Get top 20 hot users
        params do
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get do
          params[:limit] = 100 if params[:limit] > 100
          @users = User.select(:id, :email).limit(params[:limit])
          render @users
        end

        desc '获取当前登陆者的资料'
        get 'me', serializer: UserSerializer, root: 'user' do
          doorkeeper_authorize!
          render current_user
        end

        namespace ':login' do
          before do
            @user = User.find_login(params[:login])
          end

          desc '获取用户详细资料'
          get '', serializer: UserSerializer, root: 'user' do
            meta = {followed: false, blocked: false}

            # if current_user
            #   meta[:followed] = current_user.followed?(@user)
            #   meta[:blocked] = current_user.blocked_user?(@user)
            # end

            render @user, meta: meta
          end

        end
      end
    end
  end
end
