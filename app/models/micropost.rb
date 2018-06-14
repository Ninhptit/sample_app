class Micropost < ApplicationRecord
  belongs_to :user

  mount_uploader :picture, PictureUploader
  validates :content, presence: true,
    length: {maximum: Settings.content_maximum}
  validate :picture_size

  scope :order_created_at, ->{order(created_at: :desc)}
  scope :feed, ->(_id){where(user_id: :id)}

  private
  def picture_size
    return unless picture.size > Settings.size_image.megabytes
    errors.add :picture, t("models.micropost.valid_image_size")
  end
end
