describe ConversationBackfiller do
  include_context 'pipeline_context'

  describe '.call' do
    conversation = Conversation.create
    user1 = User.create
    user2 = User.create

    conversation.conversation_messages.create author: user1
    conversation.conversation_participants.create user: user2
    conversation.conversation_participants.create user: user1

    expect(PipelineService).to receive(:publish).with(an_instance_of(Conversation))
    expect(PipelineService).to receive(:publish).with(an_instance_of(ConversationMessage)).once
    expect(PipelineService).to receive(:publish).with(an_instance_of(ConversationParticipant)).twice

    ConversationBackfiller.call
  end
end
