require 'test_helper'

class FamilyGroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  # 各テスト前に毎回実行されるセットアップ
  setup do
    # fixtures/family_group_memberships.yml の one を利用
    @membership = family_group_memberships(:one)

    # その membership に紐づくユーザー（= admin ユーザー）
    @user = @membership.user

    # 管理者ユーザーとしてログイン（test_helper.rb で定義済み）
    log_in_as(@user)
  end

  # ===== edit アクションのテスト =====
  test 'should get edit' do
    # /family_group_memberships/:id/edit にアクセス
    get edit_family_group_membership_path(@membership)

    # 正常に表示できていること（200系レスポンス）を確認
    assert_response :success
  end

  # ===== update アクションのテスト =====
  test 'should update membership' do
    # PATCH /family_group_memberships/:id に更新リクエストを送る
    patch family_group_membership_path(@membership), params: {
      family_group_membership: {
        # 実際に使っている role の enum 値に合わせて指定
        role: 'other',
        # 自分自身の admin を外すケースだと before_action で弾かれるので、
        # 「admin のまま更新する」パターンとして '1' を渡しておく
        is_admin: '1'
      }
    }

    # 更新に成功したら family_settings_path にリダイレクトする仕様なので、そこを検証
    assert_redirected_to family_settings_path
  end
end
