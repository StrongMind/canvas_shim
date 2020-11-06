describe ConversationBatch do
  include_context "stubbed_network"
  let(:cm1) { ConversationMessage.create }
  let(:cm2) { ConversationMessage.create }
  subject do
    ConversationBatch.create(
      conversation_message_ids: "#{cm1.id},#{cm2.id}"
    )
  end

  it "Sends messages after update to sent" do
    expect(PipelineService).to receive(:publish_as_v2).twice
    subject.update(workflow_state: "sent")
  end

  it "does send with a different workflow state" do
    expect(PipelineService).not_to receive(:publish_as_v2)
    subject.update(workflow_state: "unsent")
  end

  it "does not send if the message isn't found" do
    cb = ConversationBatch.create(conversation_message_ids: "1234567")
    expect(PipelineService).not_to receive(:publish_as_v2)
    cb.update(workflow_state: "sent")
  end
end