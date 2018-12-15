module Emails
  module Easymsg
    def easy_msg_email
      @user = '447210107@qq.com'
      mail(to: @user, subject: subject("A easy email!"))
    end
  end
end
