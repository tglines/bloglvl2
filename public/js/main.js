$(document).ready(function(){

  var socket = io.connect('http://bloglvl2.travisglines.com');

  var side_num = 1;

  setCubeHeight = function(){
    var largest_face_height = 0;
    $('div.face').each(function(){
      if( $(this).height() > largest_face_height )
        largest_face_height = $(this).height();
    });
    $('div.face').height(largest_face_height);
  }

  if(Modernizr.history){
    var first_popstate_fired = false;
    window.onpopstate = function(e){
      if(first_popstate_fired){
        var url = window.location.pathname;
        socket.emit('req',{url:url});
      }
      else{
        first_popstate_fired = true;
      }
    };

    $('a').live('click',function(){
      if( !$(this).hasClass('ignore_history') ){
        var url = $(this).attr('href');
        socket.emit('req',{url:url});
        history.pushState({page:1},'title 1',url);
        return false;
      }
    });
  }

  socket.on('msg',function(data){
    console.log(data.msg);
  });

  socket.on('load',function(data){
    document.title = data.title;
    if(side_num==2){
      console.log('rotate');
      side_num = 1;
      $('div.face.one div.content').show();
      $('div.face.one div.content').html(data.content);
      $('#cube').css('-webkit-transform', 'rotateX(0deg) rotateY(0deg)');
      //$('#cube').css('-webkit-transform', 'rotateX(180deg) rotateY(180deg) rotateZ(180deg)');
      //$('#cube').css('-webkit-transform', 'rotateX(180deg) rotateZ(-180deg)');
      $('div.face.two div.content').fadeOut(1000);
    }
    else{
      console.log('flip');
      side_num = 2;
      $('div.face.two div.content').show();
      $('div.face.two div.content').html(data.content);
      //$('#cube').css('-webkit-transform', 'rotateX(0deg) rotateY(-180deg)');
      $('#cube').css('-webkit-transform', 'rotateX(180deg) rotateZ(-180deg)');
      $('div.face.one div.content').fadeOut(1000);
    }
  });

});
