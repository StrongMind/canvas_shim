describe AccountAuthorizationConfig::Clever do
    subject { described_class }
    
    context 'original and additional federated attributes are populated' do
        let(:login_attributes) { subject.recognized_federated_attributes }

        it 'includes original login_attributes' do
            expect(login_attributes).to include('id')
            expect(login_attributes).to include('sis_id')
            expect(login_attributes).to include('email')
            expect(login_attributes).to include('teacher_number')
            expect(login_attributes).to include('student_number')
        end
        
        it 'includes additional federated attributes' do
            expect(login_attributes).to include('name.first')
            expect(login_attributes).to include('name.last')
            expect(login_attributes).to include('name.full')
        end
    end

    context 'data sturcture if flattened when passed to flatten method' do
        let(:example_student_data) { { "id" => 1, "email" => "useremail", "name" => {"first" => "First", "last" => "Last"}} }
        let(:flattened_data) { subject.flatten_attributes(example_student_data) }

        it 'flattens the data structure' do 
            expect(flattened_data).to have_key(:id)
            expect(flattened_data).to have_key('name.first'.to_sym)
            expect(flattened_data).to have_key('name.last'.to_sym)
        end
    end
end