module UsersHelper
  def gravatar_for user, size: Settings.gravatar_size
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = size
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def active_unfollow id
    current_user.active_relationships.find_by followed_id: id
  end
end
