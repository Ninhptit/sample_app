class Micropost < ApplicationRecord
  belongs_to :user
  scope :order_created_at, -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :content, presence: true,
    length: {maximum: Settings.content_maximum}
  validate :picture_size

  private
  def picture_size
    if picture.size > Settings.size_image.megabytes
      errors.add :picture, t("models.micropost.valid_image_size")
    end
  end
end
