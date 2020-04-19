require "discordrb"
require "net/http"
require "json"

module Bot

  def parse_msg(msg)
    base = "https://covid2019-api.herokuapp.com/v2"
    if msg == "!corona"
      country = nil
    else 
      country = "#{msg}".sub! "!corona ", ""
    end
    stub = country == nil ? "total" : "country/#{country}"
    uri = URI("#{base}/#{stub}")
    res = Net::HTTP.get(uri)
    entries = JSON.parse(res)

    return entries["data"], country
  end

  def start(options)
    bot = Discordrb::Bot.new token: options.api_key
    bot.message() do |event|
      if "#{event.message}" =~ /^\!corona/ 
        res, country = parse_msg(event.message)
        if res
          event.channel.send_embed("") do |embed|
            embed.title = "Corona stats"
            embed.url = "https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public"
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://cdn.discordapp.com/attachments/239446877953720321/691020838379716698/unknown.png")
            res.keys.each do |k|
              embed.add_field(name: k, value: res[k].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse)
            end
          end
        end
      end
    end
    bot.run
  end
end
