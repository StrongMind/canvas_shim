namespace :canvas_shim do
    namespace :content do
      task :clear_course_content_and_migration, [:course_id] => :environment do
        c = Course.find(course_id)
        raise "Course #{course_id} has student submissions." if Submission.where(context_code: "course_#{course_id}").exists?

        c.context_modules.destroy_all #destroys all published modules
        cms = ContentMigration.where(context_id: course_id, context_type: 'Course') #List of content migrations
        raise "Course #{course_id} has more than content migration." if cms.count > 1

        cms.first.migration_issues.destroy_all
        cms.first.destroy
        c.save
        puts "Course #{course_id} was successfully cleared."
      end
    end
  end