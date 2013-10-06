require 'spec_helper'

describe BlogsController do
  describe 'authorize' do
    it 'should pass the correct redirect url to the oauth consumer' do
      OAuth::Consumer.any_instance.should_receive(:get_request_token).and_call_original
      get :authorize
    end

    it 'should redirect to the tumblr auth url' do
      get :authorize
      expect(response).to redirect_to 'http://www.tumblr.com/oauth/authorize?oauth_token=fzG7wXQTmHKTYiDYqzgXUZx1OgOvqwbQYIQp594W6zaBrLgzRh'
    end
  end

  describe 'new' do
    context 'if no request_token has been set' do
      it 'should redirect to :authorize' do
        get :new
        expect(response).to redirect_to authorize_blogs_url
      end
    end

    context 'when request_token is stored in the session' do
      before :each do
        @request_token = double "request_token"
        @access_token = double "access_token"

        session[:request_token] = @request_token
      end

      context 'when the access token is successfully fetched' do
        before :each do
          allow(@access_token).to receive(:token).and_return 'token'
          allow(@access_token).to receive(:secret).and_return 'secret'
        end

        it 'should be successful' do
          allow(@request_token).to receive(:get_access_token).and_return @access_token

          get :new
          expect(response).to be_successful
        end
      end

      context 'when getting the access token throws an exception' do
        it 'should set a flash error message' do
          allow(@request_token).to receive(:get_access_token).and_raise("Something bad happened")
          session[:request_token] = @request_token

          get :new

          expect(flash[:error]).to eq "Something bad happened"
        end
      end
    end
  end
end