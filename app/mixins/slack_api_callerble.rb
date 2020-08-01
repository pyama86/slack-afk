module SlackApiCallerble
  def user_token_client
    App::Registry.user_token_client
  end

  def bot_token_client
    App::Registry.bot_token_client
  end
end
