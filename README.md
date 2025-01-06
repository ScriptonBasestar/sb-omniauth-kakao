# Sb::Omniauth::Kakao

## Installation

```ruby
gem 'sb-omniauth-kakao'
```

## Kakao app
https://developers.kakao.com/console/app

## Usage


```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :sb_kakao_oauth2, ENV['KAKAO_CLIENT_ID'], ENV['KAKAO_CLIENT_SECRET']
end
OmniAuth.config.allowed_request_methods = %i[get]
```
