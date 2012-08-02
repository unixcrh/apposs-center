module ModelHelpers
  def find_app name
    app = App.reals.where(:name => name).first
  end
 
  def user_by_name user_name
    u = User.where('email like ?', "#{user_name}%").first
  end

  def find_or_create_user user_name
    if u = user_by_name(user_name)
      u.save!
    else
      email = (user_name =~ /@[a-zA-Z]+\..+/ ) ? user_name : "#{user_name}@taobao.com"
      u = User.create! :email => email
    end
  end
  
  def fixture *args
    args = args[0] if args.size==1 && args[0].class == Array
    args.each do |fixture|
      begin
        load "#{Rails.root}/features/fixtures/#{fixture}.rb"
      rescue Exception => e
        raise e.to_s
      end
    end
  end
end

World(ModelHelpers)
