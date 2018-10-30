require "mail"

class Mailer
  def initialize
    options = { :address              => "smtp.gmail.com",
                :port                 => 587,
                :user_name            => ENV["FLAT_FINDER_SENDER"],
                :password             => ENV["FLAT_FINDER_PASSW"],
                :authentication       => "plain",
                :enable_starttls_auto => true  }

    Mail.defaults do
      delivery_method :smtp, options
    end
  end

  def send(results)
    p "Sending email with results..."
    text = results.map { |result| "#{result}\n\n" }

    Mail.deliver do
           to ENV["FLAT_FINDER_RECEIVER"]
         from ENV["FLAT_FINDER_SENDER"]
      subject "Your latest #{results.length} 🏡"
         body text
    end
  end
end
