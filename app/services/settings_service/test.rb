require 'business'
course = Course.find(1)
startdate = course.start_at
enddate = course.end_at

calendar = Business::Calendar.new(working_days: %w( mon tue wed thu fri ))

business_days = calendar.business_days_between(startdate, enddate)

# assignments = Assignment.where(course: course)
assignments = ContentTag.where(content_type: 'Assignment', context_id: Course.first.id).order(:position).map{|tag| tag.assignment }
assignments_per_day = (assignments.count / business_days).to_i

byego

day = 1
assignments.each do |assignment|
  for i in 1..assignments_per_day
     #loop until business day
     while !calendar.business_day?(startdate + day.day) do
       day = day + 1
     end
     puts "assignment: #{i} day: #{day}"
     assignment.update(due_at: startdate + day.day)
  end
  day = day + 1
end
