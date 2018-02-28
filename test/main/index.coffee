Handler = require '../../src/index'
handler = new Handler
mock_next = (expected) ->
  (err) ->
    expect(err).to.be.null unless expected?
    err.should.have.property 'message', expected

describe 'provide-handler', ->
  describe '_promisify',  ->
    it 'should handle promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 200
          data.should.equal 'hi'
      proxy = handler._promisify (req) ->
        Promise.resolve req.fake
      proxy fake: 'hi', mock_res, mock_next()

    it 'should handle failed promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.equal 'hi'
      proxy = handler._promisify (req) ->
        Promise.reject new Error 'bye'
      proxy fake: 'hi', mock_res, mock_next 'hi'

    it 'should handle thrown promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.have.length 0
      proxy = handler._promisify (req) ->
        throw new Error 'bye'
      proxy fake: 'hi', mock_res, mock_next 'bye'

    it 'should honor explicit error response', (done) ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 404
          data.should.equal 'Huh?'
          done()
      proxy = handler._promisify (req, res) ->
        res.status(404).json 'Huh?'
      proxy fake: 'hi', mock_res, mock_next()

    it 'should honor explicit error response for non-Promise', (done) ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 404
          data.should.equal 'Huh?'
          done()
      proxy = handler._promisify (req, res) ->
        res.status(404).json 'Huh?'
      proxy fake: 'hi', mock_res, mock_next()

    it 'should handle non-promise model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 200
          data.should.equal 'hi'
      proxy = handler._promisify (req) ->
        req.fake
      proxy fake: 'hi', mock_res, mock_next()

    it 'should handle thrown non-promise model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.have.length 0
      proxy = handler._promisify (req) ->
        throw new Error 'bye'
      proxy fake: 'hi', mock_res, mock_next 'bye'
