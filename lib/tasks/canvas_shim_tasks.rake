namespace :canvas_shim do
  namespace :deploy do
    task :assets => :environment do
      CanvasShimAssetUploader.new.upload!
    end
  end
end
