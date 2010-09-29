require 'spec_helper'

# describe Ohm::Archive do
# 
#   describe TestDoc, 'when mixed into a document' do
#     it 'should create a new document for updates' do
#       TestDocUpdate.should be_a(Class)
#       TestDocUpdate.should respond_to(:index, :field, :key)
#     end
# 
#     it 'should copy tracked fields to the new document' do
#       TestDocUpdate.fields.keys.should include(*TestDoc.archive_fields)
#     end
# 
#     it 'should include the primary field in the list of fields' do
#       TestDoc.archive_fields.should include('day')
#     end
# 
#     it 'should provide an embed_many in the host document' do
#       TestDoc.associations.keys.should include('updates')
#     end
# 
#     it 'should reflect an embed_many in the update document' do
#       TestDocUpdate.embedded?.should be_true
#     end
#   end
# 
#   describe TestDoc do
#     before :all do
#       @doc = TestDoc.create(:name => 'test', :qty => 1, :day => 1)
#     end
# 
#     it 'should not have any updates' do
#       @doc.updates.should be_empty
#     end
# 
#     it 'should indicate a change when the target field changes' do
#       @doc.day = 2
#       @doc.archived_target_changed?.should be_true
#     end
# 
#     it 'should represent the previous state correctly' do
#       @doc.archived_attributes['qty'].should == 1
#       @doc.archived_attributes['day'].should == 1
#     end
#   end
# 
#   describe TestDoc, 'when a document changes but no tracked fields change' do
#     before :all do
#       @doc = TestDoc.create(:name => 'test', :qty => 5, :day => 1)
#       @doc.update_attributes(:name => 'test2', :qty => 5, :day => 1)
#     end
# 
#     it 'should create any updates' do
#       @doc.updates.should be_empty
#     end
#   end
# 
#   describe TestDoc, 'when a document changes and the tracked field changes' do
#     before :all do
#       @doc = TestDoc.create(:name => 'test', :qty => 5, :day => 1)
#       @doc.update_attributes(:name => 'test', :qty => 4, :day => 2)
#       @doc.update_attributes(:name => 'test', :qty => 5, :day => 2)
#     end
# 
#     it 'should save two updates' do
#       @doc.updates.size.should == 2
#     end
# 
#     it 'should save the previous state as an update' do
#       doc = @doc.updates.first
#       doc.qty.should == 5
#       doc.day.should == 1
#     end
#   end
# 
# end
# 
