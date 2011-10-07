module.exports = (app,jade,posts,topics) ->
  app.get '/', (req,res) ->
    res.local 'title', 'Blog of Travis Glines'
    res.local 'topics', topics
    res.local 'posts', posts
    res.render 'post_list'

  app.get '/topic/:topic_name', (req,res) ->
    res.local 'title', 'Posts about '+req.params.topic_name
    res.local 'topics', topics
    topic_posts = {}
    for url of posts
      post = posts[url]
      if post.topic is req.params.topic_name
        topic_posts[url] = post
    res.local 'posts', topic_posts
    res.render 'post_list'

  app.get '/debug', (req,res) ->
    res.end JSON.stringify(posts)

  app.get '/posts/:post_url_fragment', (req,res) ->
    post = posts[req.url]
    if post        
      res.local 'title', post.title
      res.local 'topics', topics
      p = jade.compile post.content
      res.local 'post', p({title:post.title})
      res.render 'post'
    else           
      resp = req.url+'\n'       
      resp += JSON.stringify(posts)+'\n'
      res.end resp+'\n not found'
