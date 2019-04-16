describe 'Feature' do
  it do
    expect(Feature.definitions).to include(
      'auto_due_dates', 
      'zero_out_past_due', 
      'auto_due_dates',
      'prescriptive_credit_recovery'
    )
  end
end