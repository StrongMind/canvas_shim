require 'aws-sdk-s3'
class CanvasShimAssetUploader < Canvas::Cdn::S3Uploader
  BUCKET_NAME = ENV['ASSET_OBJECT_STORE'] || ''
  REGION = ENV['AWS_REGION'] || 'us-west-2'
  ACCESS_KEY_ID = ENV['S3_ACCESS_KEY_ID'] || ''
  SECRET_ACCESS_KEY = ENV['S3_ACCESS_KEY'] || ''

  def initialize(folder='dist')
    require 'aws-sdk-s3'
    @folder = folder
    @s3 = Aws::S3::Resource.new(
      access_key_id: ACCESS_KEY_ID,
      secret_access_key: SECRET_ACCESS_KEY,
      region: REGION
    )
    @bucket = @s3.bucket(BUCKET_NAME)
    @mutex = Mutex.new
  end
end
