SUCCESSFUL_QUOTA_RESPONSE = {
  generated_in: '0.0124',
  stat:         'ok',
  user: {
    id:      '24997085',
    is_plus: '0',
    is_pro:  '1',
    upload_space: {
      free:   '21474836480',
      max:    '21474836480',
      resets: '1',
      used:   '0'
    },
    hd_quota: '1',
    sd_quota: '1'
  }
}

SIGNATURE_INVALID_RESPONSE = {
  generated_in: '0.0091',
  stat:         'fail',
  err: {
    code: '401',
    expl: 'The oauth_signature passed was not valid.',
    msg:  'Invalid signature'
  }
}

# Successful getQuota method call.
WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getQuota').
  with(
    headers: {
      'Authorization' => /OAuth oauth_consumer_key="client_id", oauth_nonce=".*?", oauth_signature=".*?", oauth_signature_method="HMAC-SHA1", oauth_timestamp=".*?", oauth_token="access_token", oauth_version="1.0"/,
      'User-Agent'    => 'VimeoVideos (https://github.com/ollie/vimeo_videos)'
    }
  ).to_return(
    status: 200,
    body: Oj.dump(SUCCESSFUL_QUOTA_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )

# Invalid signature.
WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getQuota').
  with(
    headers: {
      'Authorization' => /OAuth oauth_consumer_key="client_id", oauth_nonce=".*?", oauth_signature=".*?", oauth_signature_method="HMAC-SHA1", oauth_timestamp=".*?", oauth_token="signature_error", oauth_version="1.0"/,
      'User-Agent'    => 'VimeoVideos (https://github.com/ollie/vimeo_videos)'
    }
  ).to_return(
    status: 200,
    body: Oj.dump(SIGNATURE_INVALID_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )
