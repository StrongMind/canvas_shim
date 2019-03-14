# PipelineService
Pipeline service publishes lifecycle changes over a pipeline to federate our data and make it available widely to the organization

## Usage
```ruby
PipelineService.publish(submission)
```

## Serializers
Active record objects are transformed via "serializers" into "nouns" that are published.  Currently there are two ways that the noun is built, throuh a generic ActiveRecord JSON serializer or a call to the Canvas API (depricated).

## Events
COMING SOON!

## Adding new nouns
Nouns are built with a serializer.  A serializer receives a Noun through the #call method and returns json.  In its simplest form a serializer looks like this:
```ruby
module Serializers
  class Dog
    def initialize(noun:)
      @noun = noun
      @object = Dog.find(noun.id)
    end
  
    def call
      @object.to_json
    end
  end
end
```

## Models::Identity
Optionally, a serializer can provide a class property named #additional_identifers that provides ids that help link the noun to other entities.  An identifer is represented as an object in the pipeline.

### Usage
Standard usage.  Just pass a symbol of the field you want.
```ruby
Identifier.new(:owner_id)
```

Or you can alias it.  
```ruby
Identifier.new(:context_id, alias: :course_id).to_a
# Would result in:
[:course_id, 32]
```

Or you can pass in a proc.  Sometimes we need to traverse relationships on the active record instance.  That's what a proc is for!

```ruby
myproc = Proc.new {|dog| [:owner_spouse_id, dog.owner.spouse_id]}
Identifier.new(my_proc)
```

Return Identifiers from the additional_identifiers method in the serializer:
```ruby
module Serializers
  class Dog
    ...
    def self.additional_identifers
      [
        Identifier.new(:owner_id),
        Identifier.new(:breed_id, alias: :doggy_id),
        Identifier.new(
          Proc.new do |dog| 
            [:owner_spouse_id, dog.owner.spouse_id]
          end
        )
      ]
    end
  end
end
```

## Noun Payloads
When an ActiveRecord object is published, it is serialized into a payload that includes additional_identifiers and JSON data that represent the model.

### Assignment
```json
{
    "source": "pipeline",
    "message": {
        "noun": "assignment",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": "published"
        },
        "identifiers": {
            "id": 76308,
            "course_id": 518
        },
        "data": {
            "id": 76308,
            "description": "<p>Please remember to submit your workbook.</p>",
            "due_at": null,
            "unlock_at": null,
            "lock_at": null,
            "points_possible": 100,
            "grading_type": "points",
            "assignment_group_id": 3179,
            "grading_standard_id": null,
            "created_at": "2019-03-08T18:10:19Z",
            "updated_at": "2019-03-08T18:10:19Z",
            "peer_reviews": false,
            "automatic_peer_reviews": false,
            "position": 57,
            "grade_group_students_individually": false,
            "anonymous_peer_reviews": false,
            "group_category_id": null,
            "post_to_sis": false,
            "moderated_grading": false,
            "omit_from_final_grade": false,
            "intra_group_peer_reviews": false,
            "secure_params": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsdGlfYXNzaWdubWVudF9pZCI6IjE2MzU1OWVmLTFmY2UtNGNlMi04OGRkLTMwMDJhNDk0NGJiZiJ9.gyH69PMD-Q4Yc8IXaEae6PqMl2GnyerQJn1u4yGFvf4",
            "course_id": 518,
            "name": "Workbook 7.2 | Level Up: Slope-Intercept Form",
            "submission_types": [
                "external_tool"
            ],
            "has_submitted_submissions": false,
            "due_date_required": false,
            "max_name_length": 255,
            "in_closed_grading_period": false,
            "is_quiz_assignment": false,
            "external_tool_tag_attributes": {
                "url": "https://courseware-lti.azurewebsites.net/LtiAmalgamator/launch/5c82ae63f4a45a1a30010c1a",
                "new_tab": null,
                "resource_link_id": "d9cbc24e8326f4ca1a4e3aa444e52556cd434f5e"
            },
            "muted": false,
            "html_url": "https://courseware-staging.strongmind.com/courses/518/assignments/76308",
            "has_overrides": false,
            "url": "https://courseware-staging.strongmind.com/api/v1/courses/518/external_tools/sessionless_launch?assignment_id=76308&launch_type=assessment",
            "needs_grading_count": 0,
            "integration_id": null,
            "integration_data": {},
            "published": true,
            "unpublishable": true,
            "only_visible_to_overrides": false,
            "locked_for_user": false,
            "submissions_download_url": "https://courseware-staging.strongmind.com/courses/518/assignments/76308/submissions?zip=1"
        }
    }
}
```

### ConversationMessage
```json
{
    "source": "pipeline",
    "message": {
        "noun": "conversation_message",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": null
        },
        "identifiers": {
            "id": 60,
            "conversation_id": 51
        },
        "data": {
            "id": 60,
            "conversation_id": 51,
            "author_id": 1,
            "created_at": "2019-03-13T20:12:17Z",
            "generated": false,
            "body": "It's burg for crying out loud",
            "forwarded_message_ids": null,
            "media_comment_id": null,
            "media_comment_type": null,
            "context_id": 1,
            "context_type": "Account",
            "asset_id": null,
            "asset_type": null,
            "attachment_ids": null,
            "has_attachments": false,
            "has_media_objects": false
        }
    }
}
```
### ConversationParticipant
```json
{
    "source": "pipeline",
    "message": {
        "noun": "conversation_participant",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": "unread"
        },
        "identifiers": {
            "id": 102,
            "conversation_id": 51
        },
        "data": {
            "id": 102,
            "conversation_id": 51,
            "user_id": 32,
            "last_message_at": "2019-03-13T20:12:17Z",
            "subscribed": true,
            "workflow_state": "unread",
            "last_authored_at": null,
            "has_attachments": false,
            "has_media_objects": false,
            "message_count": 1,
            "label": null,
            "tags": "course_401",
            "visible_last_authored_at": null,
            "root_account_ids": "1",
            "private_hash": null,
            "updated_at": "2019-03-13T20:12:17Z"
        }
    }
}
### Conversation
{
    "source": "pipeline",
    "message": {
        "noun": "conversation",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": null
        },
        "identifiers": {
            "id": 51
        },
        "data": {
            "id": 51,
            "private_hash": null,
            "has_attachments": false,
            "has_media_objects": false,
            "tags": "course_401",
            "root_account_ids": "1",
            "subject": "Andy Rosebud",
            "context_type": "Course",
            "context_id": 401,
            "updated_at": "2019-03-13T20:12:17Z"
        }
    }
}
```

### Enrollment
```json
{
    "source": "pipeline",
    "message": {
        "noun": "student_enrollment",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": "invited"
        },
        "identifiers": {
            "id": 2212,
            "course_id": 502,
            "user_id": 607
        },
        "data": {
            "id": 2212,
            "user_id": 607,
            "course_id": 502,
            "type": "StudentEnrollment",
            "created_at": "2019-03-13T22:41:30Z",
            "updated_at": "2019-03-13T22:41:30Z",
            "associated_user_id": null,
            "start_at": null,
            "end_at": null,
            "course_section_id": 856,
            "root_account_id": 1,
            "limit_privileges_to_course_section": false,
            "enrollment_state": "invited",
            "role": "StudentEnrollment",
            "role_id": 3,
            "last_activity_at": null,
            "total_activity_time": 0,
            "sis_import_id": null,
            "grades": {
                "html_url": "",
                "current_score": 0,
                "current_grade": null,
                "final_score": 0,
                "final_grade": null
            },
            "html_url": ""
        }
    }
}
```

### Submission
```json
{
    "source": "pipeline",
    "message": {
        "noun": "submission",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": "unsubmitted"
        },
        "identifiers": {
            "id": 210434,
            "assignment_id": 73143,
            "course_id": 502
        },
        "data": {
            "id": 210434,
            "body": null,
            "url": null,
            "grade": null,
            "score": null,
            "submitted_at": null,
            "assignment_id": 73143,
            "user_id": 607,
            "submission_type": null,
            "workflow_state": "unsubmitted",
            "grade_matches_current_submission": true,
            "graded_at": null,
            "grader_id": null,
            "attempt": null,
            "cached_due_date": "2019-04-27T05:59:00Z",
            "excused": null,
            "late_policy_status": null,
            "points_deducted": null,
            "grading_period_id": null,
            "late": false,
            "missing": false,
            "seconds_late": 0,
            "entered_grade": null,
            "entered_score": null,
            "preview_url": "https://courseware-staging.strongmind.com/courses/502/assignments/73143/submissions/607?preview=1&version=0",
            "submission_history": [
                {
                    "id": 210434,
                    "body": null,
                    "url": null,
                    "grade": null,
                    "score": null,
                    "submitted_at": null,
                    "assignment_id": 73143,
                    "user_id": 607,
                    "submission_type": null,
                    "workflow_state": "unsubmitted",
                    "grade_matches_current_submission": true,
                    "graded_at": null,
                    "grader_id": null,
                    "attempt": null,
                    "cached_due_date": "2019-04-27T05:59:00Z",
                    "excused": null,
                    "late_policy_status": null,
                    "points_deducted": null,
                    "grading_period_id": null,
                    "late": false,
                    "missing": false,
                    "seconds_late": 0,
                    "entered_grade": null,
                    "entered_score": null,
                    "preview_url": "https://courseware-staging.strongmind.com/courses/502/assignments/73143/submissions/607?preview=1&version=0"
                }
            ]
        }
    }
}
```
### UnitGrades
```json
{
    "source": "pipeline",
    "message": {
        "noun": "unit_grades",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": null
        },
        "identifiers": {
            "id": 136822
        },
        "data": {
            "school_domain": "courseware-staging.strongmind.com",
            "course_id": 291,
            "course_score": 0,
            "student_id": 1,
            "sis_user_id": null,
            "submitted_at": null,
            "units": [
                {
                    "id": 1227,
                    "position": 1,
                    "score": null
                },
                {
                    "id": 1228,
                    "position": 2,
                    "score": null
                },
                {
                    "id": 1229,
                    "position": 3,
                    "score": null
                },
                {
                    "id": 1230,
                    "position": 4,
                    "score": null
                },
                {
                    "id": 1231,
                    "position": 5,
                    "score": null
                },
                {
                    "id": 1232,
                    "position": 6,
                    "score": null
                }
            ]
        }
    }
}
```
### User
```json
{
    "source": "pipeline",
    "message": {
        "noun": "user",
        "meta": {
            "source": "canvas",
            "domain_name": "courseware-staging.strongmind.com",
            "api_version": 1,
            "status": "creation_pending"
        },
        "identifiers": {
            "id": 607
        },
        "data": {
            "id": 607,
            "name": "42d51ccc59 smoketest",
            "sortable_name": "smoketest, 42d51ccc59",
            "short_name": "42d51ccc59 smoketest"
        }
    }
}
```