require 'mail'

module Delayed
  class PerformableMailer < PerformableMethod
    def perform
      #  object.send(method_name, *args).deliver
      mail_settings = nil
      args.each do |arg|
        puts arg
        if arg.kind_of? Hash
          if arg["mail_settings"] != nil
            # this arg provide the mail setting
            mail_settings = arg
            args.delete(arg)
            break
          end
        end
      end
 
      msg = object.send(method_name, *args)
      if mail_settings
        # apply mail settings if there is one
        msg.delivery_method.settings.merge!(mail_settings)
      end 
      msg.deliver
    end
  end

  module DelayMail
    def delay(options = {})
      DelayProxy.new(PerformableMailer, self, options)
    end
  end
end

Mail::Message.class_eval do
  def delay(*args)
    raise RuntimeError, "Use MyMailer.delay.mailer_action(args) to delay sending of emails."
  end
end
