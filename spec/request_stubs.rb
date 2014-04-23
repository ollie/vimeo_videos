successful_quota_response = {
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

# signature_invalid_response = {
#   generated_in: '0.0091',
#   stat:         'fail',
#   err: {
#     code: '401',
#     expl: 'The oauth_signature passed was not valid.',
#     msg:  'Invalid signature'
#   }
# }

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getQuota').
  to_return(
    status: 200,
    body: Oj.dump(successful_quota_response, VimeoVideos::Client::OJ_OPTIONS)
  )
