require 'test_helper'

class BuyerLeadsZipCodesControllerTest < ActionController::TestCase
  setup do
    @buyer_leads_zip_code = buyer_leads_zip_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buyer_leads_zip_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create buyer_leads_zip_code" do
    assert_difference('BuyerLeadsZipCode.count') do
      post :create, buyer_leads_zip_code: @buyer_leads_zip_code.attributes
    end

    assert_redirected_to buyer_leads_zip_code_path(assigns(:buyer_leads_zip_code))
  end

  test "should show buyer_leads_zip_code" do
    get :show, id: @buyer_leads_zip_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @buyer_leads_zip_code
    assert_response :success
  end

  test "should update buyer_leads_zip_code" do
    put :update, id: @buyer_leads_zip_code, buyer_leads_zip_code: @buyer_leads_zip_code.attributes
    assert_redirected_to buyer_leads_zip_code_path(assigns(:buyer_leads_zip_code))
  end

  test "should destroy buyer_leads_zip_code" do
    assert_difference('BuyerLeadsZipCode.count', -1) do
      delete :destroy, id: @buyer_leads_zip_code
    end

    assert_redirected_to buyer_leads_zip_codes_path
  end
end
