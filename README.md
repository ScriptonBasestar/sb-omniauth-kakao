# SB OmniAuth Kakao

omniauth-kakao을 쓰려고 보니 에러나는데 업데이트가 안되는 것 같아서 수정
하다보니 ommniauth도 이상한 것 같아서 보다보니 끝이 없다.
oauth2는 다 좋은데 왜 로깅이 안되는걸까

[카카오](http://www.kakao.com/) 인증을 위한 OmniAuth strategy 입니다. [카카오 개발자 페이지](http://developers.kakao.com)에서 REST API 키를 생성한 뒤 이용해 주세요. 자세한 사항은 [시작하기 - 앱 생성](https://developers.kakao.com/docs/restapi#시작하기-앱-생성) 페이지를 참고하시기 바랍니다.

## Installation

Add to your `Gemfile`:
```ruby
gem 'sb-omniauth-kakao', git: git@github.com:ScriptonBasestar/sb-omniauth-kakao.git
```

Then `bundle install`.

## Usage

### Rails

Rails Middleware 편집

`config/initializers/omniauth.rb`:
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  # 3 중 1
  provider :kakao, ENV['KAKAO_CLIENT_ID']
  provider :kakao, ENV['KAKAO_CLIENT_ID'], ENV['KAKAO_CLIENT_SECRET']
  provider :kakao, ENV['KAKAO_CLIENT_ID'], {:redirect_path => ENV['REDIRECT_PATH']}
end
```

Then go to [My Application](https://developers.kakao.com/apps) page, select your current application and add your domain address(ex: http://localhost:3000/) to  'Setting - Platform - Web - Site Domain'.

그리고 [내 어플리케이션](https://developers.kakao.com/apps)에서 현재 어플리케이션을 선택하고, '설정 - 플랫폼 - 웹 - 사이트 도메인'에  도메인 주소(예: http://localhost:3000/)를 넣어주세요.

![이미지](https://developers.kakao.com/assets/images/dashboard/dev_011.png)

For more information, please read the [OmniAuth](https://github.com/intridea/omniauth) docs for detailed instructions.

더 자세한 사항은 [OmniAuth](https://github.com/intridea/omniauth)의 문서를 참고해 주세요.

## Example

You can test omniauth-kakao in the `example/` folder.

`example/` 폴더에 있는 예제를 통해 omniauth-kakao를 테스트해볼 수 있습니다.

```
cd example/
bundle install
KAKAO_CLIENT_ID='<your-kakako-client-id>' ruby app.rb

# 또는 Redirect Path를 설정하고 싶다면(or if you want to customize your Redirect Path)
# KAKAO_CLIENT_ID='<your-kakako-client-id>' REDIRECT_PATH='<your-redirect-path>' ruby app.rb
```

Then open `http://localhost:4567/` in your browser.

이후 `http://localhost:4567/`로 접속하시면 됩니다.

Warning: Do not forgot to add `http://localhost:4567/` in [My Application](https://developers.kakao.com/apps).

주의: [내 어플리케이션](https://developers.kakao.com/apps) 의 '설정된 플랫폼 - 웹 - 사이트 도메인'에 `http://localhost:4567/`을 넣는 걸 잊지 마세요.

## Auth Hash

Here's an example *Auth Hash* available in `request.env['omniauth.auth']`:

`request.env['omniauth.auth']` 안에 들어있는 *Auth Hash* 는 다음과 같습니다.

```ruby
{
  :provider => 'kakao',
  :uid => '123456789',
  :info => {
    :name => 'Hong Gil-Dong',
    :image => 'http://xxx.kakao.com/.../aaa.jpg',
  },
  :credentials => {
    :token => 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store.
    :refresh_token => 'OPQRST...', # OAuth 2.0 refresh_token.
    :expires_at => 1321747205, # when the access token expires (it always will)
    :expires => true # this will always be true
  },
  :extra => {
    :properties => {
      :nickname => 'Hong Gil-Dong',
      :thumbnail_image => 'http://xxx.kakao.com/.../aaa.jpg'
      :profile_image => 'http://xxx.kakao.com/.../bbb.jpg'
    }
  }
}
```

## Contributors
Issue or Fork PR
