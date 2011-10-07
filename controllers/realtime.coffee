module.exports = (io,jade,fs,posts,topics) ->
  post_list_file = fs.readFileSync './views/post_list.jade'
  admin_post_file = fs.readFileSync './views/admin_post.jade'
  admin_edit_post_file = fs.readFileSync './views/admin_edit_post.jade'
  admin_edit_posts_file = fs.readFileSync './views/admin_edit_posts.jade'

  io.sockets.on 'connection', (socket) ->
    socket.emit 'msg', {msg:'connected'}
    socket.on 'req', (data) ->

      if data.url is '/'
        title = 'Blog of Travis Glines'
        template = jade.compile post_list_file
        socket.emit 'load', {title:title,content: template({title:title, posts:posts, topics:topics})}

      else if data.url.substring(0,7) is '/topic/'
        topic_posts = {}
        for url of posts   
          post = posts[url]
          if post.topic is data.url.substring(7)
            topic_posts[url] = post
        title = 'Posts about '+data.url.substring(7)
        template = jade.compile post_list_file
        socket.emit 'load', {title:title,content: template({title:title, posts:topic_posts, topics:topics})}

      else if data.url is '/admin/edit_posts'
        title = 'Edit Posts'
        template = jade.compile admin_edit_posts_file
        socket.emit 'load', {title:title,content: template({title:title, posts:posts, topics:topics})}

      else if data.url.substring(0,23) is '/admin/edit_post/posts/'
        post = posts[data.url.substring(16)]
        if post
          title = 'Edit Post -'+post.title
          template = jade.compile admin_edit_post_file
          socket.emit 'load', {title:title,content: template({title:title, post:post, topics:topics})}
        else
          title = 'Edit Post'
          template = jade.compile post.content
          socket.emit 'load', {title:title,content: template({title:title})}

      else if data.url is '/admin/post'
        title = 'New Post'
        template = jade.compile admin_post_file
        socket.emit 'load', {title:title,content: template({title:title})}

      else
        post = posts[data.url]
        if post
          title = post.title
          template = jade.compile post.content
          socket.emit 'load', {title:title,content: template({title:title})}
