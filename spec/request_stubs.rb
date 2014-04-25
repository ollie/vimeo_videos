# vimeo.videos.upload.getQuota response.
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

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getQuota')
  .with(
    headers: {
      'Authorization' => /oauth_token="access_token"/
    }
  ).to_return(
    status: 200,
    body:   Oj.dump(SUCCESSFUL_QUOTA_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )

# Invalid signature rsponse.
SIGNATURE_INVALID_RESPONSE = {
  generated_in: '0.0091',
  stat:         'fail',
  err: {
    code: '401',
    expl: 'The oauth_signature passed was not valid.',
    msg:  'Invalid signature'
  }
}

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getQuota')
  .with(
    headers: {
      'Authorization' => /oauth_token="signature_error"/
    }
  ).to_return(
    status: 200,
    body:   Oj.dump(SIGNATURE_INVALID_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )

# vimeo.videos.upload.getTicket response.
UPLOAD_TICKET_RESPONSE = {
  generated_in: '0.0258',
  stat:         'ok',
  ticket:       {
    endpoint:        'http://1511493072.cloud.vimeo.com/upload_multi?ticket_id=efb8545e8776801df481f4cbc234ecdf',
    endpoint_secure: 'https://1511493072.cloud.vimeo.com/upload_multi?ticket_id=efb8545e8776801df481f4cbc234ecdf',
    host:            '1511493072.cloud.vimeo.com',
    id:              'efb8545e8776801df481f4cbc234ecdf',
    max_file_size:   '21474836480'
  }
}

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.getTicket')
  .with(
    headers: {
      'Authorization' => /oauth_token="access_token"/
    }
  ).to_return(
    status: 200,
    body:   Oj.dump(UPLOAD_TICKET_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )

# Upload video
WebMock.stub_request(:post, 'https://1511493072.cloud.vimeo.com/upload_multi?chunk_id=0&ticket_id=efb8545e8776801df481f4cbc234ecdf')
  .with(
    body: /chunk_id=0&file_data=.+&ticket_id=efb8545e8776801df481f4cbc234ecdf/,
    headers: {
      'Authorization' => /oauth_token="access_token"/
    }
  ).to_return(
    status: 200,
    body:   ''
  )

# vimeo.videos.upload.verifyChunks
VERIFY_CHUNKS_RESPONSE = {
  generated_in: '3.5520',
  stat:         'ok',
  ticket: {
    id: 'efb8545e8776801df481f4cbc234ecdf',
    chunks: {
      chunk: {
        id:   '0',
        size: '383631'
      }
    }
  }
}

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?format=json&method=vimeo.videos.upload.verifyChunks&ticket_id=efb8545e8776801df481f4cbc234ecdf')
  .with(
    headers: {
      'Authorization' => /oauth_token="access_token"/
    }
  ).to_return(
    status: 200,
    body:   Oj.dump(VERIFY_CHUNKS_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )

# vimeo.videos.upload.complete
COMPLETE_RESPONSE = {
  generated_in: '2.6915',
  stat:         'ok',
  ticket: {
    id:       'efb8545e8776801df481f4cbc234ecdf',
    video_id: '92927445'
  }
}

WebMock.stub_request(:get, 'https://vimeo.com/api/rest/v2?filename=example-video.mp4&format=json&method=vimeo.videos.upload.complete&ticket_id=efb8545e8776801df481f4cbc234ecdf')
  .with(
    headers: {
      'Authorization' => /oauth_token="access_token"/
    }
  ).to_return(
    status: 200,
    body:   Oj.dump(COMPLETE_RESPONSE, VimeoVideos::Client::OJ_OPTIONS)
  )
