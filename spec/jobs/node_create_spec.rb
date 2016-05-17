require 'rails_helper'
describe 'Node Creation' do
  let!(:root) { Fabricate(:section, name: 'root', id: 1)}
  let!(:parent) { Fabricate(:node, :name => "Parent page", :uuid => "parent")}
  context 'when given a valid node id for a new node' do

    it 'should create a node in this system' do
      stub_request(:get, "www.example.com/api/node/1/1")
          .to_return(:headers =>{"Content-Type" => "application/json"},
                     :body => File.read(File.join("spec", "fixtures", "drupal_node.json")))
      NodeCreateJob.perform_now "1", "1"
      expect(Node.find_by(name: "My page")).to be_present
      expect(Node.find_by(name: "My page").template).to eq("default")
      expect(Node.find_by(name: "My page").section).to eq(root)
      expect(Node.find_by(name: "My page").parent).to eq(parent)
    end
  end
  context 'when given a valid node id but parent is missing' do
    let!(:parent) { Fabricate(:node, :name => "Parent page", :uuid => "notparent")}
    it 'should create a node in this system' do
      stub_request(:get, "www.example.com/api/node/1/1")
          .to_return(:headers =>{"Content-Type" => "application/json"},
                     :body => File.read(File.join("spec", "fixtures", "drupal_node.json")))
      expect {NodeCreateJob.perform_now "1", "1"}.to raise_error
      expect(Node.second).to eq(nil)
    end
  end
  context 'when given a valid node id for an node' do
    let!(:existing_node) { Fabricate(:node, :name => "My page", :uuid => "9a1f4ffe-3f8b-4e0e-b6e0-1c58ffa6efb4",
                                     :content_block => ContentBlock.new(:body => "old body", :unique_id => "9a1f4ffe-3f8b-4e0e-b6e0-1c58ffa6efb4_body"))}
    it 'should update a node in this system' do
      stub_request(:get, "www.example.com/api/node/1/1")
          .to_return(:headers =>{"Content-Type" => "application/json"},
                     :body => File.read(File.join("spec", "fixtures", "drupal_node.json")))
      NodeCreateJob.perform_now "1", "1"
      expect(Node.find_by(name: "My page")).to be_present
      expect(Node.find_by(name: "My page").content_block.body).to eq("<p>page</p>")
    end
  end
  context 'when given a system error' do
    it 'should not create a node in this system' do
      stub_request(:get, "http://www.example.com/api/node/2/1").
          to_return(:status => 500, :body => "System error", :headers => {})
      expect {NodeCreateJob.perform_now "2", "1"}.to raise_error
      expect(Node.second).to eq(nil)
    end
  end
  context 'when given a missing node id' do
    it 'should not create a node in this system' do
      stub_request(:get, "http://www.example.com/api/node/3/1").
          to_return(:status => 404, :body => "Not found", :headers => {})
      expect {NodeCreateJob.perform_now "3", "1"}.to raise_error
      expect(Node.second).to eq(nil)
    end
  end

  context 'when given an incorrect template' do
    it 'should create a node with a default template' do
      body = JSON.load(File.read(File.join("spec", "fixtures", "drupal_node.json")))
      body['field_template']['und'][0]['value'] = 'note-a-template'
      stub_request(:get, 'www.example.com/api/node/1/1')
          .to_return(:headers =>{'Content-Type' => 'application/json'},
                     :body => JSON.dump(body))
      NodeCreateJob.perform_now '1', '1'
      expect(Node.find_by(name: 'My page')).to be_present
      expect(Node.find_by(name: 'My page').template).to eq('default')
    end
  end
end