namespace :canvas_shim do
  namespace :backfill do
    task :conversations => :environment do
      ConversationBackfiller.call
    end
  end
end
