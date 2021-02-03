require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:enuri)
  end

  test "micropost interface" do 
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]' # 画像関連
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } } 
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # 正しいページネーションリンク 
    # 有効な送信
    content = "This micropost really ties the room together" 
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, image: image} } # 画像関連
    end
    assert assigns(:micropost).image.attached? # 画像関連
    #assert_redirected_to root_url 
    follow_redirect!
    assert_match content, response.body 
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first 
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認) 
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
end
