module.exports = (app,jade,fs,exec,posts,topics,setTopics) ->

  writePost = (req,res,editing,old_url) ->
    post_obj =
      title: req.body.post_title
      topic: req.body.post_topic
      url: req.body.post_url
      author_name: req.body.post_author_name
      author_image: req.body.post_author_image
      date_published: new Date()
      content: req.body.post_content
    if(editing)
      delete posts[old_url]
    posts[req.body.post_url] = post_obj
    setTopics()
    fs.writeFile './posts.js', 'module.exports='+JSON.stringify(posts,null,2), (err) ->
      if err                 
        console.log err       
      else
        exec "git add posts.js"       
        if editing
          exec "git commit -m 'Edited Post'"
        else
          exec "git commit -m 'Added Post'"
        exec "git push origin master", (error, stdout, stderr) ->
          console.log 'Pushed to github'
          res.redirect req.body.post_url

  app.get '/admin/post', (req,res) ->
    res.local 'title', 'New Post'
    res.local 'topics', topics
    res.render 'admin_post'

  app.get '/admin/edit_posts', (req,res) ->
    res.local 'title', 'Edit Posts'
    res.local 'topics', topics
    res.local 'posts', posts
    res.render 'admin_edit_posts'

  app.get '/admin/edit_post/posts/:post_url_fragment', (req,res) ->
    post = posts['/posts/'+req.params.post_url_fragment]
    res.local 'title', 'Edit Post - '+post.title
    res.local 'topics', topics
    res.local 'post', post
    res.render 'admin_edit_post'

  app.get '/admin/delete_post/posts/:post_url_fragment', (req,res) ->
    delete posts['/posts/'+req.params.post_url_fragment]
    fs.writeFile './posts.js', 'module.exports='+JSON.stringify(posts,null,2), (err) ->
      if err                 
        console.log err       
      else
        exec "git add posts.js"       
        exec "git commit -m 'Deleted Post'"
        exec "git push origin master", (error, stdout, stderr) ->
          console.log 'Pushed to github'
          res.redirect '/'

  app.post '/admin/edit_post/posts/:post_url_fragment', (req,res) ->
    old_url = '/posts/'+req.params.post_url_fragment
    writePost(req,res,true,old_url)
 
  app.post '/admin/post', (req,res) ->
    writePost(req,res,false,'')

  app.post '/pull_me', (req,res) ->
    console.log 'Pulling From Github Now'
    exec "git pull"
