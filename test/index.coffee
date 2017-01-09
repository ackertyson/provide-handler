Handler = require '../src/index'

describe 'provide-handler', ->
  describe 'wrapper',  ->
    it 'should handle promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 200
          data.should.equal 'hi'
      wrapper = Handler._wrapper (req) ->
        Promise.resolve req.fake
      wrapper fake: 'hi', mock_res

    it 'should handle failed promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.equal 'hi'
      wrapper = Handler._wrapper (req) ->
        Promise.reject req.fake
      wrapper fake: 'hi', mock_res

    it 'should handle thrown promise-based model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.be.instanceof Error
          data.should.have.property 'message', 'bye'
      wrapper = Handler._wrapper (req) ->
        throw new Error 'bye'
      wrapper fake: 'hi', mock_res

    it 'should honor explicit error response', (done) ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 404
          data.should.equal 'Huh?'
          done()
      wrapper = Handler._wrapper (req, res) ->
        Promise.reject res.status(404).json 'Huh?'
      wrapper fake: 'hi', mock_res

    it 'should honor explicit error response for non-Promise', (done) ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 404
          data.should.equal 'Huh?'
          done()
      wrapper = Handler._wrapper (req, res) ->
        res.status(404).json 'Huh?'
      wrapper fake: 'hi', mock_res

    it 'should handle non-promise model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 200
          data.should.equal 'hi'
      wrapper = Handler._wrapper (req) ->
        req.fake
      wrapper fake: 'hi', mock_res

    it 'should handle thrown non-promise model method', ->
      mock_res =
        status: (code) -> json: (data) ->
          code.should.equal 500
          data.should.be.instanceof Error
          data.should.have.property 'message', 'bye'
      wrapper = Handler._wrapper (req) ->
        throw new Error 'bye'
      wrapper fake: 'hi', mock_res
