# frozen_string_literal: true

shared_examples "permittable create actions" do
  context "when private user" do
    before do
      sign_in user
    end

    it "does not permit create action" do
      post(:create, params:)
      expect(response).to render_template("decidim/privacy/privacy_block")
    end
  end

  context "when public user" do
    before do
      user.update!(published_at: Time.current)
      sign_in user
    end

    it "permits create action" do
      post(:create, params:)
      expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    end
  end
end

shared_examples "permittable new actions" do
  context "when private user" do
    before do
      sign_in user
    end

    it "does not permit new action" do
      get(:new, params:)
      expect(response).to render_template("decidim/privacy/privacy_block")
    end
  end

  context "when public user" do
    before do
      user.update!(published_at: Time.current)
      sign_in user
    end

    it "permits new action" do
      get(:new, params:)
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:ok)
    end
  end
end

shared_examples "permittable update actions" do
  context "when private user" do
    before do
      sign_in user
    end

    it "does not permit update action" do
      patch(:update, params:)
      expect(response).to redirect_to("/")
      expect(flash[:alert]).to be_present
    end
  end

  context "when public user" do
    before do
      user.update!(published_at: Time.current)
      sign_in user
    end

    it "permits update action" do
      patch(:update, params:)
      expect(response).to have_http_status(:found)
      expect(flash[:alert]).not_to be_present
    end
  end
end

shared_examples "permittable edit actions" do
  context "when private user" do
    before do
      sign_in user
    end

    it "does not permit edit action" do
      get(:edit, params:)
      expect(response).to redirect_to("/")
      expect(flash[:alert]).to be_present
    end
  end

  context "when public user" do
    before do
      user.update!(published_at: Time.current)
      sign_in user
    end

    it "permits edit action" do
      get(:edit, params:)
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:ok)
      expect(flash[:alert]).not_to be_present
    end
  end
end
