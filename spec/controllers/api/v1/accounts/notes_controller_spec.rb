# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Accounts::NotesController do
  render_views

  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write:accounts') }
  let(:account) { Fabricate(:account) }
  let(:comment) { 'foo' }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    subject do
      post :create, params: { account_id: account.id, comment: comment }
    end

    context 'when account note has reasonable length', :aggregate_failures do
      let(:comment) { 'foo' }

      it 'updates account note' do
        subject

        expect(response).to have_http_status(200)
        expect(AccountNote.find_by(account_id: user.account.id, target_account_id: account.id).comment).to eq comment
      end
    end

    context 'when account note exceeds allowed length', :aggregate_failures do
      let(:comment) { 'a' * 2_001 }

      it 'does not create account note' do
        subject

        expect(response).to have_http_status(422)
        expect(AccountNote.where(account_id: user.account.id, target_account_id: account.id)).to_not exist
      end
    end
  end
end
